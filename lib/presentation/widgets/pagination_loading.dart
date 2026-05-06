import 'package:flutter/material.dart';

class PaginationLoader extends StatelessWidget {
  final double size;
  final double padding;
  final Color? color;
  final double strokeWidth;

  const PaginationLoader({
    super.key,
    this.size = 24,
    this.padding = 16,
    this.color,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? Theme.of(context).colorScheme.primary;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Center(
        child: SizedBox(
          height: size,
          width: size,
          child: CircularProgressIndicator(
            strokeWidth: strokeWidth,
            color: themeColor,
          ),
        ),
      ),
    );
  }
}