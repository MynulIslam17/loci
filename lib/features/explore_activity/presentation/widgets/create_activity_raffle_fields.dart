import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/data/models/activity_task_search_model.dart';
import 'package:loci/features/explore_activity/presentation/widgets/coupon_upload_card.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_picker_field.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_field_icon.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_raffle_tasks_block.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/form_labels.dart';
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
    this.couponImageUrl,
    this.taskCards,
    this.showEntryRequirements = true,
  });

  final TextEditingController raffleDateController;
  final TextEditingController maxSupplyController;
  final TextEditingController couponTitleController;
  final File? rafflePrizeImage;
  final String? couponImageUrl;
  final List<Widget>? taskCards;
  final List<TaskModel> tasks;
  final VoidCallback onPickRange;
  final VoidCallback onPickCoupon;
  final VoidCallback onClearCoupon;
  final VoidCallback onAddRequirement;
  final void Function(int index) onRemoveTask;
  final bool showEntryRequirements;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: CreateActivityPickerField(
                controller: raffleDateController,
                title: 'Entry period',
                hintText: 'Select date range',
                icon: Icons.date_range_outlined,
                onTap: onPickRange,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CustomTextField(
                controller: maxSupplyController,
                textInputAction: TextInputAction.next,
                title: 'Max supply',
                isRequired: true,
                hintText: 'Quantity',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                prefixIcon: exploreActivityFieldIcon(
                  context,
                  Icons.inventory_2_outlined,
                ),
                borderColor: colorScheme.outline,
                textColor: colorScheme.onSurface,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return 'Max supply is required';
                  final supply = int.tryParse(text);
                  if (supply == null) return 'Enter a valid number';
                  if (supply < 1) return 'Supply must be at least 1';
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: couponTitleController,
          title: 'Prize bundle name',
          isRequired: true,
          hintText: 'Name shown to participants',
          prefixIcon: exploreActivityFieldIcon(
            context,
            Icons.card_giftcard_outlined,
          ),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Prize name is required';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        const FormFieldLabel(label: 'Prize image', isRequired: true),
        const SizedBox(height: 6),
        CouponUploadCard(
          file: rafflePrizeImage,
          imageUrl: couponImageUrl,
          onTap: onPickCoupon,
          onDelete: onClearCoupon,
        ),
        if (showEntryRequirements) ...[
          const SizedBox(height: 16),
          ExploreActivityRaffleTasksBlock(
            taskCards: taskCards ??
                [
                  for (var i = 0; i < tasks.length; i++)
                    TaskCard(
                      id: tasks[i].id,
                      title: tasks[i].title,
                      description: tasks[i].details,
                      imageUrl: tasks[i].banner,
                      step: i + 1,
                      typeLabel: TaskCard.typeLabelFromActivityType(
                        tasks[i].activityType,
                      ),
                      onRemove: () => onRemoveTask(i),
                    ),
                ],
            onAddRequirement: onAddRequirement,
          ),
        ],
      ],
    );
  }
}
