import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/browse_business/data/models/browse_business_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/community/presentation/controllers/search_business_controller.dart';
import 'package:loci/features/main_nav/presentation/widgets/ios_glass_bottom_nav_bar.dart';
import 'package:loci/shared/widgets/app_skeleton.dart';
import 'package:loci/shared/widgets/business_avatar.dart';

/// Clean, simple bottom sheet modal for mentioning a business.
///
/// Features:
/// - Shimmer on initial load and when searching
/// - Instant display of default businesses when search is cleared
/// - Simple, clean business list tiles
class BusinessMentionBottomSheet extends StatefulWidget {
  const BusinessMentionBottomSheet({super.key});

  /// Opens the modal bottom sheet and returns the selected [BrowseBusinessModel],
  /// or `null` if dismissed without selection.
  static Future<BrowseBusinessModel?> show(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();

    return showModalBottomSheet<BrowseBusinessModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const BusinessMentionBottomSheet(),
    ).whenComplete(() => FocusManager.instance.primaryFocus?.unfocus());
  }

  @override
  State<BusinessMentionBottomSheet> createState() =>
      _BusinessMentionBottomSheetState();
}

class _BusinessMentionBottomSheetState
    extends State<BusinessMentionBottomSheet> {
  late final SearchBusinessController _searchCtrl;
  late final TextEditingController _textCtrl;
  late final FocusNode _focusNode;
  final ScrollController _scrollController = ScrollController();

  static const _tag = 'mention_bottom_sheet_search';

  @override
  void initState() {
    super.initState();
    _searchCtrl = Get.put(
      SearchBusinessController(Get.find<CommunityService>()),
      tag: _tag,
    );
    _textCtrl = TextEditingController();
    _focusNode = FocusNode();
    _scrollController.addListener(_onScroll);

    // Initial search: loads available default businesses (with shimmer on first open)
    _searchCtrl.onSearchChanged('', immediate: true);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 60 &&
        _searchCtrl.hasNextPage &&
        !_searchCtrl.isPaginationLoading.value) {
      _searchCtrl.loadNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _textCtrl.dispose();
    Get.delete<SearchBusinessController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;
    final bottomPadding = viewInsets.bottom > 0
        ? viewInsets.bottom + 12
        : IosGlassBottomNavBar.overlayBottomInset(context) + 20;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Drag handle ──
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // ── Header Title & Close ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 20,
                    color: colors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mention a Business',
                        style: AppTextStyle.textLg(
                          weight: FontWeight.w700,
                          color: colors.onSurface,
                        ),
                      ),
                      Text(
                        'Search and select a business to suggest',
                        style: AppTextStyle.textXs(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: colors.onSurfaceVariant,
                    size: 22,
                  ),
                  tooltip: 'Close',
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Search Input Box ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.4),
                ),
              ),
              child: TextField(
                controller: _textCtrl,
                focusNode: _focusNode,
                autofocus: true,
                style: AppTextStyle.textSm(color: colors.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search businesses by name...',
                  hintStyle: AppTextStyle.textSm(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.primary,
                    size: 22,
                  ),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _textCtrl,
                    builder: (_, value, _) {
                      if (value.text.isEmpty) return const SizedBox.shrink();
                      return IconButton(
                        icon: Icon(
                          Icons.cancel_rounded,
                          size: 18,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                        onPressed: () {
                          _textCtrl.clear();
                          setState(() {});
                          // Instantly restores default businesses without shimmer
                          _searchCtrl.restoreDefaults();
                        },
                      );
                    },
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: (val) {
                  setState(() {});
                  _searchCtrl.onSearchChanged(val);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            thickness: 0.5,
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),

          // ── Results List / Shimmer ──
          Expanded(
            child: Obx(() {
              final status = _searchCtrl.status.value;
              final businesses = _searchCtrl.businesses;
              final isPaginationLoading =
                  _searchCtrl.isPaginationLoading.value;

              // Shimmer during initial load and while searching
              if (status == SearchBusinessStatus.loading &&
                  businesses.isEmpty) {
                return _buildShimmerList(colors);
              }

              // Error state
              if (status == SearchBusinessStatus.error && businesses.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 36,
                          color: colors.error,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _searchCtrl.errorMessage.value ??
                              'Could not load businesses',
                          style: AppTextStyle.textSm(
                            weight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        FilledButton.tonal(
                          onPressed: _searchCtrl.retry,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Empty state
              if (businesses.isEmpty) {
                final query = _textCtrl.text.trim();
                final isTyping = query.isNotEmpty;

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 24,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isTyping
                                ? Icons.search_off_rounded
                                : Icons.storefront_outlined,
                            size: 36,
                            color: colors.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          isTyping
                              ? 'No results for "$query"'
                              : 'No businesses available',
                          style: AppTextStyle.textSm(
                            weight: FontWeight.w600,
                            color: colors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isTyping
                              ? 'Check your spelling or search for another business or category'
                              : 'Businesses will appear here once added',
                          style: AppTextStyle.textXs(
                            color: colors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (isTyping) ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              _textCtrl.clear();
                              setState(() {});
                              _searchCtrl.restoreDefaults();
                            },
                            icon:
                                const Icon(Icons.clear_all_rounded, size: 18),
                            label: const Text('View All Businesses'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.primary,
                              side: BorderSide(
                                color: colors.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              // Results ListView
              return ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.fromLTRB(16, 6, 16, bottomPadding),
                itemCount:
                    businesses.length + (isPaginationLoading ? 1 : 0),
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  thickness: 0.5,
                  indent: 52,
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                ),
                itemBuilder: (context, index) {
                  if (index >= businesses.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  }

                  final business = businesses[index];
                  return _BusinessCardTile(
                    business: business,
                    onTap: () => Navigator.of(context).pop(business),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList(ColorScheme colors) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
      itemCount: 6,
      separatorBuilder: (_, _) => Divider(
        height: 1,
        thickness: 0.5,
        indent: 52,
        color: colors.outlineVariant.withValues(alpha: 0.25),
      ),
      itemBuilder: (_, _) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            SkeletonBox(width: 40, height: 40, radius: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 140, height: 14, radius: 4),
                  SizedBox(height: 6),
                  SkeletonBox(width: 80, height: 10, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Simple, clean business list tile.
class _BusinessCardTile extends StatelessWidget {
  final BrowseBusinessModel business;
  final VoidCallback onTap;

  const _BusinessCardTile({
    required this.business,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final category = business.category.trim();

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            BusinessAvatar(
              imageUrl: business.logo,
              size: 40,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    business.name,
                    style: AppTextStyle.textSm(
                      weight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (category.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      category,
                      style: AppTextStyle.textXs(
                        color: colors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: colors.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
