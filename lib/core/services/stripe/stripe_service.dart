import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../../constants/app_url.dart';
import '../../network/network_caller.dart';
import '../../../features/subscription/data/models/checkout_response_model.dart';

/// Owns Stripe SDK setup + PaymentSheet presentation for iOS/Android.
///
/// Real-device / TestFlight requirements this service enforces:
/// - publishable key from backend (never hard-coded)
/// - [urlScheme] registered in Info.plist / AndroidManifest
/// - matching [returnURL] on every PaymentSheet init (Link / 3DS)
/// - present only after the next frame so iOS has a valid presenting VC
class StripeService extends GetxService {
  final NetworkCaller _network = Get.find<NetworkCaller>();
  final Logger _logger = Logger();

  /// Must match CFBundleURLSchemes in ios/Runner/Info.plist and the Android
  /// deep-link intent-filter scheme.
  static const String urlScheme = 'loci';

  /// Must match Info.plist / AndroidManifest host path for redirects.
  static const String returnURL = '$urlScheme://stripe-redirect';

  bool isReady = false;
  Future<void>? _initFuture;
  String? _lastError;

  String? get lastError => _lastError;

  bool get _supportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  /// Fetches `/subscriptions/config` and applies Stripe settings once.
  Future<void> init({String? publishableKeyOverride}) async {
    if (!_supportedPlatform) return;

    if (publishableKeyOverride != null && publishableKeyOverride.isNotEmpty) {
      await _applyKey(publishableKeyOverride);
      return;
    }

    if (isReady) {
      // Re-assert scheme — older in-memory state can lose it after hot restart.
      Stripe.urlScheme = urlScheme;
      return;
    }

    _initFuture ??= _loadFromConfig();
    try {
      await _initFuture;
    } finally {
      if (!isReady) _initFuture = null;
    }
  }

  Future<void> _loadFromConfig() async {
    try {
      final response = await _network.getRequest(url: AppUrl.subscriptionConfig);
      final key = response.body?['data']?['publishableKey'] as String?;
      if (response.isSuccess && key != null && key.isNotEmpty) {
        await _applyKey(key);
        _logger.i('Stripe initialized.');
      } else {
        isReady = false;
        _lastError =
            response.errorMessage ?? 'Payment configuration is unavailable.';
        _logger.w('Stripe config missing publishableKey: $_lastError');
      }
    } catch (e) {
      isReady = false;
      _lastError = e.toString();
      _logger.e('Stripe init failed: $e');
    }
  }

  Future<void> _applyKey(String key) async {
    Stripe.publishableKey = key;
    Stripe.urlScheme = urlScheme;
    // Lets Android use the same return-URL scheme for redirect methods.
    Stripe.setReturnUrlSchemeOnAndroid = true;
    await Stripe.instance.applySettings();
    isReady = true;
    _lastError = null;
  }

  /// Ensures SDK is ready, preferring a key returned by checkout when present.
  Future<bool> ensureReady({String? publishableKey}) async {
    if (!_supportedPlatform) {
      _lastError = 'Payments are only available on iOS and Android.';
      return false;
    }
    await init(publishableKeyOverride: publishableKey);
    return isReady;
  }

  /// Opens Stripe PaymentSheet for a paid checkout payload.
  ///
  /// Throws [StripeException] / [StateError] on failure; callers decide UX.
  Future<void> presentCheckoutSheet(CheckoutModel checkout) async {
    if (!checkout.canPresentSheet) {
      throw StateError(
        'Checkout is missing payment details. Please try again.',
      );
    }

    final ready = await ensureReady(publishableKey: checkout.publishableKey);
    if (!ready) {
      throw StateError(
        _lastError ??
            'Payments are not available right now. Please try again later.',
      );
    }

    // iOS needs a settled UI frame before presenting a native modal from a
    // button that just flipped into a loading state.
    await _waitForPresentableUi();

    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'Loci',
        customerId: checkout.customerId,
        customerEphemeralKeySecret: checkout.ephemeralKey,
        paymentIntentClientSecret: checkout.paymentIntentClientSecret,
        returnURL: returnURL,
        style: ThemeMode.system,
        appearance: themedAppearance(),
        // Card-first on device; delayed methods still allowed if Stripe enables
        // them for the account.
        allowsDelayedPaymentMethods: true,
      ),
    );

    await Stripe.instance.presentPaymentSheet();
  }

  Future<void> _waitForPresentableUi() async {
    final binding = WidgetsBinding.instance;
    // Close any GetX snackbars/dialogs that would steal the presenter.
    if (Get.isSnackbarOpen) {
      await Get.closeCurrentSnackbar();
    }
    await binding.endOfFrame;
    // One short yield helps TestFlight / release builds where the button
    // rebuild lags the present call.
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await SchedulerBinding.instance.endOfFrame;
  }

  PaymentSheetAppearance themedAppearance() {
    final ColorScheme scheme = Get.theme.colorScheme;

    final primaryButtonColors = PaymentSheetPrimaryButtonThemeColors(
      background: scheme.primary,
      text: scheme.onPrimary,
      border: scheme.primary,
    );

    return PaymentSheetAppearance(
      colors: PaymentSheetAppearanceColors(
        primary: scheme.primary,
        background: scheme.surface,
        componentBackground: scheme.surfaceContainerHighest,
        componentBorder: scheme.outline,
        componentDivider: scheme.outlineVariant,
        componentText: scheme.onSurface,
        primaryText: scheme.onSurface,
        secondaryText: scheme.onSurfaceVariant,
        placeholderText: scheme.onSurfaceVariant,
        icon: scheme.onSurfaceVariant,
        error: scheme.error,
      ),
      shapes: const PaymentSheetShape(borderRadius: 12, borderWidth: 1),
      primaryButton: PaymentSheetPrimaryButtonAppearance(
        colors: PaymentSheetPrimaryButtonTheme(
          light: primaryButtonColors,
          dark: primaryButtonColors,
        ),
      ),
    );
  }
}
