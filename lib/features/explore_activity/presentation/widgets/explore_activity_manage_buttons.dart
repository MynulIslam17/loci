import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Edit + view actions on explore activity list cards.
class ExploreActivityManageButtons extends StatelessWidget {
  const ExploreActivityManageButtons({
    super.key,
    required this.onEdit,
    required this.onView,
    this.editLabel = 'Edit Info',
    this.viewLabel = 'View Details',
  });

  final VoidCallback? onEdit;
  final VoidCallback? onView;
  final String editLabel;
  final String viewLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final editTextStyle = AppTextStyle.textSm(
      weight: FontWeight.w600,
      color: colorScheme.onSurface,
    );
    final viewTextStyle = AppTextStyle.textSm(
      weight: FontWeight.w600,
      color: colorScheme.onPrimary,
    );

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onEdit,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: colorScheme.outlineVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 16,
                  color: colorScheme.onSurface,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      editLabel,
                      maxLines: 1,
                      softWrap: false,
                      style: editTextStyle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onView,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      viewLabel,
                      maxLines: 1,
                      softWrap: false,
                      style: viewTextStyle,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: colorScheme.onPrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
