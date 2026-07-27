import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/my_business/presentation/controllers/create_ad_controller.dart';
import 'package:loci/features/my_business/presentation/widgets/create_ad_date_time_row.dart';
import 'package:loci/shared/widgets/framed_image_upload_field.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class CreateAdForm extends StatelessWidget {
  const CreateAdForm({
    super.key,
    required this.controller,
    required this.onPickDate,
    required this.onPickTime,
  });

  final CreateAdController controller;
  final Future<void> Function({required bool isStart}) onPickDate;
  final Future<void> Function({required bool isStart}) onPickTime;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final c = controller;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: c.titleController,
              title: 'Title',
              hintText: 'Enter title',
              maxLength: CreateAdController.titleMax,
              borderColor: colorScheme.outline,
              hintTextColor: colorScheme.onSurfaceVariant,
              textColor: colorScheme.onSurface,
              titleStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              validator: c.validateTitle,
            ),
            const SizedBox(height: 16),
            Obx(
              () => CustomTextField(
                controller: c.businessController,
                readOnly: c.businessLocked.value,
                fillColor: c.businessLocked.value
                    ? colorScheme.surfaceContainerHighest
                    : null,
                title: 'Business name (optional)',
                hintText: 'e.g. Rusty Anchor Bar',
                maxLength: CreateAdController.businessNameMax,
                borderColor: colorScheme.outline,
                hintTextColor: colorScheme.onSurfaceVariant,
                textColor: colorScheme.onSurface,
                titleStyle: AppTextStyle.textSm(
                  weight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
                validator: c.validateBusinessName,
              ),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: c.locationController,
              title: 'Location (optional)',
              hintText: 'e.g. Wicker Park',
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              borderColor: colorScheme.outline,
              hintTextColor: colorScheme.onSurfaceVariant,
              textColor: colorScheme.onSurface,
              titleStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            CreateAdDateTimeRow(
              label: 'Start date (optional)',
              dateController: c.startDateController,
              timeController: c.startTimeController,
              onDateTap: () => onPickDate(isStart: true),
              onTimeTap: () => onPickTime(isStart: true),
              dateHint: 'Start date',
              timeHint: 'Start time',
            ),
            const SizedBox(height: 16),
            CreateAdDateTimeRow(
              label: 'End date (required)',
              dateController: c.endDateController,
              timeController: c.endTimeController,
              onDateTap: () => onPickDate(isStart: false),
              onTimeTap: () => onPickTime(isStart: false),
              dateHint: 'End date',
              timeHint: 'End time',
              dateValidator: c.validateEndDateField,
              timeValidator: c.validateEndTimeField,
            ),
            Obx(() {
              if (c.endDateError.value == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  c.endDateError.value!,
                  style: TextStyle(color: colorScheme.error, fontSize: 12),
                ),
              );
            }),
            const SizedBox(height: 20),
            Obx(
              () => FramedImageUploadField(
                selectedImage: c.adBanner.value,
                onImageSelected: c.setAdBanner,
                title: 'Ad banner',
                subtitle: 'Clear promo image for spotlight',
                errorText: c.imageError.value,
                emptyTitle: 'Add banner',
                emptyHint: 'JPG/PNG · 1200×630',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
