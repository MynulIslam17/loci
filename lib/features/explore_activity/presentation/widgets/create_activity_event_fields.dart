import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Schedule and Seats',
          style: AppTextStyle.textSm(weight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: dateController,
                readOnly: true,
                onTap: onPickDate,
                hintText: 'Start date',
                fontSize: 12,
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
                textColor: colorScheme.onSurface,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: timeController,
                readOnly: true,
                onTap: onPickTime,
                hintText: 'Start time',
                fontSize: 12,
                suffixIcon: Icon(
                  Icons.access_time,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
                textColor: colorScheme.onSurface,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                controller: personController,
                hintText: 'Max seats',
                fontSize: 12,
                keyboardType: TextInputType.number,
                suffixIcon: Icon(
                  Icons.person_outline,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                borderColor: colorScheme.outline,
                textColor: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
