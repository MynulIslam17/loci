import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:loci/features/subscription/data/models/my_subscription_model.dart';
import 'package:loci/features/subscription/domain/services/subscription_service.dart';
import 'package:loci/features/subscription/presentation/subscription_messages.dart';

/// App-wide, server-authoritative subscription state
/// (`GET /subscriptions/my`). The single place the UI reads entitlement from.
///
/// Refreshed on login/launch, app resume, after verify/restore and after
/// returning from the store's management page (that is a resume too).
/// A network error never downgrades to "free": the last known status is kept.
class SubscriptionStatusController extends GetxController
    with WidgetsBindingObserver {
  SubscriptionStatusController(
    this._service, {
    required bool Function() canAccess,
    Stream<Object?>? sessionChanges,
    bool observeLifecycle = true,
  }) : _canAccess = canAccess,
       _sessionChanges = sessionChanges,
       _observeLifecycle = observeLifecycle;

  final SubscriptionService _service;

  /// True when the signed-in user may own a subscription (business owner /
  /// admin). Members never call the endpoint.
  final bool Function() _canAccess;
  final Stream<Object?>? _sessionChanges;
  final bool _observeLifecycle;

  final Rxn<MySubscriptionModel> subscription = Rxn<MySubscriptionModel>();

  /// A definitive server answer (200) has been received at least once.
  final RxBool hasLoaded = false.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();

  /// The user owns no business, so there is nothing to subscribe for yet.
  final RxBool hasNoBusiness = false.obs;

  String? _businessId;
  Future<void>? _inFlight;
  StreamSubscription<Object?>? _sessionSub;

  String? get businessId => _businessId;

  /// `200` with `data: null` → free plan.
  bool get isFree => hasLoaded.value && subscription.value == null;

  /// UX pre-check only — the server stays the authority (§8).
  bool get canCreatePaidContent => subscription.value != null;
  bool get canSubmitSpotlight =>
      (subscription.value?.remainingCredits ?? 0) >= spotlightCost;

  static const int spotlightCost = 10;

  @override
  void onInit() {
    super.onInit();
    if (_observeLifecycle) WidgetsBinding.instance.addObserver(this);
    _sessionSub = _sessionChanges?.listen((_) {
      // New session (login / account switch / logout): never show the previous
      // user's plan.
      clear();
      unawaited(reload());
    });
    unawaited(reload());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(reload());
  }

  @override
  void onClose() {
    if (_observeLifecycle) WidgetsBinding.instance.removeObserver(this);
    _sessionSub?.cancel();
    super.onClose();
  }

  /// Clears cached status (logout / account switch).
  void clear() {
    subscription.value = null;
    hasLoaded.value = false;
    hasNoBusiness.value = false;
    errorMessage.value = null;
    _businessId = null;
  }

  /// Fetches the owner's subscription. Concurrent calls share one request.
  Future<void> reload() {
    if (!_canAccess()) return Future<void>.value();
    return _inFlight ??= _reload().whenComplete(() => _inFlight = null);
  }

  Future<void> _reload() async {
    isLoading.value = true;
    try {
      final String? businessId = await _resolveBusinessId();
      if (businessId == null) {
        hasNoBusiness.value = true;
        subscription.value = null;
        hasLoaded.value = true;
        errorMessage.value = null;
        return;
      }
      hasNoBusiness.value = false;
      final MySubscriptionModel? result = await _service.getMySubscription(
        businessId,
      );
      subscription.value = result;
      hasLoaded.value = true;
      errorMessage.value = null;
    } catch (e) {
      // Network error ≠ free plan: keep the last known status.
      logSubscriptionError('status', e);
      errorMessage.value = friendlySubscriptionError(
        e,
        fallback: SubscriptionMessages.statusUnavailable,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Subscription is owner-level, so any owned business works as the
  /// `businessId` query parameter.
  Future<String?> _resolveBusinessId() async {
    if (_businessId != null && _businessId!.isNotEmpty) return _businessId;
    final businesses = await _service.getMyBusinesses();
    if (businesses.isEmpty) return null;
    _businessId = businesses.first.id;
    return _businessId;
  }
}
