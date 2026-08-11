import 'package:flutter/material.dart';
import 'package:loci/shared/widgets/feed/post_comment_bottom_sheet.dart';

abstract final class CommunityCommentSheet {
  static void show(BuildContext context, {required String announcementId}) {
    PostCommentBottomSheet.showForAnnouncement(
      context,
      postId: announcementId,
    );
  }
}
