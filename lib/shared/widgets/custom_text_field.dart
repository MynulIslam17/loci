import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loci/shared/widgets/form_labels.dart';

class CustomTextField extends StatefulWidget {
  final AutovalidateMode? autoValidateMode;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isObscureText;
  final String obscuringCharacter;
  final int? maxLength;
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
  final VoidCallback? onClear;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final String? title;
  final bool? isRequired;
  final TextStyle? titleStyle;
  final FocusNode? focusNode;
  final String? errorText;
  final Color? textColor;
  final bool showClearButton;
  final bool autofocus;
  final EdgeInsets scrollPadding;

  const CustomTextField({
    super.key,
    this.contentPaddingHorizontal,
    this.contentPaddingVertical,
    this.hintText,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLine,
    this.maxLength,
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
    this.onClear,
    this.onFieldSubmitted,
    this.title,
    this.isRequired,
    this.titleStyle,
    this.focusNode,
    this.errorText,
    this.autoValidateMode,
    this.textColor,
    this.showClearButton = false,
    this.autofocus = false,
    this.scrollPadding = const EdgeInsets.all(20),
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
    widget.controller?.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerChanged);
      widget.controller?.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (widget.showClearButton && mounted) {
      setState(() {});
    }
  }

  void _clearText() {
    widget.controller?.clear();
    widget.focusNode?.unfocus();
    FocusScope.of(context).unfocus();
    widget.onClear?.call();
    widget.onChanged?.call('');
  }

  void _toggleObscureText() {
    setState(() => _obscureText = !_obscureText);
  }

  TextFormField _buildField() {
    final themeColors = Theme.of(context).colorScheme;
    final isMultiline = (widget.maxLine ?? 1) > 1;
    final bool useFloatingLabel =
        widget.title == null &&
        widget.hintText != null &&
        widget.labelText == null &&
        !isMultiline &&
        widget.prefixIcon == null &&
        widget.suffixIcon == null;
    final String? effectiveLabel =
        widget.labelText ?? (useFloatingLabel ? widget.hintText : null);
    final String? effectiveHint = useFloatingLabel ? null : widget.hintText;
    final Color hintColor =
        widget.hintTextColor ?? themeColors.onSurfaceVariant;

    return TextFormField(
      autofocus: widget.autofocus,
      maxLength: widget.maxLength,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      scrollPadding: widget.scrollPadding,
      onTap: widget.onTap,
      focusNode: widget.focusNode,
      readOnly: widget.readOnly,
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      inputFormatters: widget.inputFormatters,
      obscuringCharacter: widget.obscuringCharacter,
      autovalidateMode:
          widget.autoValidateMode ?? AutovalidateMode.onUserInteraction,
      maxLines: widget.maxLine ?? 1,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      cursorColor: themeColors.primary,
      obscureText: widget.isPassword ? _obscureText : widget.isObscureText,
      style: TextStyle(
        color: widget.textColor ?? themeColors.onSurface,
        fontSize: widget.fontSize ?? 14,
      ),
      decoration: InputDecoration(
        isDense: !isMultiline,
        alignLabelWithHint: isMultiline,
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.contentPaddingHorizontal ?? 14,
          vertical: widget.contentPaddingVertical ?? (isMultiline ? 12 : 14),
        ),
        filled: true,
        fillColor: widget.fillColor ??
            themeColors.surfaceContainerHighest.withValues(alpha: 0.3),
        prefixIcon: isMultiline ? null : widget.prefixIcon,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 44,
          minHeight: 44,
        ),
        suffixIcon: _buildSuffixIcon(_obscureText),
        suffixIconConstraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
        labelText: effectiveLabel,
        hintText: effectiveHint,
        labelStyle: TextStyle(
          color: hintColor,
          fontSize: widget.fontSize ?? 14,
        ),
        floatingLabelStyle: TextStyle(color: themeColors.primary),
        hintStyle: TextStyle(
          color: hintColor,
          fontSize: widget.fontSize ?? 14,
        ),
        focusedBorder:
            _buildBorder(widget.focusBorderColor ?? themeColors.primary),
        enabledBorder:
            _buildBorder(widget.borderColor ?? themeColors.outlineVariant),
        errorBorder: _buildBorder(themeColors.error),
        focusedErrorBorder: _buildBorder(themeColors.error),
        errorText: widget.errorText,
        errorStyle: TextStyle(fontSize: 12, color: themeColors.error),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).colorScheme;
    final isMultiline = (widget.maxLine ?? 1) > 1;
    final field = _buildField();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.title != null) ...[
          if (widget.isRequired != null)
            FormFieldLabel(
              label: widget.title!,
              isRequired: widget.isRequired!,
            )
          else
            Text(
              widget.title!,
              style: widget.titleStyle ??
                  TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: themeColors.onSurface,
                  ),
            ),
          SizedBox(height: widget.isRequired != null ? 6 : 10),
        ],
        if (isMultiline && widget.prefixIcon != null)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 2, right: 6),
                child: widget.prefixIcon!,
              ),
              Expanded(child: field),
            ],
          )
        else
          field,
      ],
    );
  }

  Widget? _buildSuffixIcon(bool obscure) {
    if (widget.isPassword) {
      return IconButton(
        onPressed: _toggleObscureText,
        icon: Icon(
          obscure
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          size: 20,
        ),
      );
    }

    final hasText = widget.controller?.text.isNotEmpty ?? false;
    if (widget.showClearButton && hasText) {
      return IconButton(
        onPressed: _clearText,
        icon: Icon(
          Icons.close,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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