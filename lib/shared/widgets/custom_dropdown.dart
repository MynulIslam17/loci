import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String? title;
  final String? hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final Color? fillColor;
  final double? borderRadius;
  final Color? borderColor;
  final Color? dropdownColor;
  final TextStyle? titleStyle;
  final Color? hintColor;
  final Color? textColor;
  final double? hintFontSize;
  final double? textFontSize;

  const CustomDropdown({
    super.key,
    this.title,
    this.hintText,
    this.value,
    required this.items,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.fillColor,
    this.borderRadius,
    this.borderColor,
    this.dropdownColor,
    this.hintColor,
    this.textColor,
    this.hintFontSize,
    this.textFontSize,
    this.titleStyle,
  });

  String _textFromChild(Widget? child) {
    if (child is Text) {
      return child.data ?? child.textSpan?.toPlainText() ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final effectiveTextColor = textColor ?? scheme.onSurface;
    final effectiveHintColor = hintColor ?? scheme.onSurfaceVariant;
    final effectiveFill =
        fillColor ?? scheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final effectiveBorder = borderColor ?? scheme.outline;
    final fontSize = textFontSize ?? 13;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: titleStyle ??
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurface,
                ),
          ),
          const SizedBox(height: 10),
        ],
        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          isDense: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: scheme.onSurfaceVariant,
            size: 22,
          ),
          selectedItemBuilder: (context) {
            return items.map((item) {
              final label = _textFromChild(item.child);
              return Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: effectiveTextColor,
                    fontSize: fontSize,
                  ),
                ),
              );
            }).toList();
          },
          style: TextStyle(
            color: effectiveTextColor,
            fontSize: fontSize,
          ),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: effectiveFill,
            prefixIcon: prefixIcon == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: prefixIcon,
                  ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              color: effectiveHintColor,
              fontSize: hintFontSize ?? fontSize,
            ),
            focusedBorder: _buildBorder(scheme.primary),
            enabledBorder: _buildBorder(effectiveBorder),
            errorBorder: _buildBorder(scheme.error),
            focusedErrorBorder: _buildBorder(scheme.error),
            errorStyle: TextStyle(fontSize: 12, color: scheme.error),
          ),
          dropdownColor: dropdownColor ?? scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
          menuMaxHeight: 280,
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ?? 12),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}
