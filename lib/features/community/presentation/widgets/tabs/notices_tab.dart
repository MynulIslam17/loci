import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/utils/time_parser.dart';
import 'package:loci/features/community/data/models/announcement_author_display.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';
import 'package:loci/features/community/presentation/widgets/notice_card.dart';

class NoticesTab extends StatefulWidget {
  const NoticesTab({
    super.key,
    required this.onCommentTap,
    required this.onLikeTap,
  });

  final void Function(String postId) onCommentTap;
  final void Function(String postId) onLikeTap;

  @override
  State<NoticesTab> createState() => _NoticesTabState();
}

class _NoticesTabState extends State<NoticesTab>
    with AutomaticKeepAliveClientMixin {
  static const _tabType = AnnouncementType.notice;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      final ctrl = Get.find<AnnouncementController>();
      ctrl.revisionFor(_tabType).value;
      ctrl.announcementMap.length;
      ctrl.communityOwnerUserId.value;
      final announcements = ctrl.announcementsFor(_tabType);

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final notice = announcements[index];
              final author = AnnouncementAuthorDisplay.from(
                notice,
                communityOwnerUserId: ctrl.communityOwnerUserId.value,
              );
              return CommunityNoticeCard(
                profileImage: author.avatarUrl,
                displayName: author.displayName,
                isModerator: author.isModerator,
                dateTime: formatDateTime(notice.createdAt),
                noticeText: notice.details,
                likes: (notice.likeCount ?? 0).toString(),
                comments: (notice.commentCount ?? 0).toString(),
                isLiked: notice.isLiked,
                onCommentTap: () => widget.onCommentTap(notice.id),
                onLikeTap: () => widget.onLikeTap(notice.id),
              );
            },
          );
    });
  }
}
