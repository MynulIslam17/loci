import 'package:flutter/material.dart';

import '../../core/constants/app_text_style.dart';
import '../../core/theme/theme_extention.dart';

class PostInteractionBar extends StatelessWidget {
  final String likes;
  final String comments;

  /// Optional callbacks for future functionality
  final VoidCallback? onLikeTap;
  final VoidCallback? onCommentTap;

  const PostInteractionBar({
    super.key,
    required this.likes,
    required this.comments,
    this.onLikeTap,
    this.onCommentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        /// Like button
        _buildItem(
          context,
          icon: Icons.favorite_border,
          label: likes,
          onTap: onLikeTap ?? () {
            // For now, just show a simple feedback
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Like tapped")),
            );
          },
        ),

        const SizedBox(width: 16),

        /// Comment button
        _buildItem(
          context,
          icon: Icons.chat_bubble_outline,
          label: comments,
          onTap: onCommentTap ?? () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Comment tapped")),
            );
          },
        ),
      ],
    );
  }

  /// Builds a single icon + label button
  Widget _buildItem(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: context.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyle.textXs(
                weight: FontWeight.w700,
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}