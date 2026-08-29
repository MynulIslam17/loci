import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:loci/core/constants/app_text_style.dart';

/// Travel Mode Selector Pill (Drive 🚗, Ride 🏍️, Walk 🚶)
class LiveNavigationModePill extends StatelessWidget {
  const LiveNavigationModePill({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
    this.activeColor,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colors;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = activeColor ?? colors.primary;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected
                ? effectiveColor.withValues(alpha: 0.12)
                : colors.onSurface.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? effectiveColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? effectiveColor
                    : colors.onSurface.withValues(alpha: 0.6),
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: AppTextStyle.textSm(
                  color: isSelected
                      ? effectiveColor
                      : colors.onSurface.withValues(alpha: 0.7),
                  weight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
