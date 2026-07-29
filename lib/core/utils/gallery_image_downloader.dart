import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:gal/gal.dart';

/// Saves a remote image to the device gallery.
class GalleryImageDownloader {
  GalleryImageDownloader._();

  static Future<void> saveNetworkImage(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      throw Exception('No image to download');
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) {
      throw Exception('Invalid image URL');
    }

    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw Exception('Could not download image');
      }

      final bytes = await consolidateHttpClientResponseBytes(response);

      var hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        hasAccess = await Gal.requestAccess();
      }
      if (!hasAccess) {
        throw Exception('Gallery access denied');
      }

      await Gal.putImageBytes(bytes);
    } finally {
      client.close();
    }
  }
}
