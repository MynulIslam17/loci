import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart'
    show SK2PurchaseDetails;
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart'
    show SK2Transaction;
import 'package:loci/core/iap/iap.dart';
import 'package:loci/features/subscription/data/config/loci_iap_products.dart';
import 'package:loci/features/subscription/data/models/purchase_evidence.dart';
import 'package:loci/features/subscription/data/models/store_subscription_plan.dart';
import 'package:loci/features/subscription/data/models/verify_result.dart';
import 'package:loci/features/subscription/data/storage/pending_verification_queue.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';

/// Result of a user-initiated purchase, as decided by the backend.
enum PurchaseOutcome {
  /// `200` from `/subscriptions/verify` and the status was refreshed.
  success,

  /// Store / server say the payment is still pending (Ask to Buy, slow card).
  pending,

  /// Temporary failure — activation will be retried automatically.
  deferred,

  /// Definitive failure (rejected purchase, store error, not started).
  failed,

  /// The user dismissed the store sheet.
  cancelled,
}

/// Owns the store purchase stream (from app start), the verify → complete
/// pipeline, the persistent pending-verification queue and restore.
///
/// Golden rule: the store says "a purchase happened"; only the backend says
/// "this account has access". Nothing here unlocks a feature on its own.
class SubscriptionController extends GetxController
    with WidgetsBindingObserver {
  SubscriptionController({
    SubscriptionService? service,
    PendingVerificationQueue? queue,
    InAppPurchase? store,
    StorePlatform? platform,
    String? Function()? currentUserId,
    Future<void> Function()? refreshStatus,
    Stream<Object?>? sessionChanges,
    Stream<bool>? connectivityRestored,
    bool observeLifecycle = true,
    Duration purchaseTimeout = const Duration(minutes: 3),
    Duration restoreQuietPeriod = const Duration(seconds: 2),
    Future<List<PurchaseDetails>> Function()? unfinishedTransactions,
  }) : _serviceOverride = service,
       _unfinishedOverride = unfinishedTransactions,
       _queue = queue ?? PendingVerificationQueue(),
       _store = store,
       _platform = platform ?? _detectPlatform(),
       _currentUserId = currentUserId ?? (() => null),
       _refreshStatus = refreshStatus ?? (() async {}),
       _sessionChanges = sessionChanges,
       _connectivityRestored = connectivityRestored,
       _observeLifecycle = observeLifecycle,
       _purchaseTimeout = purchaseTimeout,
       _restoreQuietPeriod = restoreQuietPeriod;

  final SubscriptionService? _serviceOverride;
  final PendingVerificationQueue _queue;
  final InAppPurchase? _store;
  final StorePlatform? _platform;
  final String? Function() _currentUserId;
  final Future<void> Function() _refreshStatus;
  final Stream<Object?>? _sessionChanges;
  final Stream<bool>? _connectivityRestored;
  final bool _observeLifecycle;
  final Duration _purchaseTimeout;
  final Duration _restoreQuietPeriod;
  final Future<List<PurchaseDetails>> Function()? _unfinishedOverride;
  bool _recovering = false;

  SubscriptionService get _service =>
      _serviceOverride ?? Get.find<SubscriptionService>();

  static StorePlatform? _detectPlatform() {
    if (Platform.isIOS) return StorePlatform.apple;
    if (Platform.isAndroid) return StorePlatform.google;
    return null;
  }

  late final IapService _iapService;
  final List<StreamSubscription<Object?>> _subs = <StreamSubscription<Object?>>[];

  Completer<PurchaseOutcome>? _purchaseResult;
  String? _pendingProductId;
  bool _processingQueue = false;

  // Restore bookkeeping.
  bool _restoring = false;
  int _restoredOk = 0;
  String? _restoreError;
  Timer? _restoreQuietTimer;

  final Rxn<ProductDetails> monthlyProduct = Rxn<ProductDetails>();
  final Rxn<ProductDetails> yearlyProduct = Rxn<ProductDetails>();
  final RxBool isLoading = true.obs;
  final RxBool isPurchasing = false.obs;
  final RxBool isRestoring = false.obs;

  /// Store reported the payment as pending ("Waiting for approval…").
  final RxBool isAwaitingApproval = false.obs;
  final RxnString errorMessage = RxnString();

  /// Neutral feedback (pending, deferred activation, restore result).
  final RxnString infoMessage = RxnString();
  final RxList<StoreSubscriptionPlan> plans = <StoreSubscriptionPlan>[].obs;
  final Rxn<StoreSubscriptionPlan> selectedPlan = Rxn<StoreSubscriptionPlan>();

  bool get isSupportedPlatform => _platform != null;

  ProductDetails? productFor(String? productId) =>
      productId == LociIapProducts.monthly
      ? monthlyProduct.value
      : productId == LociIapProducts.yearly
      ? yearlyProduct.value
      : null;

  @override
  void onInit() {
    super.onInit();
    plans.assignAll(StoreSubscriptionPlan.catalog);
    selectedPlan.value = plans.firstWhere(
      (StoreSubscriptionPlan plan) => plan.type == StorePlanType.monthly,
    );
    final InAppPurchase store = _store ?? InAppPurchase.instance;
    _iapService = IapService(
      config: const IapConfig(productIds: LociIapProducts.all),
      verifyPurchase: _verify,
      store: store,
      isAndroid: _platform == StorePlatform.google,
      googlePastPurchases: _platform == StorePlatform.google
          ? () => _loadGooglePurchases(store)
          : null,
      finishWithoutPurchaseId: _platform == StorePlatform.apple
          ? _finishAppleById
          : null,
    );
    _subs.add(_iapService.events.listen(_handleEvent));
    if (_observeLifecycle) WidgetsBinding.instance.addObserver(this);

    final Stream<Object?>? session = _sessionChanges;
    if (session != null) {
      _subs.add(
        session.listen((_) {
          unawaited(processPendingQueue(ignoreBackoff: true));
          unawaited(recoverUnfinishedTransactions());
        }),
      );
    }
    final Stream<bool>? restored = _connectivityRestored;
    if (restored != null) {
      _subs.add(
        restored.listen((bool online) {
          if (online) unawaited(processPendingQueue());
        }),
      );
    }

    // Subscribe to the purchase stream at app start (not inside the paywall).
    unawaited(initialize().then((_) => recoverUnfinishedTransactions()));
    unawaited(processPendingQueue(ignoreBackoff: true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(processPendingQueue());
      unawaited(recoverUnfinishedTransactions());
    }
  }

  /// StoreKit 2 does not re-deliver unfinished transactions on the purchase
  /// stream by itself (verified on the simulator), so a transaction left open
  /// — signed out at purchase time, crash before finishing, retryable server
  /// error — would be lost. Query `Transaction.unfinished` and run each one
  /// through the normal verify → complete pipeline (server is idempotent).
  Future<void> recoverUnfinishedTransactions() async {
    if (_recovering || !_iapService.isAvailable) return;
    if ((_currentUserId() ?? '').isEmpty) return;
    final Future<List<PurchaseDetails>> Function()? loader =
        _unfinishedOverride ??
        (_platform == StorePlatform.apple ? _loadUnfinishedApple : null);
    if (loader == null) return;
    _recovering = true;
    try {
      final List<PurchaseDetails> unfinished = await loader();
      if (unfinished.isNotEmpty) {
        await _iapService.handleRecoveredPurchases(unfinished);
      }
    } catch (_) {
      // Try again on the next launch / resume.
    } finally {
      _recovering = false;
    }
  }

  static Future<List<PurchaseDetails>> _loadUnfinishedApple() async {
    final List<SK2Transaction> transactions =
        await SK2Transaction.unfinishedTransactions();
    return transactions
        .map(
          (SK2Transaction t) => SK2PurchaseDetails(
            productID: t.productId,
            purchaseID: t.id,
            verificationData: PurchaseVerificationData(
              localVerificationData: t.jsonRepresentation ?? '',
              serverVerificationData: t.receiptData ?? '',
              source: 'app_store',
            ),
            transactionDate: t.purchaseDate,
            status: PurchaseStatus.purchased,
            appAccountToken: t.appAccountToken,
          ),
        )
        .toList();
  }

  static Future<List<GooglePlayPurchaseDetails>> _loadGooglePurchases(
    InAppPurchase store,
  ) async {
    final InAppPurchaseAndroidPlatformAddition addition = store
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final QueryPurchaseDetailsResponse response = await addition
        .queryPastPurchases();
    return response.pastPurchases;
  }

  /// StoreKit 2 id 0 (Xcode StoreKit testing) has no `purchaseID`; finish it
  /// by the id inside its signed transaction.
  static Future<bool> _finishAppleById(PurchaseDetails purchase) async {
    final int? id = int.tryParse(appleTransactionId(purchase) ?? '');
    if (id == null) return false;
    await SK2Transaction.finish(id);
    return true;
  }

  void selectPlan(StoreSubscriptionPlan plan) => selectedPlan.value = plan;

  Future<PurchaseOutcome> subscribe() async {
    final StoreSubscriptionPlan? plan = selectedPlan.value;
    if (plan == null || !plan.isPaid) return PurchaseOutcome.failed;
    return purchase(plan.productId!);
  }

  Future<void> initialize() async {
    if (!isSupportedPlatform) {
      isLoading.value = false;
      errorMessage.value = 'Subscriptions are not available on this device.';
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await _iapService.initialize();
      if (!_iapService.isAvailable) {
        errorMessage.value = 'In-app purchases are not available.';
      }
      _updateProducts();
    } catch (error) {
      errorMessage.value = _friendly(error);
    } finally {
      isLoading.value = false;
    }
  }

  void _updateProducts() {
    monthlyProduct.value = _iapService.productById(LociIapProducts.monthly);
    yearlyProduct.value = _iapService.productById(LociIapProducts.yearly);
  }

  // ── Verification pipeline ────────────────────────────────────────────────

  /// Called by [IapService] for every `purchased` / `restored` event. The
  /// service finishes the transaction only on verified / rejected.
  Future<IapVerificationResult> _verify(PurchaseDetails purchase) async {
    final StorePlatform? platform = _platform;
    final String userId = _currentUserId() ?? '';
    if (platform == null || userId.isEmpty) {
      // Not signed in: leave the transaction open; the store re-delivers it.
      return const IapVerificationResult(
        IapVerification.retryLater,
        message: 'Sign in to finish activating your plan.',
      );
    }

    final Map<String, dynamic> body = buildVerifyBody(
      purchase,
      platform: platform,
    );
    if (!hasVerifiableEvidence(body)) {
      return const IapVerificationResult(
        IapVerification.rejected,
        message: 'This purchase could not be verified.',
      );
    }

    // Survive crash / restart between purchase and verify.
    await _queue.save(userId, body);
    final VerifyResult result = await _verifyBody(userId, body);
    return IapVerificationResult(
      _toIapVerification(result.kind),
      message: result.message,
    );
  }

  /// Sends one body and updates the queue per spec §5. Refreshes status after
  /// a `200` (before the caller shows any success UI).
  Future<VerifyResult> _verifyBody(
    String userId,
    Map<String, dynamic> body,
  ) async {
    VerifyResult result;
    try {
      result = await _service.verifyPurchase(body);
    } catch (error) {
      result = VerifyResult(
        VerifyResultKind.retryable,
        message: _friendly(error),
      );
    }

    switch (result.kind) {
      case VerifyResultKind.success:
        await _queue.remove(userId, body);
        await _safeRefreshStatus();
      case VerifyResultKind.invalid:
        await _queue.remove(userId, body);
      case VerifyResultKind.pending:
      case VerifyResultKind.retryable:
        await _queue.markAttempt(userId, body);
    }
    return result;
  }

  static IapVerification _toIapVerification(VerifyResultKind kind) {
    switch (kind) {
      case VerifyResultKind.success:
        return IapVerification.verified;
      case VerifyResultKind.pending:
        return IapVerification.pending;
      case VerifyResultKind.invalid:
        return IapVerification.rejected;
      case VerifyResultKind.retryable:
        return IapVerification.retryLater;
    }
  }

  Future<void> _safeRefreshStatus() async {
    try {
      await _refreshStatus();
    } catch (_) {
      // Status keeps its last known value; it is refreshed again on resume.
    }
  }

  /// Retries queued verifications for the signed-in user only (§5). Never
  /// shows success UI — the status refresh after a `200` updates the app.
  Future<void> processPendingQueue({bool ignoreBackoff = false}) async {
    if (_processingQueue) return;
    final String userId = _currentUserId() ?? '';
    if (userId.isEmpty) return;
    _processingQueue = true;
    try {
      final List<PendingVerification> due = await _queue.due(
        userId,
        ignoreBackoff: ignoreBackoff,
      );
      for (final PendingVerification entry in due) {
        // Stop if the account changed mid-run.
        if ((_currentUserId() ?? '') != userId) break;
        await _verifyBody(userId, entry.body);
      }
    } catch (_) {
      // Storage failure — try again on the next trigger.
    } finally {
      _processingQueue = false;
    }
  }

  // ── Store events ─────────────────────────────────────────────────────────

  void _handleEvent(IapEvent event) {
    switch (event.type) {
      case IapEventType.productsLoaded:
        _updateProducts();
        isLoading.value = false;
        errorMessage.value = event.message;
      case IapEventType.purchasePending:
        if (_isCurrent(event.productId)) {
          isAwaitingApproval.value = true;
          infoMessage.value = 'Waiting for approval…';
        }
      case IapEventType.purchaseCompleted:
      case IapEventType.purchaseRestored:
        if (_restoring) _restoredOk++;
        _finishPurchase(PurchaseOutcome.success, productId: event.productId);
        if (_restoring) _bumpRestoreQuietTimer();
      case IapEventType.verificationPending:
        _setInfoIfCurrent(
          event.productId,
          'Your payment is pending. We\'ll activate your plan as soon as it completes.',
        );
        _finishPurchase(PurchaseOutcome.pending, productId: event.productId);
        if (_restoring) _bumpRestoreQuietTimer();
      case IapEventType.verificationDeferred:
        _setInfoIfCurrent(
          event.productId,
          'We\'ll finish activating your plan shortly.',
        );
        _finishPurchase(PurchaseOutcome.deferred, productId: event.productId);
        if (_restoring) _bumpRestoreQuietTimer();
      case IapEventType.verificationFailed:
        final String message =
            event.message ?? 'This purchase could not be verified.';
        if (_restoring) {
          _restoreError = message;
          _bumpRestoreQuietTimer();
        }
        if (_isCurrent(event.productId) || _restoring) {
          errorMessage.value = message;
        }
        _finishPurchase(PurchaseOutcome.failed, productId: event.productId);
      case IapEventType.purchaseCanceled:
        _finishPurchase(PurchaseOutcome.cancelled, productId: event.productId);
      case IapEventType.purchaseFailed:
        if (_isCurrent(event.productId)) {
          errorMessage.value = event.message ?? 'Purchase failed.';
        }
        _finishPurchase(PurchaseOutcome.failed, productId: event.productId);
      case IapEventType.error:
        if (event.productId != null && _isCurrent(event.productId)) {
          errorMessage.value = event.message ?? 'Something went wrong.';
          _finishPurchase(PurchaseOutcome.failed, productId: event.productId);
        }
      case IapEventType.storeUnavailable:
        errorMessage.value = event.message;
      case IapEventType.restoreFinished:
        if (_restoring) _bumpRestoreQuietTimer();
      default:
        break;
    }
  }

  bool _isCurrent(String? productId) =>
      _pendingProductId != null && productId == _pendingProductId;

  void _setInfoIfCurrent(String? productId, String message) {
    if (_isCurrent(productId) || _restoring) infoMessage.value = message;
  }

  // ── Purchase ─────────────────────────────────────────────────────────────

  Future<PurchaseOutcome> purchase(String productId) async {
    if (!isSupportedPlatform) {
      errorMessage.value = 'Subscriptions are not available on this device.';
      return PurchaseOutcome.failed;
    }
    if (isPurchasing.value || productFor(productId) == null) {
      return PurchaseOutcome.failed;
    }
    final String userId = _currentUserId() ?? '';
    if (userId.isEmpty) {
      errorMessage.value = 'Sign in to subscribe.';
      return PurchaseOutcome.failed;
    }

    errorMessage.value = null;
    infoMessage.value = null;
    isAwaitingApproval.value = false;
    isPurchasing.value = true;
    final Completer<PurchaseOutcome> result = Completer<PurchaseOutcome>();
    _purchaseResult = result;
    _pendingProductId = productId;

    try {
      final String? token = await _accountToken(userId);
      final bool started = await _iapService.purchase(
        productId,
        applicationUserName: token,
      );
      if (!started) _finishPurchase(PurchaseOutcome.failed);
    } catch (error) {
      errorMessage.value = _friendly(error);
      _finishPurchase(PurchaseOutcome.failed);
    }

    return result.future.timeout(
      _purchaseTimeout,
      onTimeout: () {
        // Still pending in the store; the stream + queue keep handling it.
        infoMessage.value =
            'Your purchase is still being processed. We\'ll activate your plan once it completes.';
        _finishPurchase(PurchaseOutcome.pending);
        return PurchaseOutcome.pending;
      },
    );
  }

  /// Account token binds the purchase to this Loci account. Without it the
  /// purchase still works (legacy "first account to verify wins").
  Future<String?> _accountToken(String userId) async {
    try {
      return await _service.getAccountToken(userId);
    } catch (_) {
      return null;
    }
  }

  void _finishPurchase(PurchaseOutcome outcome, {String? productId}) {
    if (productId != null && productId != _pendingProductId) return;
    final Completer<PurchaseOutcome>? result = _purchaseResult;
    _purchaseResult = null;
    _pendingProductId = null;
    isPurchasing.value = false;
    isAwaitingApproval.value = false;
    if (result != null && !result.isCompleted) result.complete(outcome);
  }

  // ── Restore ──────────────────────────────────────────────────────────────

  Future<void> restorePurchases() async {
    if (_restoring) return;
    if (!isSupportedPlatform) {
      errorMessage.value = 'Subscriptions are not available on this device.';
      return;
    }
    final String userId = _currentUserId() ?? '';
    if (userId.isEmpty) {
      errorMessage.value = 'Sign in to restore purchases.';
      return;
    }
    errorMessage.value = null;
    infoMessage.value = null;
    _restoring = true;
    isRestoring.value = true;
    _restoredOk = 0;
    _restoreError = null;
    try {
      final String? token = await _accountToken(userId);
      await _iapService.restorePurchases(applicationUserName: token);
      _bumpRestoreQuietTimer();
    } catch (error) {
      errorMessage.value = _friendly(error);
      _endRestore();
    }
  }

  /// Restored items arrive on the purchase stream; finish once it has been
  /// quiet for [_restoreQuietPeriod].
  void _bumpRestoreQuietTimer() {
    _restoreQuietTimer?.cancel();
    _restoreQuietTimer = Timer(_restoreQuietPeriod, () async {
      await _safeRefreshStatus();
      if (_restoredOk > 0) {
        errorMessage.value = null;
        infoMessage.value = 'Your purchases have been restored.';
      } else if (_restoreError != null) {
        errorMessage.value = _restoreError;
      } else if (infoMessage.value == null) {
        infoMessage.value = 'No purchases to restore.';
      }
      _endRestore();
    });
  }

  void _endRestore() {
    _restoreQuietTimer?.cancel();
    _restoreQuietTimer = null;
    _restoring = false;
    isRestoring.value = false;
  }

  /// User-facing text for an error. Never shows a raw platform exception or
  /// native stack trace (e.g. StoreKit's `PlatformException(unknown,
  /// StoreKitError, Stacktrace: …)` when the Apple ID is already subscribed).
  @visibleForTesting
  static String friendlyError(Object error) => _friendly(error);

  static String _friendly(Object error) {
    if (error is PlatformException) {
      final String code = error.code.toLowerCase();
      if (code.contains('cancel')) return 'Purchase cancelled.';
      if (code.contains('network')) {
        return 'Couldn\'t reach the App Store. Check your connection and try again.';
      }
      return 'The store couldn\'t complete the purchase. If you\'re already '
          'subscribed with this Apple ID / Google account, tap Restore Purchases.';
    }
    final String text = error.toString();
    return text
        .replaceFirst('Exception: ', '')
        .replaceFirst('Bad state: ', '')
        .replaceFirst('Invalid argument(s): ', '');
  }

  @override
  void onClose() {
    if (_observeLifecycle) WidgetsBinding.instance.removeObserver(this);
    _restoreQuietTimer?.cancel();
    for (final StreamSubscription<Object?> sub in _subs) {
      sub.cancel();
    }
    _iapService.dispose();
    super.onClose();
  }
}
