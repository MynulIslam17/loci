import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Platform spinner: [CupertinoActivityIndicator] on iOS, Material on Android.
class AdaptiveProgress extends StatelessWidget {
  const AdaptiveProgress({
    super.key,
    this.color,
    this.strokeWidth = 2.0,
    this.radius = 10.0,
  });

  final Color? color;
  final double strokeWidth;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (context.isCupertino) {
      return CupertinoActivityIndicator(color: color, radius: radius);
    }
    return CircularProgressIndicator(
      strokeWidth: strokeWidth,
      color: color,
    );
  }
}
