import 'dart:io';
import 'package:file_picker/file_picker.dart';

class AppFilePicker {
  static const List<String> defaultExtensions = [
    'jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'
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
    return path != null ? File(path) : null;
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

    return result?.files
        .where((f) => f.path != null)
        .map((f) => File(f.path!))
        .toList() ??
        [];
  }

  /// IMAGE ONLY
  static Future<File?> pickImage() {
    return pickSingle(type: FileType.image);
  }

  /// MULTIPLE IMAGES
  static Future<List<File>> pickImages() {
    return pickMultiple(type: FileType.image);
  }
}