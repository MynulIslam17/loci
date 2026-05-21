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
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: widget.text,
            style: AppTextStyle.textSm(color: theme.primary),
          ),
          maxLines: widget.trimLines,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout(maxWidth: constraints.maxWidth);

        final isLongText = textPainter.didExceedMaxLines;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: isExpanded ? null : widget.trimLines,
              overflow:
              isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: AppTextStyle.textSm(color: theme.primary),
            ),

            if (isLongText)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    isExpanded ? "See less" : "See more",
                    style: AppTextStyle.textSm(
                      weight: FontWeight.w700,
                      color: theme.onSurface,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}