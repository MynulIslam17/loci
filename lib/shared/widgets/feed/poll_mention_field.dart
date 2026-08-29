import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/feed/business_mention_bottom_sheet.dart';

/// Compact mention field for poll cards in a multi-post feed.
///
/// Tapping the field opens a sleek [BusinessMentionBottomSheet] modal picker
/// that completely avoids keyboard overlapping or nesting scroll issues.
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
  final _selectedBusiness = Rxn<BrowseBusinessModel>();
  final _isSubmitting = false.obs;

  @override
  void dispose() {
    _mentionController.dispose();
    super.dispose();
  }

  // ── Modal Search ────────────────────────────────────────────────────────

  Future<void> _openBottomSheetSearch() async {
    if (_isSubmitting.value) return;
    final business = await BusinessMentionBottomSheet.show(context);
    if (business != null && mounted) {
      _onBusinessTapped(business);
    }
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

    // Center the post card in view
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
    final hasBusiness = _selectedBusiness.value != null;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: hasBusiness ? null : _openBottomSheetSearch,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.fromLTRB(8, 3, 3, 3),
        decoration: BoxDecoration(
          color: hasBusiness
              ? colors.primary.withValues(alpha: 0.06)
              : colors.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasBusiness
                ? colors.primary.withValues(alpha: 0.55)
                : colors.outline.withValues(alpha: 0.4),
            width: hasBusiness ? 1.4 : 1,
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
                    Flexible(
                      child: Text(
                        _selectedBusiness.value!.name,
                        style: AppTextStyle.textSm(
                          color: colors.onSurface,
                          weight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: _clearSelectedBusiness,
                      child: Icon(
                        Icons.cancel_rounded,
                        size: 18,
                        color: colors.error,
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        child: Text(
                          'Mention a business…',
                          style: AppTextStyle.textXs(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Obx(() {
              final isSubmitting = _isSubmitting.value;
              final hasSelected = _selectedBusiness.value != null;
              return _SendButton(
                isSubmitting: isSubmitting,
                enabled: hasSelected && !isSubmitting,
                onTap: _submit,
              );
            }),
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
