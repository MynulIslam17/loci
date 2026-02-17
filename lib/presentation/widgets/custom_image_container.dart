import 'dart:io';


import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class CustomCachedImage extends StatelessWidget {
  final String? imageUrl;   // ← For network or assets
  final File? imageFile;    // ← For picked/local files
  final double? height;
  final double? width;
  final double borderRadius;
  final bool isCircle;
  final BoxFit fit;

  const CustomCachedImage({
    super.key,
    this.imageUrl,      // works for image url
    this.imageFile,     // also works for file
    this.height,
    this.width,
    this.borderRadius = 12.0,
    this.isCircle = false,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {

    /// check if upload file
    if (imageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(isCircle ? 1000 : borderRadius),
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
      borderRadius: BorderRadius.circular(isCircle ? 1000 : borderRadius),
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