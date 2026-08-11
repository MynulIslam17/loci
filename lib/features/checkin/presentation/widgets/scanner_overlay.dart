import 'package:flutter/material.dart';

/// Viewfinder decoration drawn on top of the camera preview: four rounded
/// corner brackets plus a soft scan line that sweeps up and down.
///
/// Purely decorative — it sizes itself to its parent, so wrap it in a
/// fixed-size box (the scanner frame).
class ScannerOverlay extends StatefulWidget {
  const ScannerOverlay({
    super.key,
    this.color,
    this.cornerLength = 30,
    this.strokeWidth = 4,
    this.radius = 24,
  });

  final Color? color;
  final double cornerLength;
  final double strokeWidth;
  final double radius;

  @override
  State<ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.primary;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Corner brackets.
            Positioned.fill(
              child: CustomPaint(
                painter: _CornerBracketPainter(
                  color: color,
                  cornerLength: widget.cornerLength,
                  strokeWidth: widget.strokeWidth,
                  radius: widget.radius,
                ),
              ),
            ),
            // Sweeping scan line.
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final travel = (constraints.maxHeight - widget.strokeWidth)
                    .clamp(0.0, double.infinity);
                return Positioned(
                  top: _controller.value * travel,
                  left: 16,
                  right: 16,
                  child: Container(
                    height: 2.5,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0),
                          color,
                          color.withValues(alpha: 0),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.6),
                          blurRadius: 10,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  _CornerBracketPainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
    required this.radius,
  });

  final Color color;
  final double cornerLength;
  final double strokeWidth;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final r = radius;
    final l = cornerLength;
    final w = size.width;
    final h = size.height;

    // Top-left
    canvas.drawPath(
      Path()
        ..moveTo(0, r + l)
        ..lineTo(0, r)
        ..arcToPoint(Offset(r, 0), radius: Radius.circular(r))
        ..lineTo(r + l, 0),
      paint,
    );
    // Top-right
    canvas.drawPath(
      Path()
        ..moveTo(w - r - l, 0)
        ..lineTo(w - r, 0)
        ..arcToPoint(Offset(w, r), radius: Radius.circular(r))
        ..lineTo(w, r + l),
      paint,
    );
    // Bottom-right
    canvas.drawPath(
      Path()
        ..moveTo(w, h - r - l)
        ..lineTo(w, h - r)
        ..arcToPoint(Offset(w - r, h), radius: Radius.circular(r))
        ..lineTo(w - r - l, h),
      paint,
    );
    // Bottom-left
    canvas.drawPath(
      Path()
        ..moveTo(r + l, h)
        ..lineTo(r, h)
        ..arcToPoint(Offset(0, h - r), radius: Radius.circular(r))
        ..lineTo(0, h - r - l),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CornerBracketPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.cornerLength != cornerLength ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.radius != radius;
}
