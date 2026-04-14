import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';



class CustomButton extends StatelessWidget {
  final Widget? child;         // Pass any widget (Text, Row, Icon, Loader)
  final String? text;          // Optional: convenience string
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final TextStyle? textStyle;
  final bool isLoading;
  final BorderSide? side;


  const CustomButton({
    super.key,
    this.child,
    this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
    this.borderRadius,
    this.textStyle,
    this.isLoading = false,
    this.side,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(

      width: width ?? double.infinity,
      height: height ?? 54,
      child: ElevatedButton(
        onPressed: (isLoading || onPressed == null) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? context.colorScheme.primary,
          foregroundColor: textColor ?? Colors.white,
          elevation: 0,
          disabledBackgroundColor: Colors.grey,
          side: side,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 12),
          ),
        ),
        child: isLoading
            ? _buildLoader()
            : _buildContent(), // Logic to decide between child or text
      ),
    );
  }

  Widget _buildContent() {
    // 1. Priority: If a custom child widget is passed, use it.
    if (child != null) return child!;

    // 2. Fallback: If no child, use the text string.
    return Text(
      text ?? "",
      style: textStyle ?? TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textColor ?? Colors.white,
      ),
    );
  }

  Widget _buildLoader() {
    return const SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 2.5,
      ),
    );
  }
}