import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

/// A reusable stateless widget that loads and displays an image from a URL
/// requiring an access token (Authorization header).
///
/// Handles loading state with shimmer, error states using [ErrorStateWidget],
/// and empty states using [EmptyState].
///
/// When [latitude] and [longitude] are provided, tapping the image opens
/// the native maps app (Apple Maps on iOS, Google Maps on Android).
class AuthenticatedMapImage extends StatelessWidget {
  AuthenticatedMapImage({
    super.key,
    required this.imageUrl,
    this.height = 180,
    this.width,
    this.borderRadius = 16.0,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.map_outlined,
    this.showRetry = true,
    this.latitude,
    this.longitude,
    this.locationLabel,
  });

  /// The URL that requires auth to fetch the image.
  final String? imageUrl;

  /// Fixed height for the image container.
  final double height;

  /// Optional width. Defaults to [double.infinity].
  final double? width;

  /// Corner radius for clipping.
  final double borderRadius;

  /// How the image should be inscribed into the container.
  final BoxFit fit;

  /// Icon shown when the image fails to load or URL is null/empty.
  final IconData fallbackIcon;

  /// Whether to show a retry button on error.
  final bool showRetry;

  /// Latitude for opening native maps on tap.
  final double? latitude;

  /// Longitude for opening native maps on tap.
  final double? longitude;

  /// Optional label shown as a marker name in the maps app.
  final String? locationLabel;

  /// Notifier to trigger a refetch without using setState.
  final ValueNotifier<int> _reloadSignal = ValueNotifier<int>(0);

  bool get _hasCoordinates =>
      latitude != null &&
      longitude != null &&
      (latitude != 0.0 || longitude != 0.0);

  Future<Uint8List?> _fetchImage() async {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) {
      return null;
    }

    String token = '';
    if (Get.isRegistered<AuthController>()) {
      token = Get.find<AuthController>().accessToken ?? '';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load map image');
    }
  }

  Future<void> _openInMaps() async {
    if (!_hasCoordinates) return;

    final lat = latitude!;
    final lng = longitude!;
    final label = Uri.encodeComponent(locationLabel ?? 'Location');

    Uri? mapUri;

    if (Platform.isIOS) {
      mapUri = Uri.parse('https://maps.apple.com/?ll=$lat,$lng&q=$label');
    } else if (Platform.isAndroid) {
      mapUri = Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)');
    } else {
      mapUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
    }

    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    } else {
      final fallbackUri = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
      );
      await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final effectiveWidth = width ?? double.infinity;
    final url = imageUrl?.trim();

    Widget content;

    // Handle Empty State when URL is null or empty
    if (url == null || url.isEmpty) {
      content = Container(
        color: colors.surfaceContainerHighest,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: EmptyState(
            icon: fallbackIcon,
            title: 'No Map Image',
            subtitle: 'Map preview is unavailable for this location',
            iconSize: 24,
          ),
        ),
      );
    } else {
      content = ValueListenableBuilder<int>(
        valueListenable: _reloadSignal,
        builder: (context, value, child) {
          return FutureBuilder<Uint8List?>(
            future: _fetchImage(),
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer.fromColors(
                  baseColor: colors.surfaceContainerHighest,
                  highlightColor: colors.surfaceContainerHigh,
                  child: Container(
                    color: colors.surfaceContainerHighest,
                  ),
                );
              }

              // Error state
              if (snapshot.hasError || snapshot.data == null) {
                return Container(
                  color: colors.surfaceContainerHighest,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ErrorStateWidget(
                      message: snapshot.error?.toString() ??
                          'Failed to load map image',
                      icon: fallbackIcon,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      onRetry: showRetry
                          ? () => _reloadSignal.value++
                          : null,
                    ),
                  ),
                );
              }

              // Success state
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.memory(
                    snapshot.data!,
                    height: height,
                    width: effectiveWidth,
                    fit: fit,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: colors.surfaceContainerHighest,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ErrorStateWidget(
                          message: 'Failed to display map image',
                          icon: fallbackIcon,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          onRetry: showRetry
                              ? () => _reloadSignal.value++
                              : null,
                        ),
                      ),
                    ),
                  ),
                  if (_hasCoordinates)
                    Positioned(
                      right: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.open_in_new,
                              size: 12,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Open in Maps',
                              style: AppTextStyle.textXs(
                                color: Colors.white,
                                weight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      );
    }

    Widget result = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: effectiveWidth,
        child: content,
      ),
    );

    if (_hasCoordinates) {
      result = GestureDetector(
        onTap: _openInMaps,
        child: result,
      );
    }

    return result;
  }
}
