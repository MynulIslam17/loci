import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'toggle_item.dart';

class BillingToggleSection extends StatelessWidget {
  final bool isMonthly;
  final Function(bool) onChanged;

  const BillingToggleSection({
    super.key,
    required this.isMonthly,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            ToggleItem(
              title: "Monthly",
              isSelected: isMonthly,
              onTap: () => onChanged(true),
            ),
            ToggleItem(
              title: "Billed One-time",
              isSelected: !isMonthly,
              onTap: () => onChanged(false),
            ),
          ],
        ),
      ),
    );
  }
}