import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// A reusable form field for attaching a single file (image, PDF, or document).
///
/// - When no file is picked, it shows a tappable "add attachment" prompt that
///   calls [onPickFile].
/// - When a file is picked, it shows a card with a type icon, the file name,
///   and a remove button that calls [onRemoveFile].
///
/// The widget is purely presentational: the caller decides how to pick the file
/// (e.g. `AppFilePicker`) and how to store it, then passes the result back in
/// via [selectedFile].
class AttachmentPickerField extends StatelessWidget {
  const AttachmentPickerField({
    super.key,
    required this.selectedFile,
    required this.onPickFile,
    required this.onRemoveFile,
    this.title = 'Attachment',
    this.emptyLabel = 'Add attachment (image or PDF)',
  });

  /// The currently attached file, or null when nothing is attached.
  final File? selectedFile;

  /// Called when the user taps the empty prompt to choose a file.
  final VoidCallback onPickFile;

  /// Called when the user removes the attached file.
  final VoidCallback onRemoveFile;

  /// Label shown above the field.
  final String title;

  /// Text shown inside the empty prompt.
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyle.textMd(
            color: colors.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        selectedFile == null
            ? _AddAttachmentPrompt(label: emptyLabel, onTap: onPickFile)
            : _AttachedFileCard(file: selectedFile!, onRemove: onRemoveFile),
      ],
    );
  }
}

/// Tappable prompt shown when no file is attached.
class _AddAttachmentPrompt extends StatelessWidget {
  const _AddAttachmentPrompt({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_file, size: 20, color: colors.onSurface),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Preview card shown when a file is attached: type icon, name, and remove.
class _AttachedFileCard extends StatelessWidget {
  const _AttachedFileCard({required this.file, required this.onRemove});

  final File file;
  final VoidCallback onRemove;

  String get _fileName => file.path.split(Platform.pathSeparator).last;

  _AttachmentKind get _kind => _AttachmentKind.fromPath(file.path);

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Card(
      color: colors.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(_kind.icon, color: _kind.color(colors), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _fileName,
                style: AppTextStyle.textSm(weight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }
}

/// The kind of attachment, used to pick the right icon and color.
enum _AttachmentKind {
  pdf,
  document,
  image;

  static _AttachmentKind fromPath(String path) {
    final ext = path.toLowerCase().split('.').last;
    if (ext == 'pdf') return _AttachmentKind.pdf;
    if (ext == 'doc' || ext == 'docx') return _AttachmentKind.document;
    return _AttachmentKind.image;
  }

  IconData get icon {
    switch (this) {
      case _AttachmentKind.pdf:
        return Icons.picture_as_pdf;
      case _AttachmentKind.document:
        return Icons.description_outlined;
      case _AttachmentKind.image:
        return Icons.image_outlined;
    }
  }

  Color color(ColorScheme colors) {
    switch (this) {
      case _AttachmentKind.pdf:
        return Colors.red;
      case _AttachmentKind.document:
        return colors.primary;
      case _AttachmentKind.image:
        return colors.onSurfaceVariant;
    }
  }
}
