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
          errorBuilder: (_, __, ___) => _buildErrorWidget(),
        ),
      );
    }

    // 2. EMPTY URL
    if (imageUrl == null || imageUrl!.isEmpty) {
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: _buildErrorWidget(),
      );
    }

    final url = imageUrl!;

    // 3. NETWORK
    if (url.startsWith('http')) {
      return ClipRRect(
        borderRadius: effectiveRadius,
        child: CachedNetworkImage(
          imageUrl: url,
          height: height,
          width: width,
          fit: fit,
          placeholder: (_, __) => _buildPlaceholder(),
          errorWidget: (_, __, ___) => _buildErrorWidget(),
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
        errorBuilder: (_, __, ___) => _buildErrorWidget(),
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