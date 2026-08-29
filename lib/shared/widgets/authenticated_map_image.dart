import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/navigation/utils/live_navigation_launcher.dart';

/// Loads a static map preview and opens In-App Live Route Navigation on tap.
///
/// Handles network loading states with an animated, modern map skeleton placeholder
/// so the widget never looks blank or jarring while fetching details.
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
    this.isLoading = false,
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
  final bool isLoading;

  (double, double)? get _resolvedCoordinates {
    if (latitude != null &&
        longitude != null &&
        (latitude != 0.0 || longitude != 0.0)) {
      return (latitude!, longitude!);
    }
    return _extractCoordinatesFromUrl(imageUrl);
  }

  bool get _hasCoordinates => _resolvedCoordinates != null;

  Future<void> _openInMaps() async {
    final coords = _resolvedCoordinates;
    if (coords == null) return;

    LiveNavigationLauncher.open(
      latitude: coords.$1,
      longitude: coords.$2,
      title: locationLabel?.trim().isNotEmpty == true
          ? locationLabel!
          : 'Event Location',
      locationLabel: locationLabel,
    );
  }

  /// Extracts coordinates from static map URLs (e.g. center=23.79,90.40 or markers=23.79,90.40)
  static (double, double)? _extractCoordinatesFromUrl(String? url) {
    if (url == null || url.trim().isEmpty) return null;
    try {
      final uri = Uri.tryParse(url.trim());
      if (uri != null) {
        final center = uri.queryParameters['center'];
        if (center != null && center.contains(',')) {
          final parts = center.split(',');
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null && (lat != 0 || lng != 0)) {
            return (lat, lng);
          }
        }

        final markers = uri.queryParameters['markers'] ?? uri.queryParameters['marker'];
        if (markers != null) {
          final regex = RegExp(r'(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)');
          final match = regex.firstMatch(markers);
          if (match != null) {
            final lat = double.tryParse(match.group(1)!);
            final lng = double.tryParse(match.group(2)!);
            if (lat != null && lng != null && (lat != 0 || lng != 0)) {
              return (lat, lng);
            }
          }
        }
      }
    } catch (_) {}
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final effectiveWidth = width ?? double.infinity;
    final url = imageUrl?.trim();

    Widget content;
    if (isLoading) {
      content = _MapLoadingSkeleton(
        colors: colors,
        locationLabel: locationLabel,
      );
    } else if (url == null || url.isEmpty) {
      content = _MapFallbackCard(
        icon: fallbackIcon,
        title: locationLabel?.trim().isNotEmpty == true
            ? locationLabel!
            : (_hasCoordinates ? 'View location' : 'Map preview unavailable'),
        subtitle: _hasCoordinates ? 'Tap to start live navigation' : null,
        colors: colors,
      );
    } else {
      content = CachedNetworkImage(
        imageUrl: url,
        height: height,
        width: effectiveWidth,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 250),
        placeholder: (_, _) => _MapLoadingSkeleton(
          colors: colors,
          locationLabel: locationLabel,
        ),
        errorWidget: (_, _, _) => _MapFallbackCard(
          icon: fallbackIcon,
          title: locationLabel?.trim().isNotEmpty == true
              ? locationLabel!
              : (_hasCoordinates ? 'View location' : 'Map preview unavailable'),
          subtitle: _hasCoordinates ? 'Tap to start live navigation' : null,
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
                  right: 10,
                  bottom: 10,
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
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.7)),
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

/// Modern Animated Loading Skeleton for Map Preview
class _MapLoadingSkeleton extends StatefulWidget {
  const _MapLoadingSkeleton({
    required this.colors,
    this.locationLabel,
  });

  final ColorScheme colors;
  final String? locationLabel;

  @override
  State<_MapLoadingSkeleton> createState() => _MapLoadingSkeletonState();
}

class _MapLoadingSkeletonState extends State<_MapLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.colors;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final shimmerValue = _controller.value;

        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colors.surfaceContainerHighest.withValues(alpha: 0.9),
                Color.lerp(
                  colors.surfaceContainerHighest,
                  colors.primary.withValues(alpha: 0.12),
                  shimmerValue,
                )!,
                colors.surfaceContainerHighest.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Subtle background map road grid lines
              CustomPaint(
                painter: _MapGridPatternPainter(
                  color: colors.onSurface.withValues(alpha: 0.05 + (shimmerValue * 0.03)),
                ),
              ),

              // Centered Pulsing Location Pin with Glow Halo
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft Outer Pulse Halo
                        Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.primary.withValues(alpha: 0.18 * (1.2 - shimmerValue)),
                            ),
                          ),
                        ),
                        // Inner Pin Base
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colors.surface,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            color: colors.primary,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Loading Badge with micro spinner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors.surface.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 10,
                            height: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.8,
                              color: colors.primary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            widget.locationLabel?.trim().isNotEmpty == true
                                ? 'Loading map...'
                                : 'Preparing map preview...',
                            style: AppTextStyle.textXs(
                              color: colors.onSurface.withValues(alpha: 0.8),
                              weight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom painter to draw subtle decorative map road curves in the skeleton
class _MapGridPatternPainter extends CustomPainter {
  const _MapGridPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Road 1: diagonal curve
    final path1 = Path()
      ..moveTo(0, size.height * 0.3)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.6,
        size.height * 0.7,
        size.width,
        size.height * 0.6,
      );
    canvas.drawPath(path1, paint);

    // Road 2: cross road
    final path2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..cubicTo(
        size.width * 0.25,
        size.height * 0.4,
        size.width * 0.75,
        size.height * 0.6,
        size.width * 0.8,
        size.height,
      );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant _MapGridPatternPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _OpenInMapsChip extends StatelessWidget {
  const _OpenInMapsChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.navigation_rounded, size: 13, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            'Live Navigate',
            style: AppTextStyle.textXs(
              color: Colors.white,
              weight: FontWeight.w700,
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.navigation_rounded, size: 12, color: colors.primary),
                      const SizedBox(width: 4),
                      Text(
                        subtitle!,
                        style: AppTextStyle.textXs(
                          color: colors.primary,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ],
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
