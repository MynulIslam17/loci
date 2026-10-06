import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/subscription/presentation/controllers/subscription_controller.dart';
import 'package:loci/features/subscription/presentation/pages/subscription_details_screen.dart';
import 'package:loci/features/subscription/presentation/widgets/subscription_selection_view.dart';
import 'package:loci/shared/widgets/adaptive_progress.dart';

/// First page of the business subscription flow.
class SubscriptionPlanScreen extends GetView<SubscriptionController> {
  const SubscriptionPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        centerTitle: true,
        title: Text(
          'Loci Business',
          style: AppTextStyle.textLg(weight: FontWeight.w800),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: AdaptiveProgress());
        }
        return SubscriptionSelectionView(
          controller: controller,
          onContinue: () {
            Get.to<void>(() => const SubscriptionDetailsScreen());
          },
        );
      }),
    );
  }
}
