import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';


class PostInputField extends StatefulWidget {
  final void Function(String text, String category)? onSubmit;
  final List<String> categories;
  final String initialCategory;
  final String hintText;

  const PostInputField({
    super.key,
    this.onSubmit,
    this.categories = const ['Foodie', 'Drinks', 'Restu'],
    this.initialCategory = 'Foodie',
    this.hintText = 'Ask anything',
  });

  @override
  State<PostInputField> createState() => _PostInputFieldState();
}

class _PostInputFieldState extends State<PostInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _showDropdown = false;
  bool _isPopupOpen = false;
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

  void _handleSubmit() {
    if (_controller.text.isNotEmpty) {
      widget.onSubmit?.call(_controller.text, _selectedCategory);
      _controller.clear();
      _focusNode.unfocus();
      setState(() {
        _showDropdown = false;
        _isPopupOpen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _showDropdown
              ? context.colorScheme.primary
              : context.colorScheme.outline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // --- TextField ---
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 3,
              controller: _controller,
              focusNode: _focusNode,
              onTap: () {
                setState(() {
                  _showDropdown = true;
                });
              },
              onTapOutside: (_) {
                FocusScope.of(context).unfocus();
                Future.delayed(const Duration(milliseconds: 200), () {
                  if (_controller.text.isEmpty &&
                      !_focusNode.hasFocus &&
                      !_isPopupOpen) {
                    setState(() {
                      _showDropdown = false;
                    });
                  }
                });
              },
              style: AppTextStyle.textSm(
                color: context.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                hintText: widget.hintText,

                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                hintStyle: AppTextStyle.textSm(
                  color:
                  context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // --- Category Chip ---
          if (_showDropdown)
            PopupMenuButton<String>(
              padding: EdgeInsets.zero,
              offset: const Offset(0, 40),
              onOpened: () {
                setState(() {
                  _isPopupOpen = true;
                });
              },
              onCanceled: () {
                setState(() {
                  _isPopupOpen = false;
                });
              },
              onSelected: (String value) {
                setState(() {
                  _selectedCategory = value;
                  _isPopupOpen = false;
                });
              },
              itemBuilder: (context) => widget.categories
                  .map((c) => PopupMenuItem(value: c, child: Text(c)))
                  .toList(),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                margin: const EdgeInsets.only(left: 8, bottom: 6),
                decoration: BoxDecoration(
                  color: context.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCategory,
                      style: AppTextStyle.textSm(
                        color: context.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      size: 16,
                      color: context.colorScheme.primary,
                    ),
                  ],
                ),
              ),
            ),

          // --- Send Button ---
          if (_showDropdown) ...[
            const SizedBox(width: 4),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: _handleSubmit,
              icon:Icon(Icons.send,size: 20,color: context.colorScheme.primary,),
            ),
          ],
        ],
      ),
    );
  }
}