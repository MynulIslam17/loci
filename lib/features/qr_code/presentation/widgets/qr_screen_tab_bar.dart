import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

enum QrScreenTab { scan, myQr }

class QrScreenTabBar extends StatelessWidget {
  const QrScreenTabBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final QrScreenTab selected;
  final ValueChanged<QrScreenTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          _tabItem(
            context,
            tab: QrScreenTab.scan,
            label: 'Scan QR',
            icon: Icons.qr_code_scanner_rounded,
          ),
          _tabItem(
            context,
            tab: QrScreenTab.myQr,
            label: 'My QR',
            icon: Icons.qr_code_2_rounded,
          ),
        ],
      ),
    );
  }

  Widget _tabItem(
    BuildContext context, {
    required QrScreenTab tab,
    required String label,
    required IconData icon,
  }) {
    final colorScheme = context.colorScheme;
    final isSelected = selected == tab;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(tab),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyle.textSm(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  weight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
