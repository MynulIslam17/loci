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
}
