import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/explore_activity/presentation/widgets/create_activity_picker_field.dart';
import 'package:loci/features/explore_activity/presentation/widgets/explore_activity_field_icon.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class CreateActivityEventFields extends StatelessWidget {
  const CreateActivityEventFields({
    super.key,
    required this.dateController,
    required this.timeController,
    required this.personController,
    required this.onPickDate,
    required this.onPickTime,
  });

  final TextEditingController dateController;
  final TextEditingController timeController;
  final TextEditingController personController;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CreateActivityPickerField(
                controller: dateController,
                title: 'Start date',
                hintText: 'Select date',
                icon: Icons.calendar_today_outlined,
                onTap: onPickDate,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CreateActivityPickerField(
                controller: timeController,
                title: 'Start time',
                hintText: 'Select time',
                icon: Icons.access_time,
                onTap: onPickTime,
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
          controller: personController,
          title: 'Max participants',
          isRequired: true,
          hintText: 'e.g. 100',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          textInputAction: TextInputAction.next,
          prefixIcon: exploreActivityFieldIcon(
            context,
            Icons.groups_outlined,
          ),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return 'Max participants is required';
            final count = int.tryParse(text);
            if (count == null) return 'Enter a valid number';
            if (count < 1) return 'Must allow at least 1 participant';
            return null;
          },
        ),
      ],
    );
  }
}
