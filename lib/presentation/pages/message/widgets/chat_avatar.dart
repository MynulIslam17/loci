import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';

/// Circular chat avatar: shows the user's photo when available, otherwise a
/// colored initials circle. Optionally overlays an online indicator dot.
class ChatAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final double size;
  final bool showOnlineDot;

  const ChatAvatar({
    super.key,
    required this.name,
    this.avatarUrl,
    this.size = 48,
    this.showOnlineDot = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final hasImage = avatarUrl != null && avatarUrl!.isNotEmpty;

    return Stack(
      children: [
        if (hasImage)
          CustomCachedImage(
            width: size,
            height: size,
            imageUrl: avatarUrl,
            isCircle: true,
          )
        else
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              _initials(name),
              style: AppTextStyle.textMd(
                color: colorScheme.primary,
                weight: FontWeight.w700,
              ),
            ),
          ),
        if (showOnlineDot)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: size * 0.24,
              height: size * 0.24,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.surface, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first).toUpperCase();
  }
}
