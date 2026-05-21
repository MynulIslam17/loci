import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';

class PostInputField extends StatefulWidget {
  final Future<void> Function(String text, String category)? onSubmit;
  final List<String> categories;
  final String initialCategory;
  final String hintText;

  const PostInputField({
    super.key,
    this.onSubmit,
    required this.categories,
    this.initialCategory = 'Foodie',
    this.hintText = 'Ask anything',
  });

  @override
  State<PostInputField> createState() => _PostInputFieldState();
}

class _PostInputFieldState extends State<PostInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _showDropdown = false;
  bool _isPopupOpen = false;
  bool _isSubmitting = false;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await widget.onSubmit?.call(text, _selectedCategory);
      _controller.clear();
      _focusNode.unfocus();
      if (mounted) setState(() => _showDropdown = false);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _showDropdown ? colors.primary : colors.outline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 3,
              controller: _controller,
              focusNode: _focusNode,
              onTap: () => setState(() => _showDropdown = true),
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (_controller.text.isEmpty && !_focusNode.hasFocus && !_isPopupOpen) {
                    if (mounted) setState(() => _showDropdown = false);
                  }
                });
              },
              style: AppTextStyle.textSm(color: colors.onSurface),
              decoration: InputDecoration(
                hintText: widget.hintText,
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintStyle: AppTextStyle.textSm(color: colors.onSurfaceVariant),
              ),
            ),
          ),

          if (_showDropdown) ...[
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              offset: const Offset(0, 40),
              onOpened: () => setState(() => _isPopupOpen = true),
              onCanceled: () => setState(() => _isPopupOpen = false),
              onSelected: (value) => setState(() {
                _selectedCategory = value;
                _isPopupOpen = false;
              }),
              itemBuilder: (_) => widget.categories
                  .map((c) => PopupMenuItem(value: c, child: Text(c)))
                  .toList(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: const EdgeInsets.only(left: 8, bottom: 6),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCategory,
                      style: AppTextStyle.textSm(color: colors.primary),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_drop_down, size: 16, color: colors.primary),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 4),

            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _isSubmitting ? null : _handleSubmit,
              icon: Icon(Icons.send, size: 20, color: colors.primary),
            ),
          ],
        ],
      ),
    );
  }
}