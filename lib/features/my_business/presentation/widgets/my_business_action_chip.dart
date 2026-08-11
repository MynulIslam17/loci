import 'package:flutter/material.dart';

class MyBusinessActionChip extends StatelessWidget {
  const MyBusinessActionChip({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
    this.backgroundColor,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Colors.transparent),
      ),
      avatar: icon != null ? Icon(icon, size: 18, color: Colors.white) : null,
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
