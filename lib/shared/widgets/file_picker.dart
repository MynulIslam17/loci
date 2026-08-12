import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:loci/core/utils/image_upload_preparer.dart';

class AppFilePicker {
  static const List<String> defaultExtensions = [
    'jpg',
    'jpeg',
    'png',
    'webp',
    'heic',
    'heif',
    'pdf',
    'doc',
    'docx',
  ];

  static Future<File?> pickSingle({
    FileType type = FileType.custom,
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowedExtensions: type == FileType.custom
          ? (allowedExtensions ?? defaultExtensions)
          : null,
    );

    final path = result?.files.single.path;
    if (path == null) return null;
    return ImageUploadPreparer.fromAnyPickedFile(File(path));
  }

  static Future<List<File>> pickMultiple({
    FileType type = FileType.custom,
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: type,
      allowMultiple: true,
      allowedExtensions: type == FileType.custom
          ? (allowedExtensions ?? defaultExtensions)
          : null,
    );

    final files = result?.files
            .where((f) => f.path != null)
            .map((f) => File(f.path!))
            .toList() ??
        [];
    final prepared = <File>[];
    Object? lastError;
    for (final file in files) {
      try {
        prepared.add(await ImageUploadPreparer.fromAnyPickedFile(file));
      } catch (e) {
        lastError = e;
      }
    }
    if (files.isNotEmpty && prepared.isEmpty) {
      throw lastError ??
          ImagePickException("Couldn't read those files. Please try again.");
    }
    return prepared;
  }

  static Future<File?> pickImage() {
    return pickSingle(type: FileType.image);
  }

  static Future<List<File>> pickImages() {
    return pickMultiple(type: FileType.image);
  }
}
