import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/subscription/plans_controller.dart';
import 'package:loci/presentation/controllers/subscription/subscription_controller.dart';
import 'package:loci/presentation/pages/subscription/widget/billing_toggle.dart';
import 'package:loci/presentation/pages/subscription/widget/payment_processing_overlay.dart';
import 'package:loci/presentation/pages/subscription/widget/plan_list.dart';
import 'package:loci/presentation/pages/subscription/widget/subscription_shimmer.dart';
import 'package:loci/presentation/pages/subscription/widget/subscription_status_banner.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import '../../../core/enums/billing_type_enum.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isMonthly = true;
  int? _expandedIndex;

  final plansController = Get.find<PlansController>();
  final subscriptionController = Get.find<SubscriptionController>();

  @override
  void initState() {
    super.initState();
    plansController.fetchPlans(BillingType.monthly);
    subscriptionController.fetchMySubscription();
    subscriptionController.initializeStripe();
  }

  Future<void> _confirmCancel() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Cancel subscription?'),
        content: const Text(
          'Monthly plans stay active until the end of the billing period.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Keep plan'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Cancel plan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await subscriptionController.cancelSubscription();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Subscription Plan"),
      body: GetBuilder<SubscriptionController>(
        builder: (subCtrl) {
          return Stack(
            children: [
              Column(
                children: [
                  SubscriptionStatusBanner(
                    subscription: subCtrl.mySubscription,
                    isLoading: subCtrl.isLoadingSubscription,
                    isCancelling: subCtrl.isCancelling,
                    onCancel: subCtrl.hasActiveSubscription
                        ? _confirmCancel
                        : null,
                  ),
                  const SizedBox(height: 12),
                  BillingToggleSection(
                    isMonthly: _isMonthly,
                    onChanged: (value) {
                      if (value == _isMonthly) return;
                      setState(() => _isMonthly = value);
                      plansController.fetchPlans(
                        value ? BillingType.monthly : BillingType.oneTime,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: GetBuilder<PlansController>(
                      builder: (ctrl) => _buildPlansBody(ctrl, subCtrl),
                    ),
                  ),
                ],
              ),
              if (subCtrl.isProcessingPurchase)
                const PaymentProcessingOverlay(
                  message: 'Confirming your subscription...',
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPlansBody(
    PlansController ctrl,
    SubscriptionController subCtrl,
  ) {
    return RefreshIndicator(
      onRefresh: () async {
        await plansController.refreshPlans(
          _isMonthly ? BillingType.monthly : BillingType.oneTime,
        );
        await subscriptionController.fetchMySubscription();
      },
      child: _plansContent(ctrl, subCtrl),
    );
  }

  Widget _plansContent(
    PlansController ctrl,
    SubscriptionController subCtrl,
  ) {
    if (ctrl.isLoading) {
      return const SubscriptionShimmer();
    }
    if (ctrl.errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Center(child: Text(ctrl.errorMessage!)),
        ],
      );
    }
    return PlansList(
      plans: ctrl.plans,
      isMonthly: _isMonthly,
      expandedIndex: _expandedIndex,
      isProcessing: subCtrl.isProcessingPurchase,
      onExpand: (index) {
        setState(() {
          _expandedIndex = _expandedIndex == index ? null : index;
        });
      },
      onSubscribe: (plan) => subscriptionController.subscribeToPlan(plan),
    );
  }
}
