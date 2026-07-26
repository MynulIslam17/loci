import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Data model for each part of the rich text
class TextPart {
  final String text;
  final TextStyle? style;
  final VoidCallback? onTap;

  TextPart({
    required this.text,
    this.style,
    this.onTap,
  });
}

class CustomRichText extends StatelessWidget {
  final List<TextPart> parts;
  final TextStyle? defaultStyle;
  final TextAlign textAlign;
  final int? maxLines;
  final TextOverflow overflow;

  const CustomRichText({
    super.key,
    required this.parts,
    this.defaultStyle,
    this.textAlign = TextAlign.start,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(
        // Default style for the whole block
        style: defaultStyle ?? Theme.of(context).textTheme.bodyMedium,
        children: parts.map((part) {
          return TextSpan(
            text: part.text,
            style: part.style,
            // Only add recognizer if onTap is provided
            recognizer: part.onTap != null
                ? (TapGestureRecognizer()..onTap = part.onTap)
                : null,
          );
        }).toList(),
      ),
    );
  }
}