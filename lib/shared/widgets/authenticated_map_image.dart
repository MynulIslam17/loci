import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:url_launcher/url_launcher.dart';

/// Loads a static map preview.
///
/// Backend `mapImage` URLs are **signed** (`sig` + `exp` in the query). They
/// must be fetched without an Authorization header — iOS NSURLSession forwards
/// Bearer tokens across redirects, which makes S3/CloudFront reject the image
/// (Android OkHttp typically does not, so this looked iOS-only).
class AuthenticatedMapImage extends StatefulWidget {
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

  @override
  State<AuthenticatedMapImage> createState() => _AuthenticatedMapImageState();
}

class _AuthenticatedMapImageState extends State<AuthenticatedMapImage> {
  Future<Uint8List?>? _future;
  String? _requestedUrl;

  bool get _hasCoordinates =>
      widget.latitude != null &&
      widget.longitude != null &&
      (widget.latitude != 0.0 || widget.longitude != 0.0);

  @override
  void initState() {
    super.initState();
    _requestedUrl = widget.imageUrl?.trim();
    _future = _fetchImage(_requestedUrl);
  }

  @override
  void didUpdateWidget(covariant AuthenticatedMapImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final url = widget.imageUrl?.trim();
    if (url != _requestedUrl) {
      _requestedUrl = url;
      _future = _fetchImage(url);
    }
  }

  bool _isSignedUrl(Uri uri) {
    return uri.queryParameters.containsKey('sig') ||
        uri.path.contains('/map');
  }

  Future<Uint8List?> _fetchImage(String? rawUrl) async {
    final url = rawUrl?.trim();
    if (url == null || url.isEmpty) return null;

    final uri = Uri.parse(url);
    final signed = _isSignedUrl(uri);

    String token = '';
    if (Get.isRegistered<AuthController>()) {
      token = Get.find<AuthController>().accessToken ?? '';
    }

    Future<http.Response> get({required bool withAuth}) {
      return http
          .get(
            uri,
            headers: {
              'Accept': 'image/png,image/jpeg,image/*,*/*',
              if (withAuth && token.isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));
    }

    // Signed map URLs prove access via `sig` — never send a Bearer token.
    var response = await get(withAuth: !signed && token.isNotEmpty);

    if (!signed &&
        token.isNotEmpty &&
        (response.statusCode == 401 || response.statusCode == 403)) {
      response = await get(withAuth: false);
    }

    if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
      return response.bodyBytes;
    }
    throw Exception('map_image_${response.statusCode}');
  }

  void _retry() {
    setState(() {
      _future = _fetchImage(_requestedUrl);
    });
  }

  Future<void> _openInMaps() async {
    if (!_hasCoordinates) return;

    final lat = widget.latitude!;
    final lng = widget.longitude!;
    final label = Uri.encodeComponent(widget.locationLabel ?? 'Location');

    final mapUri = Platform.isIOS
        ? Uri.parse('https://maps.apple.com/?ll=$lat,$lng&q=$label')
        : Platform.isAndroid
            ? Uri.parse('geo:$lat,$lng?q=$lat,$lng($label)')
            : Uri.parse(
                'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
              );

    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(
        Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        ),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final effectiveWidth = widget.width ?? double.infinity;
    final url = widget.imageUrl?.trim();

    Widget content;
    if (url == null || url.isEmpty) {
      content = _MapPlaceholder(
        icon: widget.fallbackIcon,
        label: 'Map unavailable',
        colors: colors,
      );
    } else {
      content = FutureBuilder<Uint8List?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ColoredBox(color: colors.surfaceContainerHighest);
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _MapPlaceholder(
              icon: widget.fallbackIcon,
              label: 'Couldn\'t load map',
              colors: colors,
              onRetry: widget.showRetry ? _retry : null,
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(
                snapshot.data!,
                height: widget.height,
                width: effectiveWidth,
                fit: widget.fit,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) => _MapPlaceholder(
                  icon: widget.fallbackIcon,
                  label: 'Couldn\'t load map',
                  colors: colors,
                  onRetry: widget.showRetry ? _retry : null,
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
    }

    Widget result = ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        height: widget.height,
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

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({
    required this.icon,
    required this.label,
    required this.colors,
    this.onRetry,
  });

  final IconData icon;
  final String label;
  final ColorScheme colors;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: colors.surfaceContainerHighest,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: colors.onSurfaceVariant),
            const SizedBox(height: 6),
            Text(
              label,
              style: AppTextStyle.textXs(color: colors.onSurfaceVariant),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onRetry,
                child: Text(
                  'Retry',
                  style: AppTextStyle.textXs(
                    color: colors.primary,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
