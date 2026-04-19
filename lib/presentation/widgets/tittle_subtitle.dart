import 'package:flutter/material.dart';

/// A reusable Header widget that displays raffles title and raffles subtitle.
class HeaderSection extends StatelessWidget {
  final String ? title;
  final String ? subTitle;
  final TextStyle? titleStyle;
  final TextStyle? subTitleStyle;
  final double spacing;

  const HeaderSection({
    super.key,
    required this.title,
     this.subTitle,
    this.titleStyle,
    this.subTitleStyle,
    this.spacing = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title ??"",
          style: titleStyle ??
              const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
        ),
        SizedBox(height: spacing),
        if (subTitle != null)
        Text(
          subTitle! ,
          style: subTitleStyle ??
              const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}