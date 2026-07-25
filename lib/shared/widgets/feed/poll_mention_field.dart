import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/shared/widgets/business_avatar.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';

/// The "mention a business" input shown under a poll post: current-user avatar,
/// a text field with an inline send button, and the business suggestion
/// dropdown. Owns its own input/selection/submitting state so the host card
/// stays stateless.
///
/// Suggestions are fully controlled by the parent via [suggestions] /
/// [isLoading] / [searchDone]; this widget just reports [onChanged],
/// [onBusinessSelected] and [onSubmit] back up.
class PollMentionField extends StatefulWidget {
  final String postId;
  final String currentUserImage;

  final List<BrowseBusinessModel> suggestions;
  final bool isLoading;
  final bool searchDone;

  final void Function(String postId, String query)? onChanged;
  final void Function(String postId, BrowseBusinessModel business)?
  onBusinessSelected;
  final Future<void> Function(String postId, String text, String image)?
  onSubmit;

  const PollMentionField({
    super.key,
    required this.postId,
    required this.currentUserImage,
    this.suggestions = const [],
    this.isLoading = false,
    this.searchDone = false,
    this.onChanged,
    this.onBusinessSelected,
    this.onSubmit,
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

  void _onTextChanged(String value) {
    if (_selectedBusiness.value != null &&
        value != _selectedBusiness.value!.name) {
      _selectedBusiness.value = null;
    }
    widget.onChanged?.call(widget.postId, value);
  }

  void _onBusinessTapped(BrowseBusinessModel business) {
    _mentionController.text = business.name;
    _selectedBusiness.value = business;
    widget.onBusinessSelected?.call(widget.postId, business);
  }

  Future<void> _submit() async {
    final business = _selectedBusiness.value;
    final text = _mentionController.text.trim();
    if (text.isEmpty || _isSubmitting.value || business == null) {
      return;
    }
    _isSubmitting.value = true;
    try {
      // Logo only — empty string means "no image" and the repository
      // omits the field entirely in that case.
      await widget.onSubmit?.call(widget.postId, text, business.logo);
      _mentionController.clear();
      _selectedBusiness.value = null;
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final showDropdown =
        widget.isLoading ||
        widget.suggestions.isNotEmpty ||
        widget.searchDone;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // Avatar of the logged-in user. AuthController is outside assigned
            // dirs and not yet Rx — read current value directly.
            Builder(
              builder: (context) {
                final auth = Get.find<AuthController>();
                final avatar =
                    auth.userModel?.avatar ?? widget.currentUserImage;
                if (avatar.isEmpty) {
                  return CircleAvatar(
                    radius: 20,
                    backgroundColor: colors.primary.withValues(alpha: 0.1),
                    child: Icon(
                      Icons.person_rounded,
                      size: 22,
                      color: colors.primary,
                    ),
                  );
                }
                return CustomCachedImage(
                  width: 40,
                  height: 40,
                  isCircle: true,
                  imageUrl: avatar,
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _mentionController,
                onChanged: _onTextChanged,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Mention the business...',
                  hintStyle: AppTextStyle.textXs(
                    color: colors.onSurfaceVariant,
                  ),
                  border: const UnderlineInputBorder(),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: colors.primary, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  // Tight box so the 36px circle isn't offset by the suffix's
                  // default 48px minimum.
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  suffixIcon: Obx(() {
                    final isSubmitting = _isSubmitting.value;
                    final hasBusiness = _selectedBusiness.value != null;
                    return _SendButton(
                      isSubmitting: isSubmitting,
                      enabled: hasBusiness && !isSubmitting,
                      onTap: _submit,
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
        if (showDropdown) ...[
          const SizedBox(height: 4),
          _SuggestionDropdown(
            isLoading: widget.isLoading,
            suggestions: widget.suggestions,
            colors: colors,
            onTap: _onBusinessTapped,
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Send button for the mention field.
//
// Keeps a fixed 36×36 footprint across all three states so the layout never
// shifts: disabled (muted), enabled (filled primary), submitting (same filled
// circle with the icon cross-faded into a spinner — the button never hides).
// ---------------------------------------------------------------------------
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? colors.primary
              : colors.onSurface.withValues(alpha: 0.08),
        ),
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: isSubmitting
                    ? SizedBox(
                        key: const ValueKey('loader'),
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colors.onPrimary,
                          ),
                        ),
                      )
                    // Nudge right ~1px: the paper-plane glyph is optically
                    // weighted left, so its bounding-box center sits left of
                    // the visual center.
                    : Transform.translate(
                        key: const ValueKey('icon'),
                        offset: const Offset(1, 0),
                        child: Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: enabled
                              ? colors.onPrimary
                              : colors.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Business suggestion dropdown.
// ---------------------------------------------------------------------------
class _SuggestionDropdown extends StatelessWidget {
  final bool isLoading;
  final List<BrowseBusinessModel> suggestions;
  final ColorScheme colors;
  final void Function(BrowseBusinessModel) onTap;

  const _SuggestionDropdown({
    required this.isLoading,
    required this.suggestions,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outline),
      ),
      child: isLoading
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : suggestions.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                'No businesses found',
                style: AppTextStyle.textSm(color: colors.onSurfaceVariant),
              ),
            )
          : ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: suggestions.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: colors.outline),
                itemBuilder: (context, index) {
                  final business = suggestions[index];
                  return ListTile(
                    dense: true,
                    leading: BusinessAvatar(imageUrl: business.logo, size: 32),
                    title: Text(
                      business.name,
                      style: AppTextStyle.textSm(color: colors.onSurface),
                    ),
                    subtitle: Text(
                      business.category,
                      style: AppTextStyle.textXs(color: colors.onSurfaceVariant),
                    ),
                    onTap: () => onTap(business),
                  );
                },
              ),
            ),
    );
  }
}
