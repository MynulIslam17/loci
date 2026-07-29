import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/community/presentation/controllers/announcements_comment_controller.dart';
import 'package:loci/features/home/presentation/controllers/home_comment_controller.dart';
import 'package:loci/shared/widgets/feed/post_comment_section.dart';

/// Shared modal comment UI for home and community.
abstract final class PostCommentBottomSheet {
  static Future<void> showForAnnouncement(
    BuildContext context, {
    required String postId,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => _AnnouncementCommentSheet(postId: postId),
    ).whenComplete(() => FocusManager.instance.primaryFocus?.unfocus());
  }

  static Future<void> showForHomeQuestion(
    BuildContext context, {
    required String questionId,
    required HomeCommentController commentController,
    required String currentUserImage,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _HomeCommentSheet(
        questionId: questionId,
        commentController: commentController,
        currentUserImage: currentUserImage,
      ),
    ).whenComplete(() => FocusManager.instance.primaryFocus?.unfocus());
  }
}

class _AnnouncementCommentSheet extends StatefulWidget {
  const _AnnouncementCommentSheet({required this.postId});

  final String postId;

  @override
  State<_AnnouncementCommentSheet> createState() =>
      _AnnouncementCommentSheetState();
}

class _AnnouncementCommentSheetState extends State<_AnnouncementCommentSheet> {
  late final TextEditingController _input;

  CommentController get _comments => Get.find<CommentController>();

  @override
  void initState() {
    super.initState();
    _input = TextEditingController();
    _comments.fetchComments(postId: widget.postId);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.find<AuthController>();
    return Obx(
      () => PostCommentSection(
        comments: _comments.comments.toList(),
        controller: _input,
        scrollController: _comments.scrollController,
        paginationLoading: _comments.isPaginationLoading.value,
        currentUserImage: auth.userModel?.avatar ?? '',
        isLoading: _comments.isLoading.value,
        isSending: _comments.isPosting.value,
        onSendTap: (text) => _comments.postComment(
          content: text,
          postId: widget.postId,
        ),
      ),
    );
  }
}

class _HomeCommentSheet extends StatefulWidget {
  const _HomeCommentSheet({
    required this.questionId,
    required this.commentController,
    required this.currentUserImage,
  });

  final String questionId;
  final HomeCommentController commentController;
  final String currentUserImage;

  @override
  State<_HomeCommentSheet> createState() => _HomeCommentSheetState();
}

class _HomeCommentSheetState extends State<_HomeCommentSheet> {
  late final TextEditingController _input;

  @override
  void initState() {
    super.initState();
    _input = TextEditingController();
    widget.commentController.fetchComments(questionId: widget.questionId);
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.commentController;
    return Obx(
      () => PostCommentSection(
        comments: ctrl.comments.toList(),
        controller: _input,
        scrollController: ctrl.scrollController,
        paginationLoading: ctrl.isPaginating.value,
        currentUserImage: widget.currentUserImage,
        isLoading: ctrl.isLoading.value,
        isSending: ctrl.isPosting.value,
        onSendTap: (text) => ctrl.postComment(
          content: text,
          questionId: widget.questionId,
        ),
      ),
    );
  }
}
