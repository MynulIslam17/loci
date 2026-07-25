import 'package:flutter/material.dart';
import 'package:loci/features/subscription/data/models/plan_response_model.dart';
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
    // A plain box column: it lives inside a SliverToBoxAdapter and the list is
    // short, so lazy sliver building isn't needed.
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (var index = 0; index < plans.length; index++)
            PlanCard(
              plan: plans[index],
              isMonthly: isMonthly,
              isExpanded: expandedIndex == index,
              onTap: () => onExpand(index),
            ),
        ],
      ),
    );
  }
}
