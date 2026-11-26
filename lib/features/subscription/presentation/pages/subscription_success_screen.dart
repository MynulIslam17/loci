import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_success_view.dart';
import 'package:loci/routes/app_routes.dart';

class SubscriptionSuccessScreen extends GetView<SubscriptionController> {
  const SubscriptionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SubscriptionSuccessView(
        controller: controller,
        // Plans screen is underneath; replace it with the live status.
        onBackToPlans: () => Get.offNamed<void>(AppRoutes.mySubscription),
      ),
    );
  }
}
