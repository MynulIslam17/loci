import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loci/core/utils/image_upload_preparer.dart';
import 'package:permission_handler/permission_handler.dart';

/// Copy this file to reuse image picking in another Flutter app.
///
/// Dependencies: `image_picker`, `image_cropper`, `permission_handler`,
/// and (in this project) [ImageUploadPreparer] for HEIC / upload sizing.
///
/// Android: register UCropActivity in AndroidManifest.xml (see image_cropper docs).
///
/// Usage:
/// ```dart
/// // Profile / avatar (crop first)
/// await AppImagePicker.pickOne(
///   context: context,
///   kind: ImageUploadKind.profile,
///   onSelected: (file) { ... },
/// );
///
/// // Normal photo (no crop)
/// await AppImagePicker.pickOne(
///   context: context,
///   kind: ImageUploadKind.normal,
///   onSelected: (file) { ... },
/// );
///
/// // Or use the tappable widget
/// AppImagePickerField(
///   kind: ImageUploadKind.profile,
///   selectedImage: file,
///   onImageSelected: (f) { ... },
/// )
/// ```

enum ImageUploadKind {
  /// Gallery / banner / ads — no crop.
  normal,

  /// Avatar / logo — circular crop UI, square output.
  profile,
}

/// Camera / gallery pick + optional profile crop. All logic lives here.
class AppImagePicker {
  AppImagePicker._();

  static final ImagePicker _picker = ImagePicker();

  static Future<List<File>> pick({
    required BuildContext context,
    ImageUploadKind kind = ImageUploadKind.normal,
    bool allowMultiple = false,
  }) async {
    if (kind == ImageUploadKind.profile) allowMultiple = false;

    final source = await _showSourceSheet(context, allowMultiple: allowMultiple);
    if (source == null || !context.mounted) return [];

    try {
      final files = await _pickFiles(
        multi: allowMultiple && source == ImageSource.gallery,
        source: source,
        forCrop: kind == ImageUploadKind.profile,
      );
      if (files.isEmpty || !context.mounted) return [];
      if (kind == ImageUploadKind.normal) return files;

      final cropped = await _cropProfile(context, files.first);
      return cropped == null ? <File>[] : <File>[cropped];
    } catch (e) {
      if (context.mounted) {
        _toast(context, e.toString().replaceFirst('Exception: ', ''));
      }
      return [];
    }
  }

  static Future<void> pickOne({
    required BuildContext context,
    required void Function(File file) onSelected,
    ImageUploadKind kind = ImageUploadKind.normal,
  }) async {
    final files = await pick(context: context, kind: kind);
    if (files.isNotEmpty) onSelected(files.first);
  }

  static Future<void> pickMany({
    required BuildContext context,
    required void Function(List<File> files) onPicked,
    ImageUploadKind kind = ImageUploadKind.normal,
    bool allowMultiple = false,
  }) async {
    final files = await pick(
      context: context,
      kind: kind,
      allowMultiple: allowMultiple,
    );
    if (files.isNotEmpty) onPicked(files);
  }

  // ── permissions + pick ─────────────────────────────────────────────

  static Future<List<File>> _pickFiles({
    required bool multi,
    required ImageSource source,
    required bool forCrop,
  }) async {
    if (!await _ensurePermission(source)) return [];

    final maxSide = forCrop ? 1600.0 : 1024.0;
    final quality = forCrop ? 92 : 85;

    if (multi) {
      final picked = await _picker.pickMultiImage(
        maxWidth: maxSide,
        maxHeight: maxSide,
        imageQuality: quality,
        requestFullMetadata: false,
      );
      final out = <File>[];
      Object? lastError;
      for (final x in picked) {
        try {
          out.add(await ImageUploadPreparer.fromXFile(x));
        } catch (e) {
          lastError = e;
        }
      }
      if (picked.isNotEmpty && out.isEmpty) {
        throw lastError ??
            Exception("Couldn't read those photos. Please try again.");
      }
      return out;
    }

    final x = await _picker.pickImage(
      source: source,
      maxWidth: maxSide,
      maxHeight: maxSide,
      imageQuality: quality,
      requestFullMetadata: false,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (x == null) return [];
    return [await ImageUploadPreparer.fromXFile(x)];
  }

  static Future<bool> _ensurePermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      var status = await Permission.camera.status;
      if (!status.isGranted) status = await Permission.camera.request();
      if (status.isGranted) return true;
      if (status.isPermanentlyDenied || status.isRestricted) openAppSettings();
      return false;
    }
    if (Platform.isIOS) return true; // PHPicker
    var status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) return true;
    status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) return true;
    if (status.isPermanentlyDenied) openAppSettings();
    return false;
  }

  // ── crop (profile only) ────────────────────────────────────────────

  static Future<File?> _cropProfile(BuildContext context, File source) async {
    final primary = Theme.of(context).colorScheme.primary;
    final onPrimary = Theme.of(context).colorScheme.onPrimary;

    final cropped = await ImageCropper().cropImage(
      sourcePath: source.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      maxWidth: 1024,
      maxHeight: 1024,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 90,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop profile photo',
          toolbarColor: primary,
          toolbarWidgetColor: onPrimary,
          activeControlsWidgetColor: primary,
          initAspectRatio: CropAspectRatioPreset.square,
          lockAspectRatio: true,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
        IOSUiSettings(
          title: 'Crop profile photo',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          aspectRatioPickerButtonHidden: true,
          cropStyle: CropStyle.circle,
          aspectRatioPresets: const [CropAspectRatioPreset.square],
        ),
      ],
    );
    if (cropped == null) return null;
    return ImageUploadPreparer.fromFile(File(cropped.path));
  }

  // ── UI helpers ─────────────────────────────────────────────────────

  static Future<ImageSource?> _showSourceSheet(
    BuildContext context, {
    required bool allowMultiple,
  }) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!allowMultiple) ...[
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ] else
              ListTile(
                leading: const Icon(Icons.collections_outlined),
                title: const Text('Select Photos'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
          ],
        ),
      ),
    );
  }

  static void _toast(BuildContext context, String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    // Fallback if called without a Scaffold ancestor.
    debugPrint('AppImagePicker: $message');
  }
}

