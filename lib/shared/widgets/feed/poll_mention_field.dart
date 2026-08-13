import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/shared/widgets/business_avatar.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

/// Compact mention field for poll cards in a multi-post feed.
///
/// Search results are rendered **inline** below the text field (no overlay)
/// so they never get hidden behind the keyboard or block surrounding UI.
/// Supports paginated results with a "Load more" affordance.
class PollMentionField extends StatefulWidget {
  final String postId;
  final String currentUserImage;
  final int avatarRevision;
  final bool isActive;

  final List<BrowseBusinessModel> suggestions;
  final bool isLoading;
  final bool searchDone;

  /// Whether more pages are available for the current search.
  final bool hasNextPage;

  /// Whether a pagination request is in flight.
  final bool isPaginationLoading;

  final void Function(String postId, String query)? onChanged;
  final void Function(String postId, BrowseBusinessModel business)?
      onBusinessSelected;
  final Future<void> Function(String postId, String text, String image)?
      onSubmit;
  final void Function(String postId, bool focused)? onFocusChanged;

  /// Called when the user taps "Load more".
  final VoidCallback? onLoadMore;

  const PollMentionField({
    super.key,
    required this.postId,
    required this.currentUserImage,
    this.avatarRevision = 0,
    this.isActive = false,
    this.suggestions = const [],
    this.isLoading = false,
    this.searchDone = false,
    this.hasNextPage = false,
    this.isPaginationLoading = false,
    this.onChanged,
    this.onBusinessSelected,
    this.onSubmit,
    this.onFocusChanged,
    this.onLoadMore,
  });

  @override
  State<PollMentionField> createState() => _PollMentionFieldState();
}

class _PollMentionFieldState extends State<PollMentionField> {
  final TextEditingController _mentionController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final _selectedBusiness = Rxn<BrowseBusinessModel>();
  final _isSubmitting = false.obs;

