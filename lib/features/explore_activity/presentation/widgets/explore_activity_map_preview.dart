import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/gen/assets.gen.dart';

/// Static map placeholder used on edit activity screens.
class ExploreActivityMapPreview extends StatelessWidget {
  const ExploreActivityMapPreview({super.key, this.height = 160});

  final double height;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        color: colorScheme.surface,
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            Assets.images.location.path,
            height: height,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
