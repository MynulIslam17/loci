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
    this.customBorderRadius, // Initialize it here
  });

  @override
  Widget build(BuildContext context) {
    // Logic to determine which radius to use
    final effectiveRadius = customBorderRadius ??
        BorderRadius.circular(isCircle ? 1000 : borderRadius);

    /// check if upload file
    if (imageFile != null) {
      return ClipRRect(
        borderRadius: effectiveRadius, // Updated
        child: Image.file(
          imageFile!,
          height: height,
          width: width,
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
        ),
      );
    }

    /// Handle asset or network
    final bool isAsset = imageUrl?.startsWith('assets/') == true;

    return ClipRRect(
      borderRadius: effectiveRadius, // Updated
      child: isAsset
          ? Image.asset(
        imageUrl!,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
      )
          : CachedNetworkImage(
        imageUrl: imageUrl ?? '',
        height: height,
        width: width,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) => _buildErrorWidget(),
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