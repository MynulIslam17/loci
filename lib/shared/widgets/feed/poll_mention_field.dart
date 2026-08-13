import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/shared/widgets/business_avatar.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

/// Compact mention field for poll cards in a multi-post feed.
///
/// Phase (keep stable): gentle scroll only when the field is covered; search
/// pick via tap; no center / whole-post pin.
/// Search results render in an overlay clamped above the keyboard.
class PollMentionField extends StatefulWidget {
  final String postId;
  final String currentUserImage;
  final int avatarRevision;
  final bool isActive;

  final List<BrowseBusinessModel> suggestions;
  final bool isLoading;
  final bool searchDone;

  final void Function(String postId, String query)? onChanged;
  final void Function(String postId, BrowseBusinessModel business)?
      onBusinessSelected;
  final Future<void> Function(String postId, String text, String image)?
      onSubmit;
  final void Function(String postId, bool focused)? onFocusChanged;

  const PollMentionField({
    super.key,
    required this.postId,
    required this.currentUserImage,
    this.avatarRevision = 0,
    this.isActive = false,
    this.suggestions = const [],
    this.isLoading = false,
    this.searchDone = false,
    this.onChanged,
    this.onBusinessSelected,
    this.onSubmit,
    this.onFocusChanged,
  });

  @override
  State<PollMentionField> createState() => _PollMentionFieldState();
}

class _PollMentionFieldState extends State<PollMentionField> {
  final TextEditingController _mentionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _fieldKey = GlobalKey();
  final OverlayPortalController _overlayController = OverlayPortalController();
  final _selectedBusiness = Rxn<BrowseBusinessModel>();
  final _isSubmitting = false.obs;

  List<BrowseBusinessModel> _results = const [];
  bool _loading = false;
  bool _searchDone = false;
  Timer? _settleTimer;
  bool _overlaySyncScheduled = false;