  bool get _showResults =>
      widget.isActive &&
      _selectedBusiness.value == null &&
      (widget.isLoading ||
          widget.suggestions.isNotEmpty ||
          widget.searchDone);

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant PollMentionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive && !widget.isActive) {
      if (_focusNode.hasFocus) _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
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

    if (!_focusNode.hasFocus || _isSubmitting.value) return;
    _ensureFieldVisible();
  }

  void _focusField() {
    if (_isSubmitting.value) return;
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  /// Scrolls the feed so this mention field is brought to the top of the visible screen area.
  void _ensureFieldVisible() {
    Timer(const Duration(milliseconds: 300), _scrollToSelf);
  }

  void _scrollToSelf() {
    if (!mounted || _isSubmitting.value) return;
    Scrollable.ensureVisible(
      context,
      alignment: 0.05, // Push near top of visible viewport when focused
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  // ── Text & business selection ───────────────────────────────────────────

  void _clearSelectedBusiness() {
    _mentionController.clear();
    _selectedBusiness.value = null;
    setState(() {});
    widget.onChanged?.call(widget.postId, '');
  }

  void _onBusinessTapped(BrowseBusinessModel business) {
    _mentionController.value = TextEditingValue(
      text: business.name,
      selection: TextSelection.collapsed(offset: business.name.length),
    );
    _selectedBusiness.value = business;
    setState(() {});
    widget.onBusinessSelected?.call(widget.postId, business);

    // Unfocus keyboard so it dismisses, then center the post card
    _focusNode.unfocus();
    Timer(const Duration(milliseconds: 200), _centerPostInView);
  }

  void _centerPostInView() {
    if (!mounted) return;
    Scrollable.ensureVisible(
      context,
      alignment: 0.5, // Center in viewport
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _submit() async {
    final business = _selectedBusiness.value;
    final text = _mentionController.text.trim();
    if (text.isEmpty || _isSubmitting.value || business == null) return;

    _isSubmitting.value = true;
    _focusNode.unfocus();
    setState(() {});
    try {
      await widget.onSubmit?.call(widget.postId, text, business.logo);
      if (!mounted) return;
      _mentionController.clear();
      _selectedBusiness.value = null;
      setState(() {});
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final focused = _focusNode.hasFocus || _showResults;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Text input row ──
        GestureDetector(
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
                  child: Row(
                    children: [
                      if (_selectedBusiness.value != null) ...[
                        Text(
                          _selectedBusiness.value!.name,
                          style: AppTextStyle.textSm(color: colors.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _clearSelectedBusiness,
                          child: Icon(
                            Icons.cancel_rounded,
                            size: 16,
                            color: colors.error,
                          ),
                        ),
                        const Spacer(),
                      ] else ...[
                        Expanded(
                          child: TextField(
                            controller: _mentionController,
                            focusNode: _focusNode,
                            onChanged: (val) {
                              _ensureFieldVisible();
                              widget.onChanged?.call(widget.postId, val);
                            },
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
                      ],
                    ],
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

        // ── Inline search results ──
        if (_showResults)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _InlineSearchResults(
              isLoading: widget.isLoading,
              suggestions: widget.suggestions,
              hasNextPage: widget.hasNextPage,
              isPaginationLoading: widget.isPaginationLoading,
              onTap: _onBusinessTapped,
              onLoadMore: widget.onLoadMore,
            ),
          ),
      ],
    );
  }
}

// ── Inline search results ─────────────────────────────────────────────────

class _InlineSearchResults extends StatelessWidget {
  final bool isLoading;
  final List<BrowseBusinessModel> suggestions;
  final bool hasNextPage;
  final bool isPaginationLoading;
  final void Function(BrowseBusinessModel) onTap;
  final VoidCallback? onLoadMore;

  const _InlineSearchResults({
    required this.isLoading,
    required this.suggestions,
    required this.hasNextPage,
    required this.isPaginationLoading,
    required this.onTap,
    this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _buildContent(colors),
      ),
    );
  }

  Widget _buildContent(ColorScheme colors) {
    // Loading state — first page
    if (isLoading && suggestions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    // Empty state
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

    // Results list constrained to fixed height (approx 5 items) with internal scrolling
    const double fixedListHeight = 220.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Results header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              Icon(
                Icons.storefront_rounded,
                size: 14,
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              Text(
                'Select a business',
                style: AppTextStyle.textXs(
                  color: colors.onSurfaceVariant,
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          thickness: 0.5,
          color: colors.outlineVariant.withValues(alpha: 0.3),
        ),

        // Scrollable list container capped at fixed height so pagination scrolls internally
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: fixedListHeight),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollUpdateNotification &&
                  hasNextPage &&
                  !isPaginationLoading &&
                  onLoadMore != null) {
                final metrics = notification.metrics;
                if (metrics.pixels >= metrics.maxScrollExtent - 40) {
                  onLoadMore!();
                }
              }
              return false;
            },
            child: ListView.separated(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: suggestions.length + (isPaginationLoading ? 1 : 0),
              separatorBuilder: (_, _) => Divider(
                height: 1,
                thickness: 0.5,
                indent: 44,
                endIndent: 12,
                color: colors.outlineVariant.withValues(alpha: 0.25),
              ),
              itemBuilder: (context, index) {
                if (index == suggestions.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                final business = suggestions[index];
                return _BusinessRow(
                  business: business,
                  colors: colors,
                  onTap: () => onTap(business),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

// ── Business row ──────────────────────────────────────────────────────────

class _BusinessRow extends StatelessWidget {
  final BrowseBusinessModel business;
  final ColorScheme colors;
  final VoidCallback onTap;

  const _BusinessRow({
    required this.business,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        child: Row(
          children: [
            BusinessAvatar(imageUrl: business.logo, size: 28),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: colors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}



// ── User avatar ───────────────────────────────────────────────────────────

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

// ── Send button ───────────────────────────────────────────────────────────

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
