import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/models/post_card_view_model.dart';
import 'package:loci/shared/widgets/feed/poll_bar.dart';
import 'package:loci/shared/widgets/business_avatar.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PollBottomSheet extends StatefulWidget {
  final String? pollQuestion;
  final int totalVotes;
  final List<PostPollOption> options;
  final String? currentUserId;
  final void Function(String optionId)? onVote;

  const PollBottomSheet({
    super.key,
    required this.pollQuestion,
    required this.totalVotes,
    required this.options,
    this.currentUserId,
    this.onVote,
  });

  static void show(
    BuildContext context,
    PostCardViewModel viewModel, {
    String? currentUserId,
    void Function(String optionId)? onVote,
  }) {
    final options = viewModel.pollOptions;
    if (options == null || options.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PollBottomSheet(
        pollQuestion: viewModel.text,
        totalVotes: viewModel.totalVotes,
        options: options,
        currentUserId: currentUserId,
        onVote: onVote,
      ),
    );
  }

  @override
  State<PollBottomSheet> createState() => _PollBottomSheetState();
}

class _PollBottomSheetState extends State<PollBottomSheet> {
  final _selectedId = RxnString();
  String? _myVotedOptionId;

  @override
  void initState() {
    super.initState();
    if (widget.currentUserId != null && widget.currentUserId!.isNotEmpty) {
      _myVotedOptionId = widget.options
          .where(
            (opt) => opt.voters.any((v) => v.userId == widget.currentUserId),
          )
          .map((opt) => opt.id)
          .firstOrNull;
    }
    _selectedId.value = _myVotedOptionId;
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.85;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (widget.pollQuestion != null) ...[
              Text(
                widget.pollQuestion!,
                style: AppTextStyle.textMd(weight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              '${widget.totalVotes} total votes',
              style: AppTextStyle.textXs(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Flexible(
              child: Obx(() {
                // Read the observable synchronously so this Obx subscribes to
                // it — itemBuilder runs during layout, after this builder
                // returns, so reads there don't register (GetX would throw
                // "improper use of GetX" with no synchronous observable).
                final selectedId = _selectedId.value;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemCount: widget.options.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final opt = widget.options[index];
                    final isSelected = selectedId == opt.id;
                    final percent = widget.totalVotes > 0
                        ? (opt.voteCount / widget.totalVotes).clamp(0.0, 1.0)
                        : 0.0;

                    return GestureDetector(
                      onTap: () => _selectedId.value = opt.id,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: isSelected
                              ? context.colorScheme.primary.withOpacity(0.08)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? context.colorScheme.primary
                                : context.colorScheme.outlineVariant,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Always show an avatar — neutral storefront
                            // placeholder when the option has no image / logo.
                            BusinessAvatar(imageUrl: opt.image, size: 44),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    opt.text,
                                    style: AppTextStyle.textSm(
                                      weight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? context.colorScheme.primary
                                          : context.colorScheme.onSurface,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: LinearPercentIndicator(
                                          lineHeight: 8,
                                          percent: percent,
                                          backgroundColor: AppColors.base200,
                                          progressColor: isSelected
                                              ? context.colorScheme.primary
                                              : AppColors.primaryG500,
                                          barRadius: const Radius.circular(10),
                                          animation: true,
                                          animationDuration: 600,
                                          padding: EdgeInsets.zero,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '${opt.percentage.toStringAsFixed(0)}%',
                                        style: AppTextStyle.textXs(
                                          weight: FontWeight.w600,
                                          color: isSelected
                                              ? context.colorScheme.primary
                                              : context
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (opt.voters.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    VoterStack(voters: opt.voters, size: 26),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _RadioDot(isSelected: isSelected),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      _selectedId.value == null ||
                          _selectedId.value == _myVotedOptionId
                      ? null
                      : () {
                          widget.onVote?.call(_selectedId.value!);
                          Navigator.pop(context);
                        },
                  child: Text(
                    _selectedId.value == _myVotedOptionId &&
                            _myVotedOptionId != null
                        ? 'Already Voted'
                        : _myVotedOptionId != null
                        ? 'Change Vote'
                        : 'Vote',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  final bool isSelected;

  const _RadioDot({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected
              ? context.colorScheme.primary
              : context.colorScheme.outline,
          width: 2,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.primary,
                ),
              ),
            )
          : null,
    );
  }
}
