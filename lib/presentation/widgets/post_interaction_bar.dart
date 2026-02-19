import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_text_style.dart';
import '../../core/theme/theme_extention.dart';

class PostInteractionBar extends StatelessWidget {
  final String likes;
  final String comments;

  const PostInteractionBar({super.key, required this.likes, required this.comments});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildItem(context, Icons.favorite_border, likes),
        const SizedBox(width: 16),
        _buildItem(context, Icons.chat_bubble_outline, comments),
      ],
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyle.textXs(weight: FontWeight.w700, color: context.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}