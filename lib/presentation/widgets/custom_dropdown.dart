import 'package:flutter/material.dart';
import '../../../core/constants/app_text_style.dart';

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
  final double? fontSize;

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
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // --- Title logic matching CustomTextField ---
        if (title != null) ...[
          Text(
            title!,
           style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 14),
        ],

        DropdownButtonFormField<T>(
          value: value,
          items: items,
          onChanged: onChanged,
          validator: validator,
          isExpanded: true,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 20),
          style: TextStyle(
            color: Colors.black,
            fontSize: fontSize ?? 14,
            overflow: TextOverflow.ellipsis,

          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            // Match CustomTextField's default fill
            fillColor: fillColor ?? Colors.grey.withOpacity(0.05),
            prefixIcon: prefixIcon != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: prefixIcon,
            )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 45),
            hintText: hintText,
            hintStyle: TextStyle(
              color: const Color(0xFF999999),
              fontSize: fontSize ?? 14,

            ),

            // --- Border logic matching CustomTextField exactly ---
            focusedBorder: _buildBorder(borderColor ?? Colors.blue),
            enabledBorder: _buildBorder(borderColor ?? Colors.grey.withOpacity(0.3)),
            errorBorder: _buildBorder(Colors.red),
            focusedErrorBorder: _buildBorder(Colors.red),
            errorStyle: const TextStyle(fontSize: 12, color: Colors.red),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius ?? 12),
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