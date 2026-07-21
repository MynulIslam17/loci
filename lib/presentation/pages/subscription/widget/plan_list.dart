import 'package:flutter/material.dart';
import 'package:loci/data/models/subscription/plan_response_model.dart';
import 'plan_card.dart';

class PlansList extends StatelessWidget {
  final List<PlanModel> plans;
  final bool isMonthly;
  final int? expandedIndex;
  final bool isProcessing;
  final Function(int) onExpand;
  final void Function(PlanModel plan)? onSubscribe;

  const PlansList({
    super.key,
    required this.plans,
    required this.isMonthly,
    required this.expandedIndex,
    this.isProcessing = false,
    required this.onExpand,
    this.onSubscribe,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];

        return PlanCard(
          plan: plan,
          isMonthly: isMonthly,
          isExpanded: expandedIndex == index,
          isProcessing: isProcessing,
          onTap: () => onExpand(index),
          onSubscribe: onSubscribe == null ? null : () => onSubscribe!(plan),
        );
      },
    );
  }
}