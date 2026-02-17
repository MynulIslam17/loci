import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final AutovalidateMode? autoValidateMode;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isObscureText;
  final String obscuringCharacter;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusBorderColor;
  final Color? hintTextColor;
  final Widget? prefixIcon;
  final String? labelText;
  final String? hintText;
  final double? contentPaddingHorizontal;
  final double? contentPaddingVertical;
  final int? maxLine;
  final double? fontSize;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final bool isPassword;
  final bool readOnly;
  final double? borderRadius;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final String? title;
  final TextStyle? titleStyle;
  final FocusNode? focusNode;
  final String? errorText;
  final Color? textColor; // Added to allow manual override

  const CustomTextField({
    super.key,
    this.contentPaddingHorizontal,
    this.contentPaddingVertical,
    this.hintText,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLine,
    this.validator,
    this.hintTextColor,
    this.borderColor,
    this.focusBorderColor,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.isObscureText = false,
    this.obscuringCharacter = '•',
    this.fillColor,
    this.fontSize,
    this.labelText,
    this.isPassword = false,
    this.readOnly = false,
    this.borderRadius,
    this.onTap,
    this.onChanged,
    this.title,
    this.titleStyle,
    this.focusNode,
    this.errorText,
    this.autoValidateMode,
    this.textColor, // Added parameter
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword ? true : widget.isObscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get theme-aware colors
    final themeColors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          Text(
            widget.title!,
            style: widget.titleStyle ?? TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              // Adapts to light/dark mode automatically
              color: themeColors.onSurface,
            ),
          ),
          const SizedBox(height: 14),
        ],

        TextFormField(
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          focusNode: widget.focusNode,
          readOnly: widget.readOnly,
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          obscuringCharacter: widget.obscuringCharacter,
          autovalidateMode: widget.autoValidateMode ?? AutovalidateMode.disabled,
          maxLines: widget.maxLine ?? 1,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          // Cursor color follows the theme primary color
          cursorColor: themeColors.primary,
          obscureText: _obscureText,
          style: TextStyle(
            // Use widget.textColor if provided, otherwise follow the theme
            color: widget.textColor ?? themeColors.onSurface,
            fontSize: widget.fontSize ?? 14,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.contentPaddingHorizontal ?? 16,
              vertical: widget.contentPaddingVertical ?? 16,
            ),
            // Background color also adapts if not provided
            fillColor: widget.fillColor ?? themeColors.surfaceVariant.withOpacity(0.3),
            filled: true,
            prefixIcon: widget.prefixIcon != null
                ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: widget.prefixIcon,
            )
                : null,
            suffixIcon: _buildSuffixIcon(),
            prefixIconConstraints: const BoxConstraints(minWidth: 45),
            labelText: widget.labelText,
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: widget.hintTextColor ?? themeColors.onSurfaceVariant,
              fontSize: widget.fontSize ?? 14,
            ),
            focusedBorder: _buildBorder(widget.focusBorderColor ?? themeColors.primary),
            enabledBorder: _buildBorder(widget.borderColor ?? themeColors.outlineVariant),
            errorBorder: _buildBorder(themeColors.error),
            focusedErrorBorder: _buildBorder(themeColors.error),
            errorText: widget.errorText,
            errorStyle: TextStyle(fontSize: 12, color: themeColors.error),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.isPassword) {
      return IconButton(
        onPressed: _toggleObscureText,
        icon: Icon(
          _obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          color: Colors.grey,
          size: 20,
        ),
      );
    }
    return widget.suffixIcon;
  }

  OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(widget.borderRadius ?? 12),
      borderSide: BorderSide(color: color, width: 1.2),
    );
  }
}