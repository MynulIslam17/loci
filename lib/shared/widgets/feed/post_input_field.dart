import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/question_type.dart';
import 'package:loci/core/theme/theme_extention.dart';

class PostInputField extends StatefulWidget {
  final Future<void> Function(String text, String category, QuestionType type)?
  onSubmit;
  final List<String> categories;
  final String initialCategory;
  final String hintText;

  const PostInputField({
    super.key,
    this.onSubmit,
    required this.categories,
    this.initialCategory = 'Foodie',
    this.hintText = 'Ask anything…',
  });

  @override
  State<PostInputField> createState() => _PostInputFieldState();
}

class _PostInputFieldState extends State<PostInputField>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  late final AnimationController _expandAnim;
  late final Animation<double> _fadeAnim;

  final _isExpanded = false.obs;
  final _isPopupOpen = false.obs;
  final _isSubmitting = false.obs;
  late final RxString _selectedCategory;
  final _selectedType = QuestionType.question.obs;
  final _textRevision = 0.obs;

  static const _purple = Color(0xFF7F77DD);
  static const int _maxChars = 280;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory.obs;
    _controller = TextEditingController()
      ..addListener(() => _textRevision.value++);
    _focusNode = FocusNode()..addListener(_onFocusChange);
    _expandAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fadeAnim = CurvedAnimation(parent: _expandAnim, curve: Curves.easeOut);
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus && !_isExpanded.value) {
      _isExpanded.value = true;
      _expandAnim.forward().whenComplete(_scrollComposerIntoView);
    }
    if (_focusNode.hasFocus) {
      _scrollComposerIntoView();
    }
  }

  /// Lift the expanded composer above the keyboard. Pinning near the top of
  /// the remaining viewport is the reliable option on small screens; softer
  /// "only scroll if needed" policies can leave the field under the keyboard.
  void _scrollComposerIntoView() {
    void ensure() {
      if (!mounted || !_focusNode.hasFocus) return;
      Scrollable.ensureVisible(
        context,
        alignment: 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ensure();
      // Second pass after keyboard + expand animation settle.
      Future<void>.delayed(const Duration(milliseconds: 320), ensure);
    });
  }

  void _collapse() {
    if (!mounted) return;
    if (_controller.text.isEmpty && !_isPopupOpen.value) {
      _expandAnim.reverse().then((_) {
        if (mounted) _isExpanded.value = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSubmitting.value || text.length > _maxChars) return;
    _isSubmitting.value = true;
    try {
      await widget.onSubmit?.call(
        text,
        _selectedCategory.value,
        _selectedType.value,
      );
      _controller.clear();
      _focusNode.unfocus();
      _expandAnim.reverse().then((_) {
        if (mounted) _isExpanded.value = false;
      });
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _expandAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Obx(() {
      _textRevision.value;
      final isExpanded = _isExpanded.value;
      final isSubmitting = _isSubmitting.value;
      final selectedType = _selectedType.value;
      final selectedCategory = _selectedCategory.value;
      final charCount = _controller.text.length;
      final overLimit = charCount > _maxChars;
      final trimmedEmpty = _controller.text.trim().isEmpty;

      return TapRegion(
        onTapOutside: (_) {
          FocusScope.of(context).unfocus();
          Future.delayed(const Duration(milliseconds: 150), _collapse);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(isExpanded ? 20 : 24),
            border: Border.all(
              color: isExpanded ? _purple : colors.outline,
              width: isExpanded ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Text field row ──────────────────────────────────────────
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (!isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 18,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      minLines: 1,
                      maxLines: 4,
                      style: AppTextStyle.textSm(color: colors.onSurface),
                      decoration: InputDecoration(
                        hintText: widget.hintText,
                        border: InputBorder.none,
                        isCollapsed: true,
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        hintStyle: AppTextStyle.textSm(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                  // Send button always visible
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: isSubmitting ? null : _handleSubmit,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: trimmedEmpty || overLimit
                            ? colors.surfaceContainerHighest
                            : _purple,
                      ),
                      child: isSubmitting
                          ? const Padding(
                              padding: EdgeInsets.all(8),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.arrow_upward,
                              size: 18,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),

              // ── Toolbar row (animated) ──────────────────────────────────
              FadeTransition(
                opacity: _fadeAnim,
                child: SizeTransition(
                  sizeFactor: _fadeAnim,
                  axisAlignment: -1, // ignore: deprecated_member_use
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            _SegmentedToggle(
                              options: QuestionType.values,
                              selected: selectedType,
                              activeColor: _purple,
                              onSelect: (v) => _selectedType.value = v,
                            ),
                            const Spacer(),
                            Text(
                              '$charCount / $_maxChars',
                              style: AppTextStyle.textXs(
                                color: overLimit
                                    ? colors.error
                                    : colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Flexible(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: _CategoryChip(
                                  categories: widget.categories,
                                  selected: selectedCategory,
                                  onSelect: (v) {
                                    _selectedCategory.value = v;
                                    _isPopupOpen.value = false;
                                  },
                                  onOpened: () => _isPopupOpen.value = true,
                                  onCanceled: () => _isPopupOpen.value = false,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Segmented toggle ────────────────────────────────────────────────────────

class _SegmentedToggle extends StatelessWidget {
  final List<QuestionType> options;
  final QuestionType selected;
  final Color activeColor;
  final void Function(QuestionType) onSelect;

  const _SegmentedToggle({
    required this.options,
    required this.selected,
    required this.activeColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options.map((opt) {
          final isActive = selected == opt;
          return GestureDetector(
            onTap: () => onSelect(opt),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: isActive ? activeColor : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                opt.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? Colors.white : colors.onSurfaceVariant,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Category chip with popup ────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final void Function(String) onSelect;
  final VoidCallback onOpened;
  final VoidCallback onCanceled;

  const _CategoryChip({
    required this.categories,
    required this.selected,
    required this.onSelect,
    required this.onOpened,
    required this.onCanceled,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, -8),
      onOpened: onOpened,
      onCanceled: onCanceled,
      onSelected: onSelect,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (_) => categories
          .map(
            (c) => PopupMenuItem(
              value: c,
              child: Text(c, style: const TextStyle(fontSize: 14)),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outline.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Icon(Icons.sell_outlined, size: 13, color: colors.onSurfaceVariant),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                selected,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: colors.onSurface),
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.expand_less, size: 14, color: colors.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
