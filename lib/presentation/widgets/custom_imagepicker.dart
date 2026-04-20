import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker extends StatelessWidget {
  final File? selectedImage;
  final String? imageUrl;
  final Function(File) onImageSelected;
  final String? label;
  final TextStyle? labelStyle;
  final Widget? placeholder;
  final Color? backgroundColor;
  final Color? borderColor;
  final double height;
  final double borderRadius;

  const CustomImagePicker({
    super.key,
    this.selectedImage,
    this.imageUrl,
    required this.onImageSelected,
    this.label,
    this.labelStyle,
    this.placeholder,
    this.backgroundColor,
    this.borderColor,
    this.height = 155,
    this.borderRadius = 12,
  });

  /// ✅ Static helper: Show bottom sheet & pick image from anywhere
  static Future<void> pickImageSimple({
    required BuildContext context,
    required Function(File) onImageSelected,
  }) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? picked = await ImagePicker().pickImage(source: source);
      if (picked != null && context.mounted) {
        onImageSelected(File(picked.path));
      }
    }
  }

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      onImageSelected(File(pickedImage.path));
    }
    if (context.mounted) Navigator.pop(context);
  }

  void _showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take  Photo'),
              onTap: () => _pickImage(ImageSource.camera, context),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => _pickImage(ImageSource.gallery, context),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isCircle = borderRadius >= (height / 2);

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
            // Handle GridView constraints: use available height if infinity passed
            final double finalHeight = (height == double.infinity)
                ? (constraints.hasBoundedHeight ? constraints.maxHeight : 155)
                : height;

            return GestureDetector(
              onTap: () => _showPickerOptions(context),
              child: Container(
                width: isCircle ? finalHeight : double.infinity,
                height: finalHeight,
                decoration: BoxDecoration(
                  shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
                  borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
                  border: Border.all(color: borderColor ?? Colors.grey.withOpacity(0.3)),
                  color: backgroundColor ?? Colors.grey.withOpacity(0.05),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(isCircle ? finalHeight / 2 : borderRadius),
                  child: Stack(
                    children: [
                      Positioned.fill(child: _buildImageContent()),
                      // Show camera overlay only when image exists
                      if (selectedImage != null || imageUrl?.isNotEmpty == true)
                        _buildCameraOverlay(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCameraOverlay() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.4),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 24),
      ),
    );
  }

  Widget _buildImageContent() {
    if (selectedImage != null) return Image.file(selectedImage!, fit: BoxFit.cover);
    if (imageUrl?.isNotEmpty == true) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildPlaceholderContent(),
      );
    }
    return _buildPlaceholderContent();
  }

  Widget _buildPlaceholderContent() {
    return Center(
      child: placeholder ??
          Icon(Icons.add_a_photo_outlined, size: 40, color: Colors.grey.withOpacity(0.5)),
    );
  }
}