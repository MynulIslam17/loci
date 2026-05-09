import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/presentation/controllers/comment/announcement_controller.dart';
import 'package:loci/presentation/pages/communites/widgets/community_search_bar.dart';
import 'package:loci/presentation/pages/communites/widgets/notice_card.dart';
class NoticesTab extends StatelessWidget {
  final TextEditingController searchController;
  final void Function(String postId) onCommentTap;
  final void Function(String postId) onLikeTap;

  const NoticesTab({
    super.key,
    required this.searchController,
    required this.onCommentTap,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AnnouncementController>(
      builder: (ctrl) => Column(
        children: [
          CommunitySearchBar(controller: searchController, hintText: "Search notices"),
          const SizedBox(height: 20),
          ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ctrl.announcements.length,
              itemBuilder: (context, index) {
                final notice = ctrl.announcements[index];
                final business = notice.business;
                return CommunityNoticeCard(
                  profileImage: business?.logo ?? "",
                  businessName: business?.name ?? "",
                  dateTime: formatDateTime(notice.createdAt),
                  noticeText: notice.details,
                  likes: (notice.likeCount ?? 0).toString(),
                  comments: (notice.commentCount ?? 0).toString(),
                  isLiked: notice.isLiked,
                  onCommentTap: () => onCommentTap(notice.id),
                  onLikeTap: () => onLikeTap(notice.id),
                );
              },
            ),
        ],
      ),
    );
  }
}
