import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';

import 'custom_image_container.dart';

/// Shared task row for raffle create, edit, and view screens.
class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.step,
    this.typeLabel,
    this.onRemove,
    this.onTap,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final int? step;
  final String? typeLabel;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;
  final bool isCompleted;

  static String typeLabelFromActivityType(String activityType) {
    return activityType.toLowerCase().contains('route') ? 'Route' : 'Event';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    final content = Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          if (step != null) ...[
            _StepBadge(step: step!, colorScheme: colorScheme),
            const SizedBox(width: 12),
          ],
          _TaskImage(imageUrl: imageUrl, colorScheme: colorScheme),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (typeLabel != null && typeLabel!.isNotEmpty) ...[
                  _TypeBadge(label: typeLabel!, colorScheme: colorScheme),
                  const SizedBox(height: 6),
                ],
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.textSm(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w700,
                  ),
                ),
                if (description != null && description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.base50,
                ),
              ),
            ),
          ] else if (isCompleted) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 24,
            ),
          ] else if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );

    final decoration = BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: colorScheme.outline.withValues(alpha: 0.25),
      ),
    );

    if (onTap != null) {
      return Material(
        key: ValueKey(id),
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Ink(decoration: decoration, child: content),
        ),
      );
    }

    return Container(
      key: ValueKey(id),
      decoration: decoration,
      child: content,
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.step, required this.colorScheme});

  final int step;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$step',
        style: AppTextStyle.textSm(
          weight: FontWeight.w700,
          color: colorScheme.primary,
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.label, required this.colorScheme});

  final String label;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyle.textXs(
          weight: FontWeight.w600,
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

class _TaskImage extends StatelessWidget {
  const _TaskImage({required this.imageUrl, required this.colorScheme});

  final String? imageUrl;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: CustomCachedImage(
        width: 44,
        height: 44,
        isCircle: true,
        imageUrl: imageUrl,
      ),
    );
  }
}
