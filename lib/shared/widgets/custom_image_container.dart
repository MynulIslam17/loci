import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CustomCachedImage extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final double? height;
  final double? width;
  final double borderRadius;
  final bool isCircle;
  final BoxFit fit;
  // --- ADDED PARAMETER ---
  final BorderRadius? customBorderRadius;

  /// Asset shown when there is no image (null/empty url) or loading fails,
  /// instead of the default broken-image placeholder.
  final String? fallbackAsset;

  /// Neutral icon placeholder shown when there is no image / loading fails.
  /// Used when no [fallbackAsset] is given. Reads as "no image" rather than
  /// an error.
  final IconData? fallbackIcon;
  final String? cacheKey;

  const CustomCachedImage({
    super.key,
    this.imageUrl,
    this.imageFile,
    this.height,
    this.width,
    this.borderRadius = 12.0,
    this.isCircle = false,
    this.fit = BoxFit.cover,
    this.customBorderRadius,
    this.fallbackAsset,
    this.fallbackIcon,
    this.cacheKey,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = customBorderRadius ??
        BorderRadius.circular(isCircle ? 1000 : borderRadius);

    // 1. FILE
    if (imageFile != null) {
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: Image.file(
          imageFile!,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (_, __, ___) => _buildFallback(),
        ),
      );
    }

    // 2. EMPTY URL
    if (imageUrl == null || imageUrl!.isEmpty) {
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: _buildFallback(),
      );
    }

    final url = imageUrl!;

    // 3. NETWORK
    if (url.startsWith('http')) {
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: CachedNetworkImage(
          imageUrl: url,
          cacheKey: cacheKey,
          height: height,
          width: width,
          fit: fit,
          placeholder: (_, __) => _buildPlaceholder(),
          errorWidget: (_, __, ___) => _buildFallback(),
        ),
      );
    }

    // 4. ASSET (fallback)
    return ClipRRect(
      borderRadius: effectiveRadius,
      child: Image.asset(
        url,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, __, ___) => _buildFallback(),
      ),
    );
  }

  /// Fallback precedence: [fallbackAsset] → [fallbackIcon] placeholder →
  /// broken-image box. The fallback asset itself degrades to the box if
  /// missing.
  Widget _buildFallback() {
    final fb = fallbackAsset;
    if (fb != null && fb.isNotEmpty) {
      return Image.asset(
        fb,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, _, _) => _buildErrorWidget(),
      );
    }
    if (fallbackIcon != null) return _buildIconPlaceholder(fallbackIcon!);
    return _buildErrorWidget();
  }

  /// Neutral grey placeholder with a centered icon (not an error state).
  Widget _buildIconPlaceholder(IconData icon) {
    final side = (height != null && width != null)
        ? (height! < width! ? height! : width!)
        : (height ?? width);
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      color: Colors.grey.shade200,
      child: Icon(
        icon,
        color: Colors.grey.shade500,
        size: side != null ? side * 0.5 : 20,
      ),
    );
  }

  // Helper for Shimmer placeholder
  Widget _buildPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      direction: ShimmerDirection.rtl,
      child: Container(
        height: height,
        width: width,
        color: Colors.white,
      ),
    );
  }

  // Helper for Error widget
  Widget _buildErrorWidget() {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[200],
      child: const Icon(Icons.broken_image, color: Colors.grey),
    );
  }
}