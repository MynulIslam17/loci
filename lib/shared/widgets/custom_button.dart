import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/adaptive_progress.dart';

class CustomButton extends StatelessWidget {
  final Widget? child;
  final String? text;
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
    final enabled = !isLoading && onPressed != null;
    final radius = BorderRadius.circular(borderRadius ?? 12);
    final content = isLoading ? _buildLoader() : _buildContent();

    return SizedBox(
      width: width ?? double.infinity,
      height: height ?? 54,
      child: context.isCupertino
          ? _iosButton(context, enabled: enabled, radius: radius, content: content)
          : _androidButton(context, enabled: enabled, radius: radius, content: content),
    );
  }

  Widget _iosButton(
    BuildContext context, {
    required bool enabled,
    required BorderRadius radius,
    required Widget content,
  }) {
    final bg = backgroundColor ?? context.colorScheme.primary;
    final outlined = side != null;

    return CupertinoButton(
      onPressed: enabled ? onPressed : null,
      padding: EdgeInsets.zero,
      minimumSize: Size(0, height ?? 54),
      borderRadius: radius,
      color: outlined ? const Color(0x00000000) : bg,
      disabledColor: outlined ? const Color(0x00000000) : Colors.grey,
      foregroundColor: textColor ?? Colors.white,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: side == null ? null : Border.fromBorderSide(side!),
        ),
        child: Center(child: content),
      ),
    );
  }

  Widget _androidButton(
    BuildContext context, {
    required bool enabled,
    required BorderRadius radius,
    required Widget content,
  }) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? context.colorScheme.primary,
        foregroundColor: textColor ?? Colors.white,
        elevation: 0,
        disabledBackgroundColor: Colors.grey,
        side: side,
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
      child: content,
    );
  }

  Widget _buildContent() {
    if (child != null) return child!;

    return Text(
      text ?? "",
      style: textStyle ??
          TextStyle(
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
      child: AdaptiveProgress(
        color: Colors.white,
        strokeWidth: 2.5,
        radius: 10,
      ),
    );
  }
}
