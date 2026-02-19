import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  final int trimLines;

  const ExpandableText({
    super.key,
    required this.text,
    this.trimLines = 2,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          // If expanded, maxLines is null (infinite). Otherwise, use trimLines.
          maxLines: _isExpanded ? null : widget.trimLines,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: AppTextStyle.textSm(color: theme.primary),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Text(
            _isExpanded ? "See less" : "See more",
            style: AppTextStyle.textSm(
              weight: FontWeight.w700,
              color: theme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}