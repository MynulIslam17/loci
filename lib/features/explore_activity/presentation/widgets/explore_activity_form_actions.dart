import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_button.dart';

class ExploreActivityFormActions extends StatelessWidget {
  const ExploreActivityFormActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.isPrimaryEnabled,
    this.isLoading = false,
    this.onCancel,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool isPrimaryEnabled;
  final bool isLoading;
  final VoidCallback? onCancel;

  static Widget _singleLineLabel(String label, Color color) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        style: AppTextStyle.textSm(
          weight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Row(
      children: [
        Expanded(
          child: CustomButton(
            height: 48,
            backgroundColor: Colors.transparent,
            side: BorderSide(color: colorScheme.outline),
            textColor: colorScheme.onSurface,
            onPressed: onCancel ?? () => Navigator.pop(context),
            child: _singleLineLabel('Cancel', colorScheme.onSurface),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            height: 48,
            isLoading: isLoading,
            backgroundColor: colorScheme.primary,
            textColor: colorScheme.onPrimary,
            onPressed: isPrimaryEnabled ? onPrimary : null,
            child: _singleLineLabel(primaryLabel, colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }
}
