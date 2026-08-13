import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/features/my_business/presentation/widgets/edit_circle_button.dart';
import 'package:loci/shared/widgets/confirm_dialog.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/image_picker_helper.dart';
import 'package:loci/shared/widgets/image_viewer.dart';

class MyBusinessPhotoGrid extends StatelessWidget {
  const MyBusinessPhotoGrid({
    super.key,
    required this.apiPhotos,
    required this.localPhotos,
    required this.onAddPhotos,
    required this.onRemoveLocalPhoto,
    required this.onRemoveApiPhoto,
  });

  final List<String> apiPhotos;
  final RxList<File> localPhotos;
  final void Function(List<File> files) onAddPhotos;
  final void Function(int localIndex) onRemoveLocalPhoto;
  final void Function(String photoUrl) onRemoveApiPhoto;

  Future<void> _confirmRemovePhoto(
    BuildContext context, {
    required bool isUploaded,
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove photo?',
      message: isUploaded
          ? 'This photo will be removed from your business profile. You can add it again later.'
          : 'This photo has not been uploaded yet and will be removed from your selection.',
      confirmText: 'Remove',
      cancelText: 'Cancel',
      icon: Icons.photo_outlined,
      isDestructive: true,
    );
    if (confirmed) onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final totalImages = apiPhotos.length + localPhotos.length;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
        ),
        itemCount: totalImages + 1,
        itemBuilder: (context, index) {
          if (index == totalImages) {
            return _AddPhotoTile(
              onTap: () => showImagePickerSheet(
                context: context,
                allowMultiple: true,
                onPicked: (files) {
                  if (files.isEmpty) return;
                  onAddPhotos(files);
                },
              ),
            );
          }

          if (index < apiPhotos.length) {
            final url = apiPhotos[index];
            return Stack(
              children: [
                GestureDetector(
                  onTap: () => showImageViewer(
                    context,
                    imageUrl: url,
                    heroTag: 'business-photo-$url',
                  ),
                  child: Hero(
                    tag: 'business-photo-$url',
                    child: CustomCachedImage(
                      imageUrl: url,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: EditCircleButton(
                    onTap: () => _confirmRemovePhoto(
                      context,
                      isUploaded: true,
                      onConfirm: () => onRemoveApiPhoto(url),
                    ),
                    size: 20,
                    icon: Icons.cancel,
                    iconColor: AppColors.danger,
                  ),
                ),
              ],
            );
          }

          final localIndex = index - apiPhotos.length;
          final localFile = localPhotos[localIndex];
          return Stack(
            children: [
              GestureDetector(
                onTap: () => showImageViewer(
                  context,
                  imageFile: localFile,
                  heroTag: 'business-local-photo-$localIndex',
                ),
                child: Hero(
                  tag: 'business-local-photo-$localIndex',
                  child: CustomCachedImage(
                    imageFile: localFile,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Positioned(
                right: 5,
                top: 5,
                child: EditCircleButton(
                  onTap: () => _confirmRemovePhoto(
                    context,
                    isUploaded: false,
                    onConfirm: () => onRemoveLocalPhoto(localIndex),
                  ),
                  size: 20,
                  icon: Icons.cancel,
                  iconColor: AppColors.danger,
                ),
              ),
            ],
          );
        },
      );
    });
  }
}

class _AddPhotoTile extends StatelessWidget {
  const _AddPhotoTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade400,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.image_outlined, color: Colors.white, size: 28),
            SizedBox(height: 4),
            Text(
              'Add image',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
