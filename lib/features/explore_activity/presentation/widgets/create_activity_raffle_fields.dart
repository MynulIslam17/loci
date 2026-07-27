import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/data/models/task_model.dart';
import 'package:loci/features/explore_activity/presentation/widgets/coupon_upload_card.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/task_card.dart';

class CreateActivityRaffleFields extends StatelessWidget {
  const CreateActivityRaffleFields({
    super.key,
    required this.raffleDateController,
    required this.maxSupplyController,
    required this.couponTitleController,
    required this.rafflePrizeImage,
    required this.tasks,
    required this.onPickRange,
    required this.onPickCoupon,
    required this.onClearCoupon,
    required this.onAddRequirement,
    required this.onRemoveTask,
  });

  final TextEditingController raffleDateController;
  final TextEditingController maxSupplyController;
  final TextEditingController couponTitleController;
  final File? rafflePrizeImage;
  final List<TaskModel> tasks;
  final VoidCallback onPickRange;
  final VoidCallback onPickCoupon;
  final VoidCallback onClearCoupon;
  final VoidCallback onAddRequirement;
  final void Function(int index) onRemoveTask;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: raffleDateController,
                title: 'Entry Period',
                readOnly: true,
                onTap: onPickRange,
                hintText: 'Date range',
                fontSize: 12,
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
                textColor: colorScheme.onSurface,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: maxSupplyController,
                textInputAction: TextInputAction.next,
                title: 'Max Supply',
                hintText: 'Max supply',
                fontSize: 12,
                keyboardType: TextInputType.number,
                suffixIcon: Icon(
                  Icons.person_outline,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
                textColor: colorScheme.onSurface,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: couponTitleController,
          title: 'Coupon',
          hintText: 'Coupon title',
          prefixIcon: const Icon(Icons.card_giftcard),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Coupon title is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        CouponUploadCard(
          file: rafflePrizeImage,
          onTap: onPickCoupon,
          onDelete: onClearCoupon,
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          color: colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Tasks required ',
                        style: AppTextStyle.textSm(
                          weight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      TextSpan(
                        text: '(Check-in):',
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (tasks.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return TaskCard(
                        id: task.id,
                        title: task.title,
                        description: task.details,
                        imageUrl: task.banner,
                        onRemove: () => onRemoveTask(index),
                      );
                    },
                  ),
                const SizedBox(height: 12),
                CustomButton(
                  backgroundColor: colorScheme.surface,
                  side: BorderSide(color: colorScheme.primary),
                  onPressed: onAddRequirement,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: colorScheme.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Add requirement',
                        style: AppTextStyle.textMd(
                          color: colorScheme.primary,
                          weight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
