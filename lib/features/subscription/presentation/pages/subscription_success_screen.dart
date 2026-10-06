import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_success_view.dart';

class SubscriptionSuccessScreen extends GetView<SubscriptionController> {
  const SubscriptionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SubscriptionSuccessView(
        controller: controller,
        onBackToPlans: Get.back,
      ),
    );
  }
}
