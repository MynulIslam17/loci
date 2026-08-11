import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// "Fields marked * are required" helper shown at the top of forms.
class RequiredFieldsNote extends StatelessWidget {
  const RequiredFieldsNote({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return RichText(
      text: TextSpan(
        text: 'Fields marked ',
        style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
        children: [
          TextSpan(
            text: '*',
            style: AppTextStyle.textXs(
              color: colorScheme.error,
              weight: FontWeight.w700,
            ),
          ),
          const TextSpan(text: ' are required'),
        ],
      ),
    );
  }
}

/// Field label with a red asterisk for required fields, or "(optional)".
class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({
    super.key,
    required this.label,
    this.isRequired = true,
  });

  final String label;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return RichText(
      text: TextSpan(
        text: label,
        style: AppTextStyle.textSm(
          color: colorScheme.onSurfaceVariant,
          weight: FontWeight.w500,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: AppTextStyle.textSm(
                color: colorScheme.error,
                weight: FontWeight.w700,
              ),
            )
          else
            TextSpan(
              text: ' (optional)',
              style: AppTextStyle.textXs(
                color: colorScheme.onSurfaceVariant,
                weight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}

/// Highlighted section header used on meeting, referral, and activity forms.
class FormSectionLabel extends StatelessWidget {
  const FormSectionLabel({
    super.key,
    required this.label,
    this.optional = false,
  });

  final String label;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: label,
                style: AppTextStyle.textMd(
                  color: colorScheme.primary,
                  weight: FontWeight.w700,
                ),
                children: [
                  if (optional)
                    TextSpan(
                      text: ' (optional)',
                      style: AppTextStyle.textSm(
                        color: colorScheme.onSurfaceVariant,
                        weight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
