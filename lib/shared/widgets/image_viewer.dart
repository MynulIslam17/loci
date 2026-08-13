import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';

/// Opens a fullscreen, pinch-to-zoom viewer when [imageFile] or [imageUrl] is set.
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
      barrierColor: Colors.black.withValues(alpha: 0.92),
      transitionDuration: const Duration(milliseconds: 220),
      reverseTransitionDuration: const Duration(milliseconds: 180),
      pageBuilder: (context, animation, secondaryAnimation) {
        return FadeTransition(
          opacity: animation,
          child: _ImageViewerPage(
            imageFile: imageFile,
            imageUrl: hasUrl ? imageUrl.trim() : null,
            heroTag: heroTag,
          ),
        );
      },
    ),
  );
}

class _ImageViewerPage extends StatelessWidget {
  const _ImageViewerPage({
    this.imageFile,
    this.imageUrl,
    this.heroTag,
  });

  final File? imageFile;
  final String? imageUrl;
  final String? heroTag;

  @override
  Widget build(BuildContext context) {
    final image = _buildImage();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: heroTag == null
                        ? image
                        : Hero(tag: heroTag!, child: image),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                tooltip: 'Close',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black45,
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Text(
                'Pinch to zoom · Tap to close',
                textAlign: TextAlign.center,
                style: AppTextStyle.textXs(
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageFile != null) {
      return Image.file(
        imageFile!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const _ViewerError(),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      fit: BoxFit.contain,
      placeholder: (_, __) => const SizedBox(
        width: 48,
        height: 48,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
      errorWidget: (_, __, ___) => const _ViewerError(),
    );
  }
}

class _ViewerError extends StatelessWidget {
  const _ViewerError();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.broken_image_outlined, color: Colors.white70, size: 48),
        const SizedBox(height: 12),
        Text(
          'Could not load image',
          style: AppTextStyle.textSm(color: Colors.white70),
        ),
      ],
    );
  }
}
