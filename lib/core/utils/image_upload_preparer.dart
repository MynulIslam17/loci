import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class ImagePickException implements Exception {
  ImagePickException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Turns any iPhone/Android picker result into a small JPEG the API will accept.
///
/// Covers TestFlight/iOS cases: HEIC/HEIF, Live Photos, iCloud stubs, EXIF
/// orientation, security-scoped temp paths, and oversized camera files.
class ImageUploadPreparer {
  static const int maxBytes = 1500 * 1024;

  static Future<File> fromXFile(XFile picked) async {
    final bytes = await _readBytes(picked);
    return fromBytes(bytes, sourcePath: picked.path);
  }

  static Future<File> fromFile(File file) async {
    if (!await file.exists()) {
      throw ImagePickException(
        "Couldn't read that photo. Please try another image.",
      );
    }
    final bytes = await file.readAsBytes();
    return fromBytes(bytes, sourcePath: file.path);
  }

  /// Copies any picked file into app temp. Images become JPEG; PDFs/docs keep
  /// their type. Needed on iOS TestFlight where picker paths expire.
  static Future<File> fromAnyPickedFile(File file) async {
    if (!await file.exists()) {
      throw ImagePickException("Couldn't read that file. Please try again.");
    }
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      throw ImagePickException(
        "Couldn't load that file. If it's in iCloud, wait for it to download "
        'and try again.',
      );
    }
    if (looksLikeImage(bytes, file.path)) {
      return fromBytes(bytes, sourcePath: file.path);
    }

    final ext = _nonImageExtension(bytes, file.path);
    final out = File(
      '${Directory.systemTemp.path}/loci_file_${DateTime.now().microsecondsSinceEpoch}.$ext',
    );
    await out.writeAsBytes(bytes, flush: true);
    return out;
  }

  static bool looksLikeImage(List<int> bytes, [String? path]) {
    if (_isJpeg(bytes) ||
        _isPng(bytes) ||
        _isHeic(bytes) ||
        _isWebp(bytes) ||
        _isGif(bytes)) {
      return true;
    }
    final lower = (path ?? '').toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.heic') ||
        lower.endsWith('.heif') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }

  static Future<File> fromBytes(Uint8List bytes, {String? sourcePath}) async {
    if (bytes.isEmpty) {
      throw ImagePickException(
        "That photo couldn't be loaded. If it's in iCloud, wait for it to "
        'download and try again.',
      );
    }

    final jpeg = await _toJpegUnderLimit(bytes, sourcePath: sourcePath);
    final out = File(
      '${Directory.systemTemp.path}/loci_upload_${DateTime.now().microsecondsSinceEpoch}.jpg',
    );
    await out.writeAsBytes(jpeg, flush: true);
    if (!await out.exists() || await out.length() == 0) {
      throw ImagePickException(
        "Couldn't save that photo for upload. Please try again.",
      );
    }
    return out;
  }

  static Future<File> recompress(
    File file, {
    int quality = 55,
    int maxSide = 720,
  }) async {
    final bytes = await file.readAsBytes();
    final jpeg = await _compress(
      bytes,
      sourcePath: file.path,
      quality: quality,
      maxSide: maxSide,
    );
    if (jpeg == null || jpeg.isEmpty || !_isJpeg(jpeg)) {
      throw ImagePickException(
        'This photo is too large. Please try a different image.',
      );
    }
    return fromBytes(jpeg);
  }

  static Future<Uint8List> _readBytes(XFile picked) async {
    try {
      final bytes = await picked.readAsBytes();
      if (bytes.isNotEmpty) return bytes;
    } catch (_) {}

    try {
      final file = File(picked.path);
      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        if (bytes.isNotEmpty) return bytes;
      }
    } catch (_) {}

    throw ImagePickException(
      "Couldn't read that photo. If it's in iCloud, wait for it to download "
      'and try again.',
    );
  }

  static Future<Uint8List> _toJpegUnderLimit(
    Uint8List bytes, {
    String? sourcePath,
  }) async {
    var input = bytes;
    var path = sourcePath;
    Uint8List? jpeg;

    const attempts = [
      (quality: 85, maxSide: 1024),
      (quality: 70, maxSide: 800),
      (quality: 50, maxSide: 640),
    ];

    for (final attempt in attempts) {
      jpeg = await _compress(
        input,
        sourcePath: path,
        quality: attempt.quality,
        maxSide: attempt.maxSide,
      );
      if (jpeg != null && jpeg.isNotEmpty && _isJpeg(jpeg)) {
        if (jpeg.length <= maxBytes) return jpeg;
        input = jpeg;
        path = null;
      }
    }

    if (jpeg != null && jpeg.isNotEmpty && _isJpeg(jpeg)) return jpeg;
    if (_isJpeg(bytes) && bytes.length <= maxBytes) return bytes;

    throw ImagePickException(
      'This photo is too large or in an unsupported format. Try another image.',
    );
  }

  static Future<Uint8List?> _compress(
    Uint8List bytes, {
    String? sourcePath,
    required int quality,
    required int maxSide,
  }) async {
    final rawPath = await _writeIdentifiableTemp(bytes, sourcePath);

    try {
      if (sourcePath != null && sourcePath.isNotEmpty) {
        final fromOriginal = await _compressFile(
          sourcePath,
          quality: quality,
          maxSide: maxSide,
        );
        if (fromOriginal != null) return fromOriginal;
      }
    } catch (_) {}

    try {
      final fromRaw = await _compressFile(
        rawPath,
        quality: quality,
        maxSide: maxSide,
      );
      if (fromRaw != null) return fromRaw;
    } catch (_) {}

    try {
      final fromList = await FlutterImageCompress.compressWithList(
        bytes,
        quality: quality,
        minWidth: maxSide,
        minHeight: maxSide,
        format: CompressFormat.jpeg,
        keepExif: false,
        autoCorrectionAngle: true,
      );
      if (fromList.isNotEmpty && _isJpeg(fromList)) return fromList;
    } catch (_) {}

    return null;
  }

  static Future<Uint8List?> _compressFile(
    String path, {
    required int quality,
    required int maxSide,
  }) async {
    final result = await FlutterImageCompress.compressWithFile(
      path,
      quality: quality,
      minWidth: maxSide,
      minHeight: maxSide,
      format: CompressFormat.jpeg,
      keepExif: false,
      autoCorrectionAngle: true,
    );
    if (result == null || result.isEmpty || !_isJpeg(result)) return null;
    return Uint8List.fromList(result);
  }

  /// ImageIO on iOS needs a real extension (especially `.heic`) to decode.
  static Future<String> _writeIdentifiableTemp(
    Uint8List bytes,
    String? sourcePath,
  ) async {
    final ext = _extensionFor(bytes, sourcePath);
    final path =
        '${Directory.systemTemp.path}/loci_raw_${DateTime.now().microsecondsSinceEpoch}.$ext';
    await File(path).writeAsBytes(bytes, flush: true);
    return path;
  }

  static String _extensionFor(Uint8List bytes, String? sourcePath) {
    if (_isJpeg(bytes)) return 'jpg';
    if (_isPng(bytes)) return 'png';
    if (_isHeic(bytes)) return 'heic';
    final lower = (sourcePath ?? '').toLowerCase();
    if (lower.endsWith('.heic') || lower.endsWith('.heif')) return 'heic';
    if (lower.endsWith('.png')) return 'png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'jpg';
    if (lower.endsWith('.webp')) return 'webp';
    if (lower.endsWith('.gif')) return 'gif';
    return 'img';
  }

  static String _nonImageExtension(List<int> bytes, String path) {
    if (_isPdf(bytes) || path.toLowerCase().endsWith('.pdf')) return 'pdf';
    final lower = path.toLowerCase();
    final dot = lower.lastIndexOf('.');
    if (dot != -1 && dot < lower.length - 1) {
      return lower.substring(dot + 1);
    }
    return 'bin';
  }

  static bool _isJpeg(List<int> bytes) =>
      bytes.length > 2 && bytes[0] == 0xFF && bytes[1] == 0xD8;

  static bool _isPng(List<int> bytes) =>
      bytes.length > 7 &&
      bytes[0] == 0x89 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x4E &&
      bytes[3] == 0x47;

  static bool _isGif(List<int> bytes) =>
      bytes.length > 5 &&
      bytes[0] == 0x47 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x38;

  static bool _isWebp(List<int> bytes) =>
      bytes.length > 11 &&
      bytes[0] == 0x52 &&
      bytes[1] == 0x49 &&
      bytes[2] == 0x46 &&
      bytes[3] == 0x46 &&
      bytes[8] == 0x57 &&
      bytes[9] == 0x45 &&
      bytes[10] == 0x42 &&
      bytes[11] == 0x50;

  static bool _isPdf(List<int> bytes) =>
      bytes.length > 3 &&
      bytes[0] == 0x25 &&
      bytes[1] == 0x50 &&
      bytes[2] == 0x44 &&
      bytes[3] == 0x46;

  static bool _isHeic(List<int> bytes) {
    if (bytes.length < 12) return false;
    final brand = String.fromCharCodes(bytes.sublist(4, 8));
    if (brand != 'ftyp') return false;
    final ftyp = String.fromCharCodes(bytes.sublist(8, 12)).toLowerCase();
    return ftyp.contains('hei') ||
        ftyp.contains('mif1') ||
        ftyp.contains('msf1') ||
        ftyp.contains('avif');
  }
}
