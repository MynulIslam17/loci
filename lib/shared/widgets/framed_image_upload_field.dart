import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/app_image_picker.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

/// Tappable image upload area with an inset frame, preview, and optional labels.
class FramedImageUploadField extends StatelessWidget {
  const FramedImageUploadField({
    super.key,
    this.selectedImage,
    required this.onImageSelected,
    this.title,
    this.subtitle,
    this.errorText,
    this.height = 148,
    this.emptyTitle = 'Add image',
    this.emptyHint = 'JPG or PNG',
    this.changeImageLabel = 'Tap to change image',
    this.onPickImage,
    this.kind = ImageUploadKind.normal,
  });

  final File? selectedImage;
  final ValueChanged<File> onImageSelected;
  final String? title;
  final String? subtitle;
  final String? errorText;
  final double height;
  final String emptyTitle;
  final String emptyHint;
  final String changeImageLabel;
  final ImageUploadKind kind;

  /// When set, used instead of [AppImagePicker.pickOne].
  final Future<void> Function(BuildContext context)? onPickImage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final hasError = errorText != null && errorText!.isNotEmpty;
    final borderColor = hasError ? colorScheme.error : colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: AppTextStyle.textSm(
              weight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 12),
        ],
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _pickImage(context),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    colorScheme.surfaceContainerHighest,
                    colorScheme.surfaceContainerHigh,
                  ],
                ),
                border: Border.all(
                  color: borderColor.withValues(alpha: hasError ? 1 : 0.35),
                  width: hasError ? 2 : 1.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: selectedImage != null
                  ? Padding(
                      padding: const EdgeInsets.all(8),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.85),
                            width: 1.5,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.5),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              CustomCachedImage(
                                imageFile: selectedImage,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                right: 12,
                                top: 12,
                                child: _EditBadge(colorScheme: colorScheme),
                              ),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        colorScheme.scrim.withValues(alpha: 0.55),
                                      ],
                                    ),
                                  ),
                                  child: Text(
                                    changeImageLabel,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyle.textXs(
                                      color: colorScheme.onInverseSurface,
                                      weight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : _EmptyPlaceholder(
                      colorScheme: colorScheme,
                      title: emptyTitle,
                      hint: emptyHint,
                    ),
            ),
          ),
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorText!,
              style: TextStyle(color: colorScheme.error, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    if (onPickImage != null) {
      await onPickImage!(context);
      return;
    }
    await AppImagePicker.pickOne(
      context: context,
      kind: kind,
      onSelected: onImageSelected,
    );
  }
}

class _EditBadge extends StatelessWidget {
  const _EditBadge({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_outlined, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            'Edit',
            style: AppTextStyle.textXs(
              color: colorScheme.onSurface,
              weight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder({
    required this.colorScheme,
    required this.title,
    required this.hint,
  });

  final ColorScheme colorScheme;
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colorScheme.primaryContainer,
          ),
          child: Icon(
            Icons.add_photo_alternate_outlined,
            size: 26,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: AppTextStyle.textSm(
            color: colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          hint,
          style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
