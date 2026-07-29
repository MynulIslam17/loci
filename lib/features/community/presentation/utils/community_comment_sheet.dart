import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/community/presentation/controllers/announcements_comment_controller.dart';
import 'package:loci/shared/widgets/feed/post_comment_section.dart';

abstract final class CommunityCommentSheet {
  static void show(BuildContext context, {required String announcementId}) {
    final inputController = TextEditingController();
    final commentController = Get.find<CommentController>();
    final auth = Get.find<AuthController>();

    commentController.fetchComments(postId: announcementId);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Obx(
        () => PostCommentSection(
          comments: commentController.comments.toList(),
          controller: inputController,
          scrollController: commentController.scrollController,
          paginationLoading: commentController.isPaginationLoading.value,
          currentUserImage: auth.userModel?.avatar ?? '',
          isLoading: commentController.isLoading.value,
          isSending: commentController.isPosting.value,
          onSendTap: (text) => commentController.postComment(
            content: text,
            postId: announcementId,
          ),
        ),
      ),
    ).whenComplete(inputController.dispose);
  }
}