/// Bottom-sheet entry used by existing screens.
Future<void> showImagePickerSheet({
  required BuildContext context,
  required Function(List<File>) onPicked,
  bool allowMultiple = false,
  ImageUploadKind kind = ImageUploadKind.normal,
}) {
  return AppImagePicker.pickMany(
    context: context,
    onPicked: onPicked,
    allowMultiple: allowMultiple,
    kind: kind,
  );
}

/// Tappable preview tile that opens the picker (profile or normal).
class AppImagePickerField extends StatelessWidget {
  const AppImagePickerField({
    super.key,
    required this.onImageSelected,
    this.selectedImage,
    this.imageUrl,
    this.label,
    this.labelStyle,
    this.placeholder,
    this.backgroundColor,
    this.borderColor,
    this.height = 155,
    this.borderRadius = 12,
    this.kind = ImageUploadKind.normal,
  });

  final File? selectedImage;
  final String? imageUrl;
  final ValueChanged<File> onImageSelected;
  final String? label;
  final TextStyle? labelStyle;
  final Widget? placeholder;
  final Color? backgroundColor;
  final Color? borderColor;
  final double height;
  final double borderRadius;
  final ImageUploadKind kind;

  /// Alias kept so older call sites keep working.
  static Future<void> pickImageSimple({
    required BuildContext context,
    required Function(File) onImageSelected,
    ImageUploadKind kind = ImageUploadKind.normal,
  }) {
    return AppImagePicker.pickOne(
      context: context,
      onSelected: onImageSelected,
      kind: kind,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isCircle = borderRadius >= (height / 2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(label!, style: labelStyle ?? const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
        ],
        LayoutBuilder(
          builder: (context, constraints) {
            final h = height == double.infinity
                ? (constraints.hasBoundedHeight ? constraints.maxHeight : 155.0)
                : height;

            Widget content;
            if (selectedImage != null) {
              content = Image.file(selectedImage!, fit: BoxFit.cover);
            } else if (imageUrl != null && imageUrl!.isNotEmpty) {
              content = Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) =>
                    placeholder ?? _defaultPlaceholder(),
              );
            } else {
              content = placeholder ?? _defaultPlaceholder();
            }

            return GestureDetector(
              onTap: () => AppImagePicker.pickOne(
                context: context,
                kind: kind,
                onSelected: onImageSelected,
              ),
              child: Container(
                width: isCircle ? h : double.infinity,
                height: h,
                decoration: BoxDecoration(
                  shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius:
                      isCircle ? null : BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: borderColor ?? Colors.grey.withValues(alpha: 0.3),
                  ),
                  color: backgroundColor ?? Colors.grey.withValues(alpha: 0.05),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    content,
                    if (selectedImage != null ||
                        (imageUrl != null && imageUrl!.isNotEmpty))
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _defaultPlaceholder() {
    return Center(
      child: Icon(
        Icons.add_a_photo_outlined,
        size: 40,
        color: Colors.grey.withValues(alpha: 0.5),
      ),
    );
  }
}

/// Old name → same widget (so existing imports keep compiling).
typedef CustomImagePicker = AppImagePickerField;
