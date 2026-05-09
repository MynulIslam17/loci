import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/data/models/community/announcement_model.dart';
import 'package:loci/presentation/controllers/comment/announcement_controller.dart';
import 'package:loci/presentation/pages/communites/widgets/post_card.dart';
import 'package:loci/presentation/pages/communites/widgets/post_card_view_model.dart';
import 'package:loci/presentation/pages/home/widgets/post_input_filed.dart';

class FeedTab extends StatelessWidget {
  final void Function(String postId) onCommentTap;
  final void Function(AnnouncementModel announcement) onPollTap;
  final void Function(String postId) onLikeTap;

  const FeedTab({
    super.key,
    required this.onCommentTap,
    required this.onPollTap,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AnnouncementController>(
      builder: (ctrl) => Column(
        children: [
          PostInputField(
            categories: const ['Food', 'Drinks', 'Restaurant', 'Entertainment'],
            initialCategory: "Food",
            onSubmit: (text, category) {},
            hintText: 'Post a question...',
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ctrl.announcements.length,
            itemBuilder: (context, index) {
              final announcement = ctrl.announcements[index];
              return PostCardWidget(
                viewModel: PostCardViewModel.from(announcement),
                onLikeTap: (postId) => onLikeTap(postId),
                onCommentTap: (postId) => onCommentTap(postId),
                onClickPoll: (_) => onPollTap(announcement),
                onSubmit: (postId, text) {},
                onChanged: (postId, value) {},
              );
            },
          ),
        ],
      ),
    );
  }
}
