import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loci/core/utils/image_upload_preparer.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:permission_handler/permission_handler.dart';

class ImagePickerHelper {
  static final ImagePicker _picker = ImagePicker();

  static const double _maxWidth = 1024;
  static const double _maxHeight = 1024;
  static const int _imageQuality = 85;

  static Future<List<File>> pick({
    required bool multi,
    required ImageSource source,
  }) async {
    final allowed = await _ensurePermission(source);
    if (!allowed) return [];

    if (multi) {
      final files = await _picker.pickMultiImage(
        maxWidth: _maxWidth,
        maxHeight: _maxHeight,
        imageQuality: _imageQuality,
        requestFullMetadata: false,
      );
      final persisted = <File>[];
      Object? lastError;
      for (final file in files) {
        try {
          persisted.add(await ImageUploadPreparer.fromXFile(file));
        } catch (e) {
          lastError = e;
        }
      }
      if (files.isNotEmpty && persisted.isEmpty) {
        throw lastError ??
            ImagePickException(
              "Couldn't read those photos. Please try again.",
            );
      }
      return persisted;
    }

    final file = await _picker.pickImage(
      source: source,
      maxWidth: _maxWidth,
      maxHeight: _maxHeight,
      imageQuality: _imageQuality,
      requestFullMetadata: false,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (file == null) return [];
    return [await ImageUploadPreparer.fromXFile(file)];
  }

  static Future<File?> persistForUpload(XFile? picked) async {
    if (picked == null) return null;
    return ImageUploadPreparer.fromXFile(picked);
  }

  static Future<bool> _ensurePermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      var status = await Permission.camera.status;
      if (!status.isGranted) {
        status = await Permission.camera.request();
      }
      if (status.isGranted) return true;
      _permissionDenied(
        'Camera access is required to take a photo.',
        openSettings: status.isPermanentlyDenied || status.isRestricted,
      );
      return false;
    }

    // iOS 14+ PHPicker does not need full Photo Library permission.
    if (Platform.isIOS) return true;

    var status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) return true;
    status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) return true;

    _permissionDenied(
      'Photo access is required to choose an image.',
      openSettings: status.isPermanentlyDenied,
    );
    return false;
  }

  static void _permissionDenied(String message, {required bool openSettings}) {
    SnackbarService.error(
      openSettings ? '$message Enable it in Settings.' : message,
    );
    if (openSettings) {
      openAppSettings();
    }
  }
}

void showImagePickerSheet({
  required BuildContext context,
  required Function(List<File>) onPicked,
  bool allowMultiple = false,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!allowMultiple) ...[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text("Gallery"),
                onTap: () async {
                  try {
                    final files = await ImagePickerHelper.pick(
                      multi: allowMultiple,
                      source: ImageSource.gallery,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (files.isNotEmpty) onPicked(files);
                  } catch (e) {
                    if (ctx.mounted) Navigator.pop(ctx);
                    SnackbarService.error(
                      e.toString().replaceFirst('Exception: ', ''),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text("Camera"),
                onTap: () async {
                  try {
                    final files = await ImagePickerHelper.pick(
                      multi: false,
                      source: ImageSource.camera,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (files.isNotEmpty) onPicked(files);
                  } catch (e) {
                    if (ctx.mounted) Navigator.pop(ctx);
                    SnackbarService.error(
                      e.toString().replaceFirst('Exception: ', ''),
                    );
                  }
                },
              ),
            ],
            if (allowMultiple)
              ListTile(
                leading: const Icon(Icons.collections),
                title: const Text("Multiple Select"),
                onTap: () async {
                  try {
                    final files = await ImagePickerHelper.pick(
                      multi: true,
                      source: ImageSource.gallery,
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (files.isNotEmpty) onPicked(files);
                  } catch (e) {
                    if (ctx.mounted) Navigator.pop(ctx);
                    SnackbarService.error(
                      e.toString().replaceFirst('Exception: ', ''),
                    );
                  }
                },
              ),
          ],
        ),
      );
    },
  );
}
