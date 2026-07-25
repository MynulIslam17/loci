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

  static const double _itemHeight = 48;

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
        // One solid highlight pill that slides between the two segments, so
        // there is always exactly one clean highlight — no cross-fade blend
        // between the outgoing/incoming tab while switching.
        child: LayoutBuilder(
          builder: (context, constraints) {
            final pillWidth = constraints.maxWidth / 2;

            return SizedBox(
              height: _itemHeight,
              width: constraints.maxWidth,
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    left: isMonthly ? 0 : pillWidth,
                    top: 0,
                    bottom: 0,
                    width: pillWidth,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
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
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
