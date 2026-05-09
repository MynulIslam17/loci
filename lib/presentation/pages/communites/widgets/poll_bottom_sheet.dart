import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/models/community/announcement_model.dart';
import 'package:loci/presentation/pages/home/widgets/poll_bar.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PollBottomSheet extends StatefulWidget {
  final String? pollQuestion;
  final int totalVotes;
  final List<PollOption> options;
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
    AnnouncementModel announcement, {
    String? currentUserId,
    void Function(String optionId)? onVote,
  }) {
    final options = announcement.pollOptions;
    if (options == null || options.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PollBottomSheet(
        pollQuestion: announcement.pollQuestion,
        totalVotes: announcement.totalVotes ?? 0,
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
  String? _selectedId;
  String? _myVotedOptionId;

  @override
  void initState() {
    super.initState();
    if (widget.currentUserId != null && widget.currentUserId!.isNotEmpty) {
      _myVotedOptionId = widget.options
          .where((opt) =>
              opt.voters.any((v) => v.userId == widget.currentUserId))
          .map((opt) => opt.id)
          .firstOrNull;
    }
    _selectedId = _myVotedOptionId;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.options.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, index) {
              final opt = widget.options[index];
              final isSelected = _selectedId == opt.id;
              final percent = widget.totalVotes > 0
                  ? (opt.voteCount / widget.totalVotes).clamp(0.0, 1.0)
                  : 0.0;

              return GestureDetector(
                onTap: () => setState(() => _selectedId = opt.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
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
                      // Option image on the left
                      if (opt.image != null && opt.image!.isNotEmpty) ...[
                        CustomCachedImage(
                          width: 44,
                          height: 44,
                          isCircle: true,
                          imageUrl: opt.image,
                        ),
                        const SizedBox(width: 12),
                      ],

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
                            // Progress bar + percentage
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
                                        : context.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            // Voter stack
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
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedId == null || _selectedId == _myVotedOptionId
                  ? null
                  : () {
                      widget.onVote?.call(_selectedId!);
                      Navigator.pop(context);
                    },
              child: Text(
                _selectedId == _myVotedOptionId && _myVotedOptionId != null
                    ? 'Already Voted'
                    : _myVotedOptionId != null
                        ? 'Change Vote'
                        : 'Vote',
              ),
            ),
          ),
        ],
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
