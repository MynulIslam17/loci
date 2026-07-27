import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class CreateAdDateTimeRow extends StatelessWidget {
  const CreateAdDateTimeRow({
    super.key,
    required this.label,
    required this.dateController,
    required this.timeController,
    required this.onDateTap,
    required this.onTimeTap,
    this.dateHint = 'Date',
    this.timeHint = 'Time',
    this.dateValidator,
    this.timeValidator,
  });

  final String label;
  final TextEditingController dateController;
  final TextEditingController timeController;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;
  final String dateHint;
  final String timeHint;
  final FormFieldValidator<String>? dateValidator;
  final FormFieldValidator<String>? timeValidator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.textSm(
            weight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextField(
                onTap: onDateTap,
                controller: dateController,
                readOnly: true,
                hintText: dateHint,
                fontSize: 10,
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
                hintTextColor: colorScheme.onSurfaceVariant,
                textColor: colorScheme.onSurface,
                validator: dateValidator,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(
                controller: timeController,
                onTap: onTimeTap,
                readOnly: true,
                hintText: timeHint,
                fontSize: 10,
                suffixIcon: Icon(
                  Icons.access_time,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
                hintTextColor: colorScheme.onSurfaceVariant,
                textColor: colorScheme.onSurface,
                validator: timeValidator,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
