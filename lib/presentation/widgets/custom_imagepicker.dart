import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CustomImagePicker extends StatelessWidget {
  /// The local file to display
  final File? selectedImage;

  /// The network URL to display if no local file is selected
  final String? imageUrl;

  /// Callback when a new image is picked
  final Function(File) onImageSelected;

  /// Label text above the picker
  final String? label;

  /// Style for the label text
  final TextStyle? labelStyle;

  /// Custom placeholder widget (e.g., an Icon or Svg)
  final Widget? placeholder;

  /// Background color of the picker box
  final Color? backgroundColor;

  /// Border color of the picker box
  final Color? borderColor;

  /// Height of the picker box
  final double height;

  /// Corner radius
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

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage = await picker.pickImage(source: source);

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
              title: const Text('Take a Photo'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
              label!,
              style: labelStyle ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w400)
          ),
          const SizedBox(height: 10),
        ],
        GestureDetector(
          onTap: () => _showPickerOptions(context),
          child: Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: borderColor ?? Colors.grey.withOpacity(0.3)),
              color: backgroundColor ?? Colors.grey.withOpacity(0.05),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildImageContent(),
                ),
                // Overlay camera icon when an image is already present
                if (selectedImage != null || (imageUrl != null && imageUrl!.isNotEmpty))
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    if (selectedImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          selectedImage!,
          fit: BoxFit.cover,
        ),
      );
    }

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderContent(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          },
        ),
      );
    }

    return _buildPlaceholderContent();
  }

  Widget _buildPlaceholderContent() {
    return Center(
      child: placeholder ?? Icon(
          Icons.camera_alt_outlined,
          size: 40,
          color: Colors.grey.withOpacity(0.5)
      ),
    );
  }
}