  bool get _showDropdown =>
      widget.isActive &&
      _selectedBusiness.value == null &&
      (_loading || _results.isNotEmpty || _searchDone);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    if (widget.isActive) _applyParentSuggestions();
  }

  @override
  void didUpdateWidget(covariant PollMentionField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isActive) {
      _applyParentSuggestions();
      // Parent Obx rebuilds us; also refresh after layout so the overlay
      // paints with the latest results (not an empty first frame).
      _syncOverlay();
      if (_showDropdown) _ensureFieldAboveKeyboard();
      return;
    }

    if (oldWidget.isActive && !widget.isActive) {
      _cancelFocusScroll();
      _clearResults();
      // Never hide/show OverlayPortal during build — defer to next frame.
      _syncOverlay();
      if (_focusNode.hasFocus) _focusNode.unfocus();
    }
  }

  void _applyParentSuggestions() {
    if (_selectedBusiness.value != null) {
      _clearResults();
      return;
    }
    _results = List<BrowseBusinessModel>.of(widget.suggestions);
    _loading = widget.isLoading;
    _searchDone = widget.searchDone;
  }

  void _clearResults() {
    _results = const [];
    _loading = false;
    _searchDone = false;
  }

  void _syncOverlay() {
    if (_overlaySyncScheduled) return;
    _overlaySyncScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _overlaySyncScheduled = false;
      if (!mounted) return;
      final shouldShow = _showDropdown;
      if (shouldShow) {
        if (!_overlayController.isShowing) _overlayController.show();
      } else if (_overlayController.isShowing) {
        _overlayController.hide();
      }
    });
  }

  @override
  void dispose() {
    _cancelFocusScroll();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _mentionController.dispose();
    super.dispose();
  }

  void _cancelFocusScroll() {
    _settleTimer?.cancel();
    _settleTimer = null;
  }

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {});
    widget.onFocusChanged?.call(widget.postId, _focusNode.hasFocus);
    _syncOverlay();

    _cancelFocusScroll();
    if (!_focusNode.hasFocus || _isSubmitting.value) return;

    _ensureFieldAboveKeyboard();
    _settleTimer =
        Timer(const Duration(milliseconds: 350), _ensureFieldAboveKeyboard);
  }

  void _focusField() {
    if (_isSubmitting.value) return;
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  /// Nudge the feed so the mention field itself stays above the keyboard.
  void _ensureFieldAboveKeyboard() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isSubmitting.value) return;
      if (!widget.isActive && !_focusNode.hasFocus) return;

      final ctx = _fieldKey.currentContext;
      if (ctx == null || !ctx.mounted) return;

      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;

      final scrollable = Scrollable.maybeOf(ctx);
      if (scrollable == null) return;
      final position = scrollable.position;

      final viewData = MediaQueryData.fromView(View.of(ctx));
      final keyboard = viewData.viewInsets.bottom;
      final top = box.localToGlobal(Offset.zero).dy;
      final bottom = top + box.size.height;

      // Room for IME suggestion strip above the soft keyboard.
      final visibleTop = viewData.padding.top + 8;
      final visibleBottom = viewData.size.height - keyboard - 72;

      double delta = 0;
      if (bottom > visibleBottom) {
        delta = bottom - visibleBottom;
      } else if (top < visibleTop) {
        delta = top - visibleTop;
      } else {
        return;
      }

      final target =
          (position.pixels + delta).clamp(0.0, position.maxScrollExtent);
      if ((target - position.pixels).abs() < 2) return;

      position.animateTo(
        target,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _onTextChanged(String value) {
    if (_selectedBusiness.value != null &&
        value != _selectedBusiness.value!.name) {
      _selectedBusiness.value = null;
    }
    if (value.trim().isEmpty) {
      setState(_clearResults);
      _syncOverlay();
    }
    widget.onChanged?.call(widget.postId, value);
  }

  void _onBusinessTapped(BrowseBusinessModel business) {
    _mentionController.value = TextEditingValue(
      text: business.name,
      selection: TextSelection.collapsed(offset: business.name.length),
    );
    _selectedBusiness.value = business;
    setState(_clearResults);
    _syncOverlay();
    widget.onBusinessSelected?.call(widget.postId, business);
  }

  Future<void> _submit() async {
    final business = _selectedBusiness.value;
    final text = _mentionController.text.trim();
    if (text.isEmpty || _isSubmitting.value || business == null) return;

    _cancelFocusScroll();
    _isSubmitting.value = true;
    _focusNode.unfocus();
    setState(_clearResults);
    _syncOverlay();
    try {
      await widget.onSubmit?.call(widget.postId, text, business.logo);
      if (!mounted) return;
      _mentionController.clear();
      _selectedBusiness.value = null;
      setState(_clearResults);
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  /// Results float on top of the field for THIS post only (matching width +
  /// caret), clamped so they stay on-screen above the keyboard.
  Widget _buildSuggestionsOverlay(BuildContext context) {
    final colors = context.colorScheme;
    final fieldCtx = _fieldKey.currentContext;
    final box = fieldCtx?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) {
      return const SizedBox.shrink();
    }

    final viewData = MediaQueryData.fromView(View.of(context));
    final keyboard = viewData.viewInsets.bottom;
    final minTop = viewData.padding.top + 8;
    final keyboardTop = viewData.size.height - keyboard - 12;

    final origin = box.localToGlobal(Offset.zero);
    final fieldTop = origin.dy;
    final fieldLeft = origin.dx;
    final fieldWidth = box.size.width;
    final fieldBottom = fieldTop + box.size.height;

    final spaceAbove = fieldTop - minTop - 8;
    final spaceBelow = keyboardTop - fieldBottom - 8;
    final showAbove = spaceAbove >= 72 || spaceAbove >= spaceBelow;
    final available = showAbove ? spaceAbove : spaceBelow;
    final listHeight =
        (available < 56 ? 120.0 : math.min(140.0, available)).clamp(56.0, 140.0);

    const caretH = 7.0;
    final totalH = listHeight + caretH;
    final double top;
    if (showAbove) {
      top = (fieldTop - 2 - totalH).clamp(minTop, keyboardTop - totalH);
    } else {
      top = (fieldBottom + 2).clamp(minTop, keyboardTop - totalH);
    }

    return Positioned(
      left: fieldLeft,
      width: fieldWidth,
      top: top,
      child: TextFieldTapRegion(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!showAbove)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 22),
                  child: Transform.flip(
                    flipY: true,
                    child: CustomPaint(
                      size: const Size(14, caretH),
                      painter: _AnchorCaretPainter(
                        fill: colors.surfaceContainerHigh,
                        border: colors.primary.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                ),
              ),
            Material(
              elevation: 8,
              shadowColor: colors.primary.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(10),
              color: colors.surfaceContainerHigh,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colors.primary.withValues(alpha: 0.65),
                    width: 1.4,
                  ),
                ),
                child: NotificationListener<ScrollNotification>(
                  onNotification: (_) => true,
                  child: _SuggestionDropdown(
                    isLoading: _loading,
                    suggestions: _results,
                    colors: colors,
                    maxHeight: listHeight,
                    onTap: _onBusinessTapped,
                  ),
                ),
              ),
            ),
            if (showAbove)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 22),
                  child: CustomPaint(
                    size: const Size(14, caretH),
                    painter: _AnchorCaretPainter(
                      fill: colors.surfaceContainerHigh,
                      border: colors.primary.withValues(alpha: 0.65),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final focused = _focusNode.hasFocus || _showDropdown;

    // Rebuild when the IME inset changes so the overlay can re-clamp.
    MediaQueryData.fromView(View.of(context)).viewInsets.bottom;
    _syncOverlay();

    return TextFieldTapRegion(
      child: OverlayPortal(
        controller: _overlayController,
        overlayChildBuilder: _buildSuggestionsOverlay,
        child: Listener(
          key: _fieldKey,
          behavior: HitTestBehavior.opaque,
          onPointerDown: (_) => _focusField(),
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              padding: const EdgeInsets.fromLTRB(8, 3, 3, 3),
              decoration: BoxDecoration(
                color: focused
                    ? colors.primary.withValues(alpha: 0.06)
                    : colors.surface.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: focused
                      ? colors.primary.withValues(alpha: 0.55)
                      : colors.outline.withValues(alpha: 0.4),
                  width: focused ? 1.4 : 1,
                ),
              ),
              child: Row(
                children: [
                  _UserAvatar(
                    fallbackUrl: widget.currentUserImage,
                    revision: widget.avatarRevision,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _mentionController,
                      focusNode: _focusNode,
                      onChanged: _onTextChanged,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                      scrollPadding: EdgeInsets.zero,
                      style: AppTextStyle.textSm(color: colors.onSurface),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Mention a business…',
                        hintStyle: AppTextStyle.textXs(
                          color: colors.onSurfaceVariant,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 7),
                      ),
                    ),
                  ),
                  Obx(() {
                    final isSubmitting = _isSubmitting.value;
                    final hasBusiness = _selectedBusiness.value != null;
                    return _SendButton(
                      isSubmitting: isSubmitting,
                      enabled: hasBusiness && !isSubmitting,
                      onTap: _submit,
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.fallbackUrl, required this.revision});

  final String fallbackUrl;
  final int revision;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final auth = Get.find<AuthController>();
    final avatar = auth.userModelRx.value?.avatar ?? fallbackUrl;
    if (avatar.isEmpty) {
      return CircleAvatar(
        radius: 14,
        backgroundColor: colors.primary.withValues(alpha: 0.1),
        child: Icon(Icons.person_rounded, size: 16, color: colors.primary),
      );
    }
    return CustomCachedImage(
      width: 28,
      height: 28,
      isCircle: true,
      imageUrl: avatar,
      cacheKey: '$avatar-$revision',
    );
  }
}

class _AnchorCaretPainter extends CustomPainter {
  _AnchorCaretPainter({required this.fill, required this.border});

  final Color fill;
  final Color border;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..color = fill
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = border
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(covariant _AnchorCaretPainter oldDelegate) =>
      fill != oldDelegate.fill || border != oldDelegate.border;
}

class _SendButton extends StatelessWidget {
  final bool isSubmitting;
  final bool enabled;
  final VoidCallback onTap;

  const _SendButton({
    required this.isSubmitting,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final isActive = enabled || isSubmitting;

    return Material(
      color: isActive
          ? colors.primary
          : colors.onSurface.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: isSubmitting
                  ? SizedBox(
                      key: const ValueKey('loader'),
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colors.onPrimary,
                        ),
                      ),
                    )
                  : Icon(
                      key: const ValueKey('icon'),
                      Icons.send_rounded,
                      size: 16,
                      color: enabled
                          ? colors.onPrimary
                          : colors.onSurface.withValues(alpha: 0.35),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SuggestionDropdown extends StatelessWidget {
  final bool isLoading;
  final List<BrowseBusinessModel> suggestions;
  final ColorScheme colors;
  final double maxHeight;
  final void Function(BrowseBusinessModel) onTap;

  const _SuggestionDropdown({
    required this.isLoading,
    required this.suggestions,
    required this.colors,
    required this.onTap,
    this.maxHeight = 140,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colors.outline.withValues(alpha: 0.7)),
      ),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : suggestions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Text(
                    'No businesses found',
                    style: AppTextStyle.textXs(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxHeight),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.manual,
                    physics: const ClampingScrollPhysics(),
                    itemCount: suggestions.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 1,
                      color: colors.outline.withValues(alpha: 0.5),
                    ),
                    itemBuilder: (context, index) {
                      final business = suggestions[index];
                      return InkWell(
                        onTap: () => onTap(business),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          child: Row(
                            children: [
                              BusinessAvatar(
                                imageUrl: business.logo,
                                size: 26,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      business.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyle.textSm(
                                        color: colors.onSurface,
                                        weight: FontWeight.w500,
                                      ),
                                    ),
                                    if (business.category.isNotEmpty)
                                      Text(
                                        business.category,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyle.textXs(
                                          color: colors.onSurfaceVariant,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
