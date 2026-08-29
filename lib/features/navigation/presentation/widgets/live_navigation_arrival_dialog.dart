import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';

/// Modern Confirmation Dialog displayed upon reaching destination
class LiveNavigationArrivalDialog {
  LiveNavigationArrivalDialog._();

  static void show({
    required String title,
    String? locationLabel,
    VoidCallback? onDone,
  }) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
        elevation: 16,
        backgroundColor: Get.context?.theme.colorScheme.surface ?? Colors.white,
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 36.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'You Have Arrived!',
                style: AppTextStyle.textXl(
                  weight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'You have successfully reached $title.',
                textAlign: TextAlign.center,
                style: AppTextStyle.textSm(
                  color: Get.context?.theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  weight: FontWeight.w400,
                ),
              ),
              if (locationLabel != null && locationLabel.trim().isNotEmpty) ...[
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    locationLabel.trim(),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.textXs(
                      color: const Color(0xFF10B981),
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 22.h),
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: ElevatedButton(
                  onPressed: () {
                    Get.back();
                    onDone?.call();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Done',
                    style: AppTextStyle.textMd(
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
