import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

/// Loads a static map preview and opens Apple/Google Maps on tap.
///
/// Uses the `mapImage` URL from the backend as-is. Signed URLs (`sig` + `exp`)
/// are loaded without a Bearer token.
class AuthenticatedMapImage extends StatelessWidget {
  const AuthenticatedMapImage({
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

  final String? imageUrl;
  final double height;
  final double? width;
  final double borderRadius;
  final BoxFit fit;
  final IconData fallbackIcon;
  final bool showRetry;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;

  bool get _hasCoordinates =>
      latitude != null &&
      longitude != null &&
      (latitude != 0.0 || longitude != 0.0);

  Future<void> _openInMaps() async {
    if (!_hasCoordinates) return;

    final lat = latitude!;
    final lng = longitude!;

    // 1. Request/verify location permission from the device
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        final status = await Permission.locationWhenInUse.status;
        if (!status.isGranted && !status.isPermanentlyDenied) {
          await Permission.locationWhenInUse.request();
        }
      }
    } catch (_) {}

    try {
      if (Platform.isIOS) {
        // iOS Directions: Explicitly specify 'saddr=Current+Location' so Apple Maps
        // uses the user's current GPS location to plot the turn-by-turn route to destination.
        final appleMapsScheme = Uri.parse(
          'maps://?saddr=Current+Location&daddr=$lat,$lng&dirflg=d',
        );
        if (await canLaunchUrl(appleMapsScheme)) {
          await launchUrl(appleMapsScheme, mode: LaunchMode.externalApplication);
          return;
        }

        // Fallback: Apple Maps HTTPS Universal link
        final appleMapsWeb = Uri.parse(
          'https://maps.apple.com/?saddr=Current+Location&daddr=$lat,$lng&dirflg=d',
        );
        if (await canLaunchUrl(appleMapsWeb)) {
          await launchUrl(appleMapsWeb, mode: LaunchMode.externalApplication);
          return;
        }

        // Fallback: Google Maps Universal Directions
        final googleMapsWeb = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
        );
        await launchUrl(googleMapsWeb, mode: LaunchMode.externalApplication);
      } else {
        // Android & Web Directions:
        // 1. Try Google Maps Native Navigation intent (prompts for current location & launches turn-by-turn)
        final googleNavUri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
        if (await canLaunchUrl(googleNavUri)) {
          await launchUrl(googleNavUri, mode: LaunchMode.externalApplication);
          return;
        }

        // 2. Google Maps Universal directions API URL
        final googleMapsUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
        );
        if (await canLaunchUrl(googleMapsUri)) {
          await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        } else {
          await launchUrl(
            googleMapsUri,
            mode: LaunchMode.externalNonBrowserApplication,
          );
        }
      }
    } catch (_) {
      // Resilient fallback to universal web directions
      final fallbackUri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
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
    if (url == null || url.isEmpty) {
      content = _MapFallbackCard(
        icon: fallbackIcon,
        title: locationLabel?.trim().isNotEmpty == true
            ? locationLabel!
            : (_hasCoordinates ? 'View location' : 'Map unavailable'),
        subtitle: _hasCoordinates ? 'Get directions' : null,
        colors: colors,
      );
    } else {
      content = CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: effectiveWidth,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 180),
        placeholder: (_, _) => ColoredBox(color: colors.surfaceContainerHighest),
        errorWidget: (_, _, _) => _MapFallbackCard(
          icon: fallbackIcon,
          title: locationLabel?.trim().isNotEmpty == true
              ? locationLabel!
              : (_hasCoordinates ? 'View location' : 'Couldn\'t load map'),
          subtitle: _hasCoordinates ? 'Get directions' : null,
          colors: colors,
        ),
        imageBuilder: (context, imageProvider) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Image(
                image: imageProvider,
                height: height,
                width: effectiveWidth,
                fit: fit,
              ),
              if (_hasCoordinates)
                const Positioned(
                  right: 8,
                  bottom: 8,
                  child: _OpenInMapsChip(),
                ),
            ],
          );
        },
      );
    }

    Widget result = Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      color: colors.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        side: BorderSide(color: colors.outlineVariant),
      ),
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

class _OpenInMapsChip extends StatelessWidget {
  const _OpenInMapsChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions, size: 13, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            'Directions',
            style: AppTextStyle.textXs(
              color: Colors.white,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MapFallbackCard extends StatelessWidget {
  const _MapFallbackCard({
    required this.icon,
    required this.title,
    required this.colors,
    this.subtitle,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primary.withValues(alpha: 0.08),
            colors.surfaceContainerHighest,
            colors.primary.withValues(alpha: 0.04),
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: colors.outlineVariant),
                ),
                child: Icon(icon, size: 22, color: colors.primary),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.textSm(
                  color: colors.onSurface,
                  weight: FontWeight.w600,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: AppTextStyle.textXs(
                    color: colors.primary,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
