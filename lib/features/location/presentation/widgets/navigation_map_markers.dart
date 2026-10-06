import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Small, legible map badges for the active travel mode and destination.
abstract final class NavigationMapMarkers {
  static Future<BitmapDescriptor> walking() =>
      _badge(Icons.directions_walk_rounded, const Color(0xFF2563EB));

  static Future<BitmapDescriptor> riding() =>
      _badge(Icons.two_wheeler_rounded, const Color(0xFF0F766E));

  static Future<BitmapDescriptor> destination() =>
      _badge(Icons.flag_rounded, const Color(0xFFE24A3B));

  static Future<BitmapDescriptor> _badge(IconData icon, Color color) async {
    const size = 96.0;
    const center = Offset(size / 2, size / 2);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawCircle(
      center + const Offset(0, 2),
      42,
      Paint()
        ..color = const Color(0x44000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(center, 42, Paint()..color = Colors.white);
    canvas.drawCircle(center, 36, Paint()..color = color);

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          fontSize: 44,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(
      canvas,
      Offset(
        center.dx - iconPainter.width / 2,
        center.dy - iconPainter.height / 2,
      ),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    picture.dispose();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (bytes == null) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure);
    }
    return BitmapDescriptor.bytes(
      bytes.buffer.asUint8List(),
      imagePixelRatio: 2,
    );
  }
}
