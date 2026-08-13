import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/models/post_card_view_model.dart';
import 'package:loci/shared/widgets/feed/poll_bar.dart';

/// Collapsed poll preview shown inside a [PostCardWidget]: the leading options
/// (see [PostCardViewModel.previewOptions]) plus a "See all" affordance when
/// there are more. Tapping anywhere opens the full poll via [onTap].
class PollPreview extends StatelessWidget {
  final PostCardViewModel viewModel;
  final String? currentUserId;
  final VoidCallback? onTap;

  /// Number of options shown before "See all". Kept in sync with the preview
  /// ranking below.
  static const int _previewCount = 2;

  const PollPreview({
    super.key,
    required this.viewModel,
    this.currentUserId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final options = viewModel.pollOptions;
    if (options == null || options.isEmpty) return const SizedBox.shrink();

    final preview = viewModel.previewOptions(
      max: _previewCount,
      currentUserId: currentUserId,
    );

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...preview.map((opt) {
            final percent = viewModel.totalVotes > 0
                ? opt.voteCount / viewModel.totalVotes
                : 0.0;
            final isVoted =
                currentUserId != null &&
                currentUserId!.isNotEmpty &&
                opt.voters.any((v) => v.userId == currentUserId);
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: PollBar(
                title: opt.text,
                percent: percent,
                percentage: opt.percentage,
                imagePath: opt.image,
                voters: opt.voters,
                isVoted: isVoted,
              ),
            );
          }),
          if (options.length > _previewCount)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'See all ${options.length} options',
                style: AppTextStyle.textSm(
                  color: colors.primary,
                  weight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
