import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/pages/communites/widgets/post_card_view_model.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import '../../../../core/constants/app_text_style.dart';
import '../../home/widgets/expandable_text.dart';
import '../../home/widgets/poll_bar.dart';
import '../../home/widgets/post_interaction_bar.dart';
import '../../home/widgets/user_post_header.dart';

class PostCardWidget extends StatefulWidget {
  final PostCardViewModel viewModel;

  final void Function(String postId)? onLikeTap;
  final void Function(String postId)? onCommentTap;
  final void Function(String postId)? onClickPoll;

  final TextEditingController? controller;
  final void Function(String postId, String value)? onSubmit;
  final void Function(String postId, String value)? onChanged;

  const PostCardWidget({
    super.key,
    required this.viewModel,
    this.onLikeTap,
    this.onCommentTap,
    this.onClickPoll,
    this.controller,
    this.onSubmit,
    this.onChanged,
  });

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = widget.viewModel;

    return Card(
      color: Theme.of(context).colorScheme.surfaceContainer,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserPostHeader(
              fullName: vm.userName,
              date: vm.date,
              category: vm.category,
              imagePath: vm.userImage,
            ),
            const SizedBox(height: 20),

            ExpandableText(text: vm.text, trimLines: 2),

            if (vm.pollOptions != null && vm.pollOptions!.isNotEmpty) ...[
              const SizedBox(height: 20),
              InkWell(
                onTap: () => widget.onClickPoll?.call(vm.postId),
                child: ListView.separated(
                  clipBehavior: Clip.antiAlias,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: vm.pollOptions!.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final opt = vm.pollOptions![index];
                    final percent =
                        vm.totalVotes > 0 ? opt.voteCount / vm.totalVotes : 0.0;
                    return PollBar(
                      title: opt.text,
                      percent: percent,
                      imagePath: opt.image ?? '',
                      trailingText: '${opt.voteCount} votes',
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 20),

            Row(
              children: [
                CustomCachedImage(
                  width: 40,
                  height: 40,
                  isCircle: true,
                  imageUrl: "assets/images/logo.png",
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) =>
                        widget.onChanged?.call(vm.postId, value),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        widget.onSubmit?.call(vm.postId, value.trim());
                        _controller.clear();
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Mention the business...',
                      hintStyle: AppTextStyle.textXs(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      border: const UnderlineInputBorder(),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: context.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          if (_controller.text.trim().isNotEmpty) {
                            widget.onSubmit
                                ?.call(vm.postId, _controller.text.trim());
                            _controller.clear();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            PostInteractionBar(
              likes: vm.likes,
              comments: vm.comments,
              onLikeTap: () => widget.onLikeTap?.call(vm.postId),
              onCommentTap: () => widget.onCommentTap?.call(vm.postId),
            ),
          ],
        ),
      ),
    );
  }
}
