import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/subscription/plans_controller.dart';
import 'package:loci/presentation/pages/subscription/widget/billing_toggle.dart';
import 'package:loci/presentation/pages/subscription/widget/plan_list.dart';
import 'package:loci/presentation/pages/subscription/widget/subscription_shimmer.dart';
import 'package:loci/presentation/widgets/app_skeleton.dart';
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

  final controller = Get.find<PlansController>();

  @override
  void initState() {
    super.initState();
    controller.fetchPlans(BillingType.monthly);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Subscription Plan"),
      body: GetBuilder<PlansController>(
        builder: (ctrl) {
          if (ctrl.isLoading) {
            return const SubscriptionShimmer();
          }
          if(ctrl.errorMessage!=null){
            return Center(child: Text(ctrl.errorMessage!));
          }



          return Column(
            children: [
              const SizedBox(height: 20),

              BillingToggleSection(
                isMonthly: _isMonthly,
                onChanged: (value) {
                  setState(() => _isMonthly = value);

                  ctrl.fetchPlans(
                    value ? BillingType.monthly : BillingType.oneTime,
                  );
                },
              ),

              const SizedBox(height: 10),

              Expanded(
                child: PlansList(
                  plans: ctrl.plans,
                  isMonthly: _isMonthly,
                  expandedIndex: _expandedIndex,
                  onExpand: (index) {
                    setState(() {
                      _expandedIndex = _expandedIndex == index ? null : index;
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}