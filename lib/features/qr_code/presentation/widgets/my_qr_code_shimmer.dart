import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Skeleton placeholder while the user's QR code is loading.
class MyQrCodeShimmer extends StatelessWidget {
  const MyQrCodeShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme.surfaceContainerHighest;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(height: 16),
        Container(
          width: 160,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 28),
        Container(
          width: 260,
          height: 260,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ],
    );
  }
}
