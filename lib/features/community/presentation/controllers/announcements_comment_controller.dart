import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/shared/models/pagination_model.dart';
import 'package:loci/features/community/data/models/comment_model.dart';
import 'package:loci/features/community/domain/services/community_service.dart';
import 'package:loci/features/community/presentation/controllers/announcement_controller.dart';

class CommentController extends GetxController {
  CommentController(this._service);

  final CommunityService _service;
  final ScrollController scrollController = ScrollController();

  final isLoading = false.obs;
  final isPosting = false.obs;
  final isPaginationLoading = false.obs;
  final errorMessage = RxnString();

  final comments = <CommentModel>[].obs;
  final meta = Rxn<PaginationMeta>();

  int _currentPage = 1;
  String? _currentPostId;

  bool get hasMore => meta.value?.hasNextPage ?? false;

  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 100 &&
          !isPaginationLoading.value &&
          hasMore &&
          _currentPostId != null) {
        fetchMoreComments(postId: _currentPostId!);
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchComments({required String postId}) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;
      _currentPostId = postId;
      _currentPage = 1;
      comments.clear();

      final result = await _service.getAnnouncementComments(
        postId: postId,
        page: _currentPage,
        limit: 7,
      );
      comments.assignAll(result.comments);
      meta.value = result.meta;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMoreComments({required String postId}) async {
    if (!hasMore || isPaginationLoading.value) return;

    try {
      isPaginationLoading.value = true;
      _currentPage++;

      final result = await _service.getAnnouncementComments(
        postId: postId,
        page: _currentPage,
        limit: 10,
      );
      comments.addAll(result.comments);
      meta.value = result.meta;
    } catch (e) {
      _currentPage--;
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isPaginationLoading.value = false;
    }
  }

  Future<CommentModel?> postComment({
    required String content,
    required String postId,
  }) async {
    try {
      isPosting.value = true;
      errorMessage.value = null;

      final newComment = await _service.postAnnouncementComment(
        postId: postId,
        content: content,
      );
      Get.find<AnnouncementController>().incrementCommentCount(postId);
      comments.insert(0, newComment);
      return null;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      isPosting.value = false;
    }
  }
}
