import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/data/models/common/paginatation_model.dart';
import '../../../core/network/network_caller.dart';
import '../../../data/models/comment/comment_model.dart';

class CommentController extends GetxController {
  final ScrollController scrollController = ScrollController();

  bool _isLoading = false;
  bool _isSending = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;

  List<CommentModel> _comments = [];
  PaginationMeta? _meta;

  int _currentPage = 1;
  String? _currentPostId;

  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;
  List<CommentModel> get comments => _comments;
  PaginationMeta? get meta => _meta;
  bool get hasMore => _meta?.hasNextPage ?? false;

  // -------------------------------------------------
  // INIT
  // -------------------------------------------------
  @override
  void onInit() {
    super.onInit();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 100 &&
          !_isPaginationLoading &&
          hasMore &&
          _currentPostId != null) {
        fetchMoreComments(postId: _currentPostId!);
      }
    });
  }

  // -------------------------------------------------
  // CLEANUP
  // -------------------------------------------------
  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  // -------------------------------------------------
  // FETCH FIRST PAGE
  // -------------------------------------------------
  Future<void> fetchComments({required String postId}) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      _currentPostId = postId;
      _currentPage = 1;
      _comments = [];

      update();

      final NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.announcementsComments(postId),
        queryParams: {
          "page": _currentPage,
          "limit": 7,
        },
      );

      if (response.isSuccess && response.body != null) {
        final result = CommentResponse.fromJson(response.body!);
        _comments = result.comments;
        _meta = result.meta;
      } else {
        _errorMessage =
            response.body?['message'] ?? "Failed to load comments";
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      update();
    }
  }

  // -------------------------------------------------
  // PAGINATION
  // -------------------------------------------------
  Future<void> fetchMoreComments({required String postId}) async {
    if (!hasMore || _isPaginationLoading) return;

    try {
      _isPaginationLoading = true;
      update();

      _currentPage++;

      final NetworkResponse response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.announcementsComments(postId),
        queryParams: {
          "page": _currentPage,
          "limit": 10,
        },
      );

      if (response.isSuccess && response.body != null) {
        final result = CommentResponse.fromJson(response.body!);
        _comments.addAll(result.comments);
        _meta = result.meta;
      } else {
        _currentPage--; // rollback
        _errorMessage =
            response.body?['message'] ?? "Failed to load more";
      }
    } catch (e) {
      _currentPage--;
      _errorMessage = e.toString();
    } finally {
      _isPaginationLoading = false;
      update();
    }
  }

  // -------------------------------------------------
  // SEND COMMENT
  // -------------------------------------------------
  Future<bool> sendComment({
    required String postId,
    required String content,
  }) async {
    try {
      _isSending = true;
      _errorMessage = null;
      update();

      final NetworkResponse response =
      await Get.find<NetworkCaller>().postRequest(
        url: AppUrl.announcementsComments(postId),
        body: {"content": content},
      );

      if (response.isSuccess && response.body != null) {
        final newComment =
        CommentModel.fromJson(response.body!['data']);

        _comments.insert(0, newComment);
        update();
        return true;
      } else {
        _errorMessage =
            response.body?['message'] ?? "Failed to send comment";
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isSending = false;
      update();
    }
  }
}