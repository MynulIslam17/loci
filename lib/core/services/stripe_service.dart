import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

import '../constants/app_url.dart';
import '../network/network_caller.dart';

/// Initializes the Stripe SDK by fetching the publishable key from the backend
/// (`GET /subscriptions/config`, public) and applying it once at app startup.
///
/// The publishable key differs between test and live mode, so it must never be
/// hard-coded — it always comes from the server (see PAYMENTS.md §3, STEP 1).
class StripeService extends GetxService {
  final NetworkCaller _network = Get.find<NetworkCaller>();
  final Logger _logger = Logger();

  bool isReady = false;

  Future<void> init() async {
    try {
      final response = await _network.getRequest(url: AppUrl.subscriptionConfig);

      final key = response.body?['data']?['publishableKey'] as String?;
      if (response.isSuccess && key != null && key.isNotEmpty) {
        Stripe.publishableKey = key;
        await Stripe.instance.applySettings();
        isReady = true;
        _logger.i('Stripe initialized.');
      } else {
        _logger.w('Stripe config missing publishableKey: ${response.errorMessage}');
      }
    } catch (e) {
      // Non-fatal: checkout will surface a clear error if the key never loaded.
      _logger.e('Stripe init failed: $e');
    }
  }

  /// Builds a PaymentSheet appearance that matches the app's current theme.
  ///
  /// Without this, Stripe's native sheet — and the "cancel without paying"
  /// confirmation it shows — fall back to a default light styling that
  /// clashes with our theme (most obvious in dark mode). Colours are pulled
  /// from the live [ColorScheme] so it always tracks the active theme.
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
        // Same colours for both so Stripe's own light/dark detection can't
        // diverge from our theme.
        colors: PaymentSheetPrimaryButtonTheme(
          light: primaryButtonColors,
          dark: primaryButtonColors,
        ),
      ),
    );
  }
}
