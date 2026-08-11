import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/checkin/presentation/controllers/check_in_controller.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

/// Tab for manual check-in code entry in Check-In feature.
class CheckInManualTab extends StatelessWidget {
  const CheckInManualTab({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckInController>();
    final colorScheme = context.colorScheme;

    return Form(
      key: controller.formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 32,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.keyboard_alt_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Enter check-in code',
              style: AppTextStyle.textLg(
                color: colorScheme.onSurface,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Type the code shown at the venue if you can\'t scan the QR.',
              textAlign: TextAlign.center,
              style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            CustomTextField(
              controller: controller.manualCodeController,
              title: 'Check-In Code',
              hintText: controller.manualCodeHint,
              borderRadius: 12,
              textCapitalization: TextCapitalization.characters,
              prefixIcon: Icon(
                Icons.confirmation_number_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                  ? 'Please enter the check-in code'
                  : null,
            ),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Check in',
                  isLoading: controller.isManualLoading.value,
                  onPressed: controller.isManualLoading.value
                      ? null
                      : controller.onManualCheckIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
