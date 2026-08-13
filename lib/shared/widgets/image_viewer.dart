import 'dart:io';
import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Copy this file to reuse fullscreen image preview in another Flutter app.
///
/// Optional dependency: `cached_network_image`.
///
/// Close: X button, vertical swipe (when not zoomed), or tap backdrop.
/// Pinch freely in any direction — dismiss never steals the scale gesture.
void showImageViewer(
  BuildContext context, {
  File? imageFile,
  String? imageUrl,
  String? heroTag,
}) {
  final hasFile = imageFile != null;
  final hasUrl = imageUrl != null && imageUrl.trim().isNotEmpty;
  if (!hasFile && !hasUrl) return;

  Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: ImageViewerPage(
            imageFile: imageFile,
            imageUrl: hasUrl ? imageUrl.trim() : null,
            heroTag: heroTag,
          ),
        );
      },
    ),
  );
}

class ImageViewerPage extends StatefulWidget {
  const ImageViewerPage({
    super.key,
    this.imageFile,
    this.imageUrl,
    this.heroTag,
  });

  final File? imageFile;
  final String? imageUrl;
  final String? heroTag;

  @override
  State<ImageViewerPage> createState() => _ImageViewerPageState();
}

class _ImageViewerPageState extends State<ImageViewerPage> {
  static const double _dismissDistance = 140;

  late final TransformationController _transform;

  double _bgOpacity = 1;
  bool _dismissing = false;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _transform = TransformationController()..addListener(_onTransformChanged);
  }

  @override
  void dispose() {
    _transform.removeListener(_onTransformChanged);
    _transform.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final scale = _transform.value.getMaxScaleOnAxis();
    final zoomed = scale > 1.02;
    if (zoomed != _isZoomed && mounted) {
      setState(() => _isZoomed = zoomed);
    }
  }

  Future<void> _close() async {
    if (_dismissing || !mounted) return;
    _dismissing = true;
    HapticFeedback.lightImpact();
    await Navigator.of(context).maybePop();
  }

  /// Swipe-to-dismiss is driven by InteractiveViewer's own pan matrix when
  /// scale ≈ 1. No parent [GestureDetector] — that steals vertical pinch.
  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (_dismissing) return;
    final scale = _transform.value.getMaxScaleOnAxis();
    if (scale > 1.02 || details.pointerCount > 1) {
      if (_bgOpacity != 1) setState(() => _bgOpacity = 1);
      return;
    }

    final ty = _transform.value.getTranslation().y;
    final progress = (ty.abs() / _dismissDistance).clamp(0.0, 1.0);
    final next = 1 - (progress * 0.55);
    if ((next - _bgOpacity).abs() > 0.01) {
      setState(() => _bgOpacity = next);
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    if (_dismissing) return;
    final scale = _transform.value.getMaxScaleOnAxis();

    if (scale > 1.02) {
      if (_bgOpacity != 1) setState(() => _bgOpacity = 1);
      return;
    }

    final ty = _transform.value.getTranslation().y;
    final vy = details.velocity.pixelsPerSecond.dy;
    final shouldDismiss = ty.abs() > _dismissDistance || vy.abs() > 900;

    if (shouldDismiss) {
      _close();
      return;
    }

    // Snap back to centered, unzoomed.
    _transform.value = Matrix4.identity();
    if (_bgOpacity != 1) setState(() => _bgOpacity = 1);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = math.max(16.0, MediaQuery.paddingOf(context).bottom + 8);

    Widget image;
    if (widget.imageFile != null) {
      image = Image.file(
        widget.imageFile!,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) => _errorBody(),
      );
    } else {
      image = CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) => const SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
        ),
        errorWidget: (context, url, error) => _errorBody(),
      );
    }

    if (widget.heroTag != null) {
      image = Hero(tag: widget.heroTag!, child: image);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.92 * _bgOpacity),
        body: Stack(
          children: [
            // Tap empty area to close (does not wrap InteractiveViewer).
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _isZoomed ? null : _close,
                child: const SizedBox.expand(),
              ),
            ),
            Positioned.fill(
              child: InteractiveViewer(
                transformationController: _transform,
                minScale: 1,
                maxScale: 5,
                // Always allow pan so vertical swipe-dismiss + pinch both work
                // inside InteractiveViewer (no competing parent drag).
                panEnabled: true,
                scaleEnabled: true,
                clipBehavior: Clip.none,
                boundaryMargin: const EdgeInsets.all(80),
                onInteractionUpdate: _onInteractionUpdate,
                onInteractionEnd: _onInteractionEnd,
                child: Center(child: image),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: IconButton(
                    tooltip: 'Close',
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _close,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomPad,
              child: IgnorePointer(
                child: AnimatedOpacity(
                  opacity: _isZoomed ? 0 : 1,
                  duration: const Duration(milliseconds: 160),
                  child: const Text(
                    'Swipe up or down to close · Pinch to zoom',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _errorBody() {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.broken_image_outlined, color: Colors.white70, size: 48),
        SizedBox(height: 12),
        Text(
          'Could not load image',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
