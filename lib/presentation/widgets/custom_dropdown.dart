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
  final Color? dropdownColor;


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
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(
            title!,
            style: const TextStyle(fontSize: 16),
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
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey,
            size: 20,
          ),


          style: TextStyle(
            color: textColor ?? Colors.black,
            fontSize: textFontSize ?? 14,
            overflow: TextOverflow.ellipsis,
          ),

          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            filled: true,
            fillColor: fillColor ?? Colors.grey.withOpacity(0.05),
            prefixIcon: prefixIcon != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: prefixIcon,
            )
                : null,
            prefixIconConstraints:
            const BoxConstraints(minWidth: 45),
            hintText: hintText,


            hintStyle: TextStyle(
              color: hintColor ?? const Color(0xFF999999),
              fontSize: hintFontSize ?? 14,
            ),

            focusedBorder:
            _buildBorder(borderColor ?? Colors.blue),
            enabledBorder:
            _buildBorder(borderColor ?? Colors.grey.withOpacity(0.3)),
            errorBorder: _buildBorder(Colors.red),
            focusedErrorBorder: _buildBorder(Colors.red),
            errorStyle:
            const TextStyle(fontSize: 12, color: Colors.red),
          ),
          dropdownColor: dropdownColor ?? Colors.white,
          borderRadius:
          BorderRadius.circular(borderRadius ?? 12),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius:
      BorderRadius.circular(borderRadius ?? 12),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}