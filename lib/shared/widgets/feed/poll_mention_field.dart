import 'dart:async';

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
/// Search results are shown in an overlay that always floats ABOVE the text
/// field, staying clear of the soft keyboard. Uses [CompositedTransformTarget]
/// / [CompositedTransformFollower] for reliable tracking during keyboard
/// animations, instead of manual [localToGlobal] math.
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
  final LayerLink _layerLink = LayerLink();
  final _selectedBusiness = Rxn<BrowseBusinessModel>();
  final _isSubmitting = false.obs;

  OverlayEntry? _overlayEntry;

  List<BrowseBusinessModel> _results = const [];
  bool _loading = false;
  bool _searchDone = false;

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
      _syncOverlay();
      return;
    }

    if (oldWidget.isActive && !widget.isActive) {
      _clearResults();
      _removeOverlay();
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

  // ── Overlay management ──────────────────────────────────────────────────

  void _syncOverlay() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_showDropdown) {
        _showOverlay();
      } else {
        _removeOverlay();
      }
    });
  }

  void _showOverlay() {
    // Always rebuild to pick up new results / loading state.
    _removeOverlay();
    if (!mounted) return;

    final overlay = Overlay.of(context, rootOverlay: false);
    _overlayEntry = OverlayEntry(builder: (_) => _buildSuggestionsOverlay());
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _mentionController.dispose();
    super.dispose();
  }

  // ── Focus & scroll ──────────────────────────────────────────────────────

  void _onFocusChanged() {
    if (!mounted) return;
    setState(() {});
    widget.onFocusChanged?.call(widget.postId, _focusNode.hasFocus);
    _syncOverlay();

    if (!_focusNode.hasFocus || _isSubmitting.value) return;
    _ensureFieldVisible();
  }

  void _focusField() {
    if (_isSubmitting.value) return;
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  /// Scrolls the feed so this mention field is fully visible above the keyboard.
  /// Uses [Scrollable.ensureVisible] which handles all the math reliably.
  void _ensureFieldVisible() {
    // Wait for the keyboard to finish animating before scrolling.
    Timer(const Duration(milliseconds: 350), _scrollToSelf);
  }

  void _scrollToSelf() {
    if (!mounted || _isSubmitting.value) return;
    Scrollable.ensureVisible(
      context,
      alignment: 0.7, // Place the field in the lower-middle of visible area
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  // ── Text & business selection ───────────────────────────────────────────

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

    _isSubmitting.value = true;
    _focusNode.unfocus();
    setState(_clearResults);
    _removeOverlay();
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

  // ── Overlay widget ──────────────────────────────────────────────────────

  /// The suggestion dropdown is positioned using [CompositedTransformFollower]
  /// anchored to the text field via [_layerLink]. This tracks the field's
  /// position automatically, even during keyboard open/close animations.
  /// The dropdown always appears ABOVE the field.
  Widget _buildSuggestionsOverlay() {
    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      targetAnchor: Alignment.topLeft,
      followerAnchor: Alignment.bottomLeft,
      offset: const Offset(0, -4),
      child: TextFieldTapRegion(
        child: Builder(builder: (context) {
          final colors = Theme.of(context).colorScheme;
          // ~42px per row × 6 rows + list padding ≈ 260
          const maxHeight = 260.0;

          return Material(
            elevation: 6,
            shadowColor: colors.shadow.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(14),
            color: colors.surfaceContainerHigh,
            clipBehavior: Clip.antiAlias,
            child: Container(
              constraints: const BoxConstraints(maxHeight: maxHeight),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: _SuggestionDropdown(
                isLoading: _loading,
                suggestions: _results,
                colors: colors,
                maxHeight: maxHeight,
                onTap: _onBusinessTapped,
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final focused = _focusNode.hasFocus || _showDropdown;

    // Re-sync overlay when keyboard state changes.
    _syncOverlay();

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFieldTapRegion(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _focusField,
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
    this.maxHeight = 260,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 14),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (suggestions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 16,
              color: colors.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 8),
            Text(
              'No businesses found',
              style: AppTextStyle.textSm(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        physics: const ClampingScrollPhysics(),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          thickness: 0.5,
          indent: 42,
          endIndent: 12,
          color: colors.outlineVariant.withValues(alpha: 0.4),
        ),
        itemBuilder: (context, index) {
          final business = suggestions[index];
          return InkWell(
            onTap: () => onTap(business),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              child: Row(
                children: [
                  BusinessAvatar(imageUrl: business.logo, size: 26),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: business.name,
                            style: AppTextStyle.textSm(
                              color: colors.onSurface,
                              weight: FontWeight.w500,
                            ),
                          ),
                          if (business.category.isNotEmpty) ...[
                            TextSpan(
                              text: '  ·  ',
                              style: AppTextStyle.textXs(
                                color: colors.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            TextSpan(
                              text: business.category,
                              style: AppTextStyle.textXs(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

