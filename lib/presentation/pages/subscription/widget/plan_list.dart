import 'package:flutter/material.dart';
import 'package:loci/data/models/subscription/plan_response_model.dart';
import 'plan_card.dart';

class PlansList extends StatelessWidget {
  final List<PlanModel> plans;
  final bool isMonthly;
  final int? expandedIndex;
  final Function(int) onExpand;

  const PlansList({
    super.key,
    required this.plans,
    required this.isMonthly,
    required this.expandedIndex,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: plans.length,
      itemBuilder: (context, index) {
        final plan = plans[index];

        return PlanCard(
          plan: plan,
          isMonthly: isMonthly,
          isExpanded: expandedIndex == index,
          onTap: () => onExpand(index),
        );
      },
    );
  }
}