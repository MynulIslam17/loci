import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
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
import 'package:loci/features/subscription/presentation/subscription_messages.dart';

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

  /// The store accepted a plan change that starts at the next renewal
  /// (e.g. an App Store downgrade/crossgrade). The current plan stays active
  /// until then; nothing new is unlocked now.
  scheduled,
}

/// Result of Restore Purchases, for the UI to explain.
enum RestoreOutcome {
  /// At least one purchase was verified by the backend.
  restored,

  /// The store returned nothing for this Apple ID / Google account.
  nothing,

  /// A purchase was found but the backend says it's no longer active (or it
  /// belongs to another Loci account) — see [SubscriptionController.errorMessage].
  inactive,

  /// Found, but activation is still pending / will be retried.
  pending,

  /// The restore itself failed (store / network) — see errorMessage.
  failed,
}

/// Copy for a plan change the store applies at the next renewal. Pure for
/// testing.
String scheduledSwitchMessage({
  required String newPlan,
  required String currentPlan,
  DateTime? startsAt,
  DateFormat? format,
}) {
  final String when = startsAt == null
      ? 'when your current billing period ends'
      : 'on ${(format ?? DateFormat('MMM d, yyyy')).format(startsAt.toLocal())}';
  return 'Your switch to $newPlan is scheduled. You keep $currentPlan until '
      'it renews $when, then $newPlan starts.';
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
    DateTime Function()? clock,
    QueueStore? switchStore,
  }) : _serviceOverride = service,
       _switchStore = switchStore ?? SecureQueueStore(),
       _now = clock ?? DateTime.now,
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
  final DateTime Function() _now;
  final QueueStore _switchStore;
  bool _recovering = false;

  static const String _switchKey = 'loci.iap.scheduled_switch.v1';

  SubscriptionService get _service =>
      _serviceOverride ?? Get.find<SubscriptionService>();

  static StorePlatform? _detectPlatform() {
    if (Platform.isIOS) return StorePlatform.apple;
    if (Platform.isAndroid) return StorePlatform.google;
    return null;
  }

  late final IapService _iapService;
  final List<StreamSubscription<Object?>> _subs =
      <StreamSubscription<Object?>>[];

  Completer<PurchaseOutcome>? _purchaseResult;
  String? _pendingProductId;
  bool _processingQueue = false;

  /// One in-flight verify per transaction: an app-resume queue retry must not
  /// send the same purchase again while the first request is still open.
  final Map<String, Future<VerifyResult>> _inFlightVerify =
      <String, Future<VerifyResult>>{};

  /// When the current store purchase began (to recognise the store handing
  /// back an existing transaction for a scheduled plan change).
  DateTime? _purchaseStartedAt;

  // Restore bookkeeping.
  bool _restoring = false;
  int _restoredOk = 0;

  /// Restored transactions still waiting for the backend's answer. Restore
  /// can't conclude "nothing to restore" while any are in flight.
  int _restoreInFlight = 0;
  String? _restoreError;
  Timer? _restoreQuietTimer;

  final Rxn<ProductDetails> monthlyProduct = Rxn<ProductDetails>();
  final Rxn<ProductDetails> yearlyProduct = Rxn<ProductDetails>();
  final RxBool isLoading = true.obs;
  final RxBool isPurchasing = false.obs;
  final RxBool isRestoring = false.obs;

  /// Store reported the payment as pending ("Waiting for approval…").
  final RxBool isAwaitingApproval = false.obs;

  /// Product the store has already scheduled as the next plan. Kept on the
  /// device (per account, until the current period ends) so a relaunch still
  /// shows "Switch scheduled". Buying it again is blocked until it starts.
  final RxnString scheduledSwitchProductId = RxnString();

  bool isSwitchScheduled(String? productId) =>
      productId != null && scheduledSwitchProductId.value == productId;
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
    unawaited(_loadScheduledSwitch());
    if (_observeLifecycle) WidgetsBinding.instance.addObserver(this);

    final Stream<Object?>? session = _sessionChanges;
    if (session != null) {
      _subs.add(
        session.listen((_) {
          scheduledSwitchProductId.value = null;
          unawaited(_loadScheduledSwitch());
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

  void selectPlan(StoreSubscriptionPlan plan) {
    selectedPlan.value = plan;
    clearMessages();
  }

  /// Drops feedback from an earlier action (e.g. a finished restore) so it
  /// isn't shown on the next screen.
  void clearMessages() {
    if (isPurchasing.value || _restoring) return;
    errorMessage.value = null;
    infoMessage.value = null;
  }

  Future<PurchaseOutcome> subscribe() async {
    final StoreSubscriptionPlan? plan = selectedPlan.value;
    if (plan == null || !plan.isPaid) return PurchaseOutcome.failed;
    return purchase(plan.productId!);
  }

  Future<void> initialize() async {
    if (!isSupportedPlatform) {
      isLoading.value = false;
      errorMessage.value = SubscriptionMessages.storeUnavailable;
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = null;
      await _iapService.initialize();
      if (!_iapService.isAvailable) {
        errorMessage.value = SubscriptionMessages.storeUnavailable;
      }
      _updateProducts();
    } catch (error) {
      logSubscriptionError('initialize', error);
      errorMessage.value = friendlySubscriptionError(
        error,
        fallback: SubscriptionMessages.plansUnavailable,
      );
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
        message: SubscriptionMessages.purchaseUnverified,
      );
    }

    if (kDebugMode) {
      debugPrint(
        '[subscription] store ${purchase.status.name}: '
        '${describeAppleTransaction(purchase.verificationData.serverVerificationData) ?? purchase.productID}',
      );
    }

    // Survive crash / restart between purchase and verify.
    await _queue.save(userId, body);
    final VerifyResult result = await _verifyBody(userId, body);
    if (kDebugMode) {
      debugPrint('[subscription] verify → ${result.kind.name}');
    }
    if (result.kind != VerifyResultKind.success) {
      logSubscriptionError('verify ${result.kind.name}', result.message);
    }
    return IapVerificationResult(
      _toIapVerification(result.kind),
      // Backend text is shown only when it's written for users; JWS /
      // certificate validation details go to the log.
      message: result.kind == VerifyResultKind.invalid
          ? userFacingOr(
              result.message,
              purchase.status == PurchaseStatus.restored
                  ? SubscriptionMessages.restoredInactive
                  : SubscriptionMessages.purchaseUnverified,
            )
          : null,
    );
  }

  /// Sends one body and updates the queue per spec §5. Refreshes status after
  /// a `200` (before the caller shows any success UI).
  Future<VerifyResult> _verifyBody(String userId, Map<String, dynamic> body) {
    final String key = '$userId|${verifyBodyKey(body)}';
    return _inFlightVerify[key] ??= _sendVerify(userId, body).whenComplete(() {
      // Block body: returning the removed future would make whenComplete
      // wait on itself.
      _inFlightVerify.remove(key);
    });
  }

  Future<VerifyResult> _sendVerify(
    String userId,
    Map<String, dynamic> body,
  ) async {
    VerifyResult result;
    try {
      result = await _service.verifyPurchase(body);
    } catch (error) {
      logSubscriptionError('verify request', error);
      result = const VerifyResult(VerifyResultKind.retryable);
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
        logSubscriptionError('products', event.message);
        errorMessage.value = event.products.isEmpty
            ? SubscriptionMessages.plansUnavailable
            : null;
      case IapEventType.purchasePending:
        if (_isCurrent(event.productId)) {
          isAwaitingApproval.value = true;
          infoMessage.value = 'Waiting for approval…';
        }
      case IapEventType.verificationStarted:
        if (_restoring) {
          _restoreInFlight++;
          _restoreQuietTimer?.cancel();
        }
      case IapEventType.purchaseCompleted:
      case IapEventType.purchaseRestored:
        _restoreVerificationDone();
        if (_restoring) _restoredOk++;
        final String? switchMessage = _scheduledSwitchMessageFor(event);
        if (switchMessage != null) {
          infoMessage.value = switchMessage;
          _rememberScheduledSwitch(_pendingProductId, _expiresOf(event));
          _finishPurchase(PurchaseOutcome.scheduled);
        } else {
          _finishPurchase(PurchaseOutcome.success, productId: event.productId);
        }
        if (_restoring) _bumpRestoreQuietTimer();
      case IapEventType.verificationPending:
        _restoreVerificationDone();
        _setInfoIfCurrent(
          event.productId,
          'Your payment is pending. We\'ll activate your plan as soon as it completes.',
        );
        _finishPurchase(PurchaseOutcome.pending, productId: event.productId);
        if (_restoring) _bumpRestoreQuietTimer();
      case IapEventType.verificationDeferred:
        _restoreVerificationDone();
        final bool existingReply = _isExistingSubscriptionReply(event);
        if (existingReply) {
          infoMessage.value = 'We\'ll finish activating your plan shortly.';
        } else {
          _setInfoIfCurrent(
            event.productId,
            'We\'ll finish activating your plan shortly.',
          );
        }
        _finishPurchase(
          PurchaseOutcome.deferred,
          productId: existingReply ? null : event.productId,
        );
        if (_restoring) _bumpRestoreQuietTimer();
      case IapEventType.verificationFailed:
        _restoreVerificationDone();
        final bool existingReply = _isExistingSubscriptionReply(event);
        String message =
            event.message ?? SubscriptionMessages.purchaseUnverified;
        if (existingReply &&
            RegExp(
              r'(another|different).*account',
              caseSensitive: false,
            ).hasMatch(message)) {
          message = SubscriptionMessages.storeAccountUsedElsewhere(
            isIOS: _platform == StorePlatform.apple,
          );
        }
        if (_restoring) {
          _restoreError = message;
          _bumpRestoreQuietTimer();
        }
        if (_isCurrent(event.productId) || _restoring || existingReply) {
          errorMessage.value = message;
        }
        _finishPurchase(
          PurchaseOutcome.failed,
          productId: existingReply ? null : event.productId,
        );
      case IapEventType.purchaseCanceled:
        _finishPurchase(PurchaseOutcome.cancelled, productId: event.productId);
      case IapEventType.purchaseFailed:
        logSubscriptionError('purchase failed', event.error ?? event.message);
        if (_isCurrent(event.productId)) {
          errorMessage.value = friendlySubscriptionError(
            event.error,
            fallback: SubscriptionMessages.storeFailed,
          );
        }
        _finishPurchase(PurchaseOutcome.failed, productId: event.productId);
      case IapEventType.error:
        // Internal store problems (e.g. finishing an already-verified
        // transaction) are retried by the store; the verification outcome
        // event that follows decides what the user sees. Never fail a
        // purchase or show raw text here.
        logSubscriptionError('store', event.error ?? event.message);
      case IapEventType.storeUnavailable:
        errorMessage.value = SubscriptionMessages.storeUnavailable;
      case IapEventType.restoreFinished:
        if (_restoring) _bumpRestoreQuietTimer();
      default:
        break;
    }
  }

  /// While buying plan B, the App Store may answer with the *existing*
  /// plan-A transaction: the change is scheduled for the next renewal
  /// (downgrade / crossgrade in the subscription group). Recognised by a
  /// verified, same-group, different-product transaction that was purchased
  /// before this purchase started. Returns the copy to show, else null.
  String? _scheduledSwitchMessageFor(IapEvent event) {
    final String? pending = _pendingProductId;
    if (event.type != IapEventType.purchaseCompleted ||
        pending == null ||
        !_isExistingSubscriptionReply(event)) {
      return null;
    }
    final Map<String, dynamic>? payload = jwsPayload(
      event.purchase!.verificationData.serverVerificationData,
    );
    final int? expiresMs = (payload?['expiresDate'] as num?)?.toInt();
    return scheduledSwitchMessage(
      newPlan: _planName(pending),
      currentPlan: _planName(event.productId),
      startsAt: expiresMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(expiresMs, isUtc: true),
    );
  }

  /// True when the store answered the purchase in progress with the
  /// subscription this store account ALREADY has (another product of the
  /// same group, bought before this purchase started) — StoreKit 2 does this
  /// for "You're currently subscribed" and for scheduled plan changes.
  /// Whatever the backend says about that transaction is the answer to the
  /// current purchase; waiting for the requested product would only time out.
  bool _isExistingSubscriptionReply(IapEvent event) {
    final String? pending = _pendingProductId;
    final PurchaseDetails? purchase = event.purchase;
    final DateTime? startedAt = _purchaseStartedAt;
    if (pending == null ||
        purchase == null ||
        startedAt == null ||
        event.productId == pending ||
        !LociIapProducts.all.contains(event.productId)) {
      return false;
    }
    final Map<String, dynamic>? payload = jwsPayload(
      purchase.verificationData.serverVerificationData,
    );
    final int? purchasedMs =
        (payload?['purchaseDate'] as num?)?.toInt() ??
        int.tryParse(purchase.transactionDate ?? '');
    // A transaction created after the purchase started is genuinely new
    // (e.g. a renewal), not the store's reply.
    return purchasedMs != null &&
        DateTime.fromMillisecondsSinceEpoch(
          purchasedMs,
        ).isBefore(startedAt.subtract(const Duration(seconds: 5)));
  }

  static DateTime? _expiresOf(IapEvent event) {
    final Map<String, dynamic>? payload = jwsPayload(
      event.purchase?.verificationData.serverVerificationData ?? '',
    );
    final int? ms = (payload?['expiresDate'] as num?)?.toInt();
    return ms == null ? null : DateTime.fromMillisecondsSinceEpoch(ms);
  }

  void _rememberScheduledSwitch(String? productId, DateTime? until) {
    scheduledSwitchProductId.value = productId;
    final String? user = _currentUserId();
    if (productId == null || user == null) return;
    // Without an expiry, fall back to the longest monthly period.
    final DateTime end = until ?? _now().add(const Duration(days: 31));
    unawaited(
      _switchStore
          .write(
            _switchKey,
            jsonEncode(<String, Object>{
              'user': user,
              'product': productId,
              'until': end.toUtc().toIso8601String(),
            }),
          )
          .catchError((Object e) => logSubscriptionError('save switch', e)),
    );
  }

  /// Restores a store-scheduled plan change for the signed-in account; a
  /// record for another account or a past period is dropped.
  Future<void> _loadScheduledSwitch() async {
    try {
      final String? raw = await _switchStore.read(_switchKey);
      if (raw == null) return;
      final Object? json = jsonDecode(raw);
      final String? user = _currentUserId();
      if (json is! Map || user == null || json['user'] != user) return;
      final DateTime? until = DateTime.tryParse('${json['until']}');
      final Object? product = json['product'];
      if (until == null || !until.isAfter(_now()) || product is! String) {
        await _switchStore.delete(_switchKey);
        return;
      }
      scheduledSwitchProductId.value ??= product;
    } catch (e) {
      logSubscriptionError('load switch', e);
    }
  }

  static String _planName(String? productId) {
    for (final StoreSubscriptionPlan plan in StoreSubscriptionPlan.catalog) {
      if (plan.productId == productId) return plan.name;
    }
    return 'your new plan';
  }

  bool _isCurrent(String? productId) =>
      _pendingProductId != null && productId == _pendingProductId;

  void _setInfoIfCurrent(String? productId, String message) {
    if (_isCurrent(productId) || _restoring) infoMessage.value = message;
  }

  // ── Purchase ─────────────────────────────────────────────────────────────

  Future<PurchaseOutcome> purchase(String productId) async {
    if (!isSupportedPlatform) {
      errorMessage.value = SubscriptionMessages.storeUnavailable;
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
    _purchaseStartedAt = _now();

    try {
      final String? token = await _accountToken(userId);
      final bool started = await _iapService.purchase(
        productId,
        applicationUserName: token,
      );
      if (!started) _finishPurchase(PurchaseOutcome.failed);
    } catch (error) {
      logSubscriptionError('purchase', error);
      errorMessage.value = friendlySubscriptionError(
        error,
        fallback: SubscriptionMessages.storeFailed,
      );
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

  Completer<RestoreOutcome>? _restoreResult;

  /// Restores store purchases and completes once the backend has answered
  /// for every restored transaction.
  Future<RestoreOutcome> restorePurchases() async {
    if (_restoring) {
      return _restoreResult?.future ?? Future.value(RestoreOutcome.failed);
    }
    if (!isSupportedPlatform) {
      errorMessage.value = SubscriptionMessages.storeUnavailable;
      return RestoreOutcome.failed;
    }
    final String userId = _currentUserId() ?? '';
    if (userId.isEmpty) {
      errorMessage.value = 'Sign in to restore purchases.';
      return RestoreOutcome.failed;
    }
    final Completer<RestoreOutcome> result = Completer<RestoreOutcome>();
    _restoreResult = result;
    errorMessage.value = null;
    infoMessage.value = null;
    _restoring = true;
    isRestoring.value = true;
    _restoredOk = 0;
    _restoreInFlight = 0;
    _restoreError = null;
    try {
      final String? token = await _accountToken(userId);
      await _iapService.restorePurchases(applicationUserName: token);
      _bumpRestoreQuietTimer();
    } catch (error) {
      logSubscriptionError('restore', error);
      errorMessage.value = friendlySubscriptionError(
        error,
        fallback: SubscriptionMessages.restoreFailed,
      );
      _endRestore(RestoreOutcome.failed);
    }
    return result.future;
  }

  /// Restored items arrive on the purchase stream; finish once it has been
  /// quiet for [_restoreQuietPeriod].
  void _bumpRestoreQuietTimer() {
    _restoreQuietTimer?.cancel();
    _restoreQuietTimer = Timer(_restoreQuietPeriod, () async {
      // Still waiting on the backend for a restored transaction; its outcome
      // event re-arms this timer.
      if (_restoreInFlight > 0) return;
      await _safeRefreshStatus();
      final RestoreOutcome outcome;
      if (_restoredOk > 0) {
        errorMessage.value = null;
        infoMessage.value = 'Your purchases have been restored.';
        outcome = RestoreOutcome.restored;
      } else if (_restoreError != null) {
        errorMessage.value = _restoreError;
        outcome = RestoreOutcome.inactive;
      } else if (infoMessage.value == null) {
        infoMessage.value = 'No purchases to restore.';
        outcome = RestoreOutcome.nothing;
      } else {
        // Pending / deferred activation message already set.
        outcome = RestoreOutcome.pending;
      }
      _endRestore(outcome);
    });
  }

  void _restoreVerificationDone() {
    if (_restoreInFlight > 0) _restoreInFlight--;
  }

  void _endRestore(RestoreOutcome outcome) {
    _restoreQuietTimer?.cancel();
    _restoreQuietTimer = null;
    _restoring = false;
    isRestoring.value = false;
    final Completer<RestoreOutcome>? result = _restoreResult;
    _restoreResult = null;
    if (result != null && !result.isCompleted) result.complete(outcome);
  }

  // ── Plans retry ──────────────────────────────────────────────────────────

  /// No store product loaded (offline, store hiccup) — the plans screen
  /// offers "Try again".
  bool get plansUnavailable =>
      monthlyProduct.value == null && yearlyProduct.value == null;

  Future<void> retryLoadingPlans() async {
    if (isLoading.value || !isSupportedPlatform) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      await _iapService.initialize();
      if (!_iapService.isAvailable) {
        errorMessage.value = SubscriptionMessages.storeUnavailable;
        return;
      }
      if (plansUnavailable) await _iapService.reloadProducts();
      _updateProducts();
      errorMessage.value = plansUnavailable
          ? SubscriptionMessages.plansUnavailable
          : null;
    } catch (error) {
      logSubscriptionError('reload plans', error);
      errorMessage.value = friendlySubscriptionError(
        error,
        fallback: SubscriptionMessages.plansUnavailable,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// User-facing text for an error. Never shows a raw platform exception or
  /// native stack trace (e.g. StoreKit's `PlatformException(unknown,
  /// StoreKitError, Stacktrace: …)` when the Apple ID is already subscribed).
  @visibleForTesting
  static String friendlyError(Object error) => _friendly(error);

  static String _friendly(Object error) => friendlySubscriptionError(
    error,
    fallback: SubscriptionMessages.storeFailed,
  );

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
