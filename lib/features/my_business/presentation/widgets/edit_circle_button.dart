import 'package:flutter/material.dart';
import 'package:loci/core/theme/app_colors.dart';

class EditCircleButton extends StatelessWidget {
  const EditCircleButton({
    super.key,
    required this.onTap,
    this.size = 26,
    this.icon = Icons.edit_outlined,
    this.iconColor = AppColors.primaryG700,
  });

  final VoidCallback onTap;
  final double size;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Icon(icon, size: size * 0.7, color: iconColor),
        ),
      ),
    );
  }
}
