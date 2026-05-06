import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_url.dart';
import 'package:loci/core/network/network_response.dart';
import 'package:loci/core/network/network_caller.dart';
import 'package:loci/data/models/common/paginatation_model.dart';

import '../../../core/enums/announcement_type.dart';
import '../../../data/community/announcement_model.dart';
import '../../../data/community/announcement_response.dart';

class AnnouncementController extends GetxController {

  bool _isLoading = false;
  bool _isPaginationLoading = false;
  String? _errorMessage;

  List<AnnouncementModel> _announcements = [];
  PaginationMeta? _meta;

  int _currentPage = 1;
  AnnouncementType _currentType = AnnouncementType.activity;
  String? _communityId;

  // -------------------------------------------------
  // GETTERS
  // -------------------------------------------------
  bool get isLoading => _isLoading;
  bool get isPaginationLoading => _isPaginationLoading;
  String? get errorMessage => _errorMessage;

  List<AnnouncementModel> get announcements => _announcements;
  PaginationMeta? get meta => _meta;

  bool get hasMore => _meta?.hasNextPage ?? false;

  AnnouncementType get currentType => _currentType;




  // -------------------------------------------------
  // SET COMMUNITY INIT
  // -------------------------------------------------
  Future<void> init(String communityId) async {
    _communityId = communityId;
    await fetchAnnouncements(isRefresh: true);
  }

  // -------------------------------------------------
  // CHANGE TAB TYPE
  // -------------------------------------------------
  void changeType(AnnouncementType type) {
    if (_currentType == type) return;

    _currentType = type;
    fetchAnnouncements(isRefresh: true);
  }

  // -------------------------------------------------
  // FETCH FIRST PAGE
  // -------------------------------------------------
  Future<void> fetchAnnouncements({bool isRefresh = false}) async {
    if (_communityId == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;

      if (isRefresh) {
        _currentPage = 1;
        _announcements = [];
      }

      update();

      final response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.announcementList,
        queryParams: {
          "communityId": _communityId,
          "type": _currentType.toJson,
          "page": _currentPage,
          "limit": 3,
        },
      );

      if (response.isSuccess && response.body != null) {
        final result =
        AnnouncementResponse.fromJson(response.body!);

        _announcements = result.data;
        _meta = result.meta;
      } else {
        _errorMessage =
            response.body?['message'] ?? "Failed to load announcements";
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
  Future<void> fetchMoreAnnouncements() async {
    if (!hasMore || _isPaginationLoading || _communityId == null) return;

    try {
      _isPaginationLoading = true;
      update();

      _currentPage++;

      final response =
      await Get.find<NetworkCaller>().getRequest(
        url: AppUrl.announcementList,
        queryParams: {
          "communityId": _communityId,
          "type": _currentType.toJson,
          "page": _currentPage,
          "limit": 3,
        },
      );

      if (response.isSuccess && response.body != null) {
        final result =
        AnnouncementResponse.fromJson(response.body!);

        _announcements.addAll(result.data);
        _meta = result.meta;
      } else {
        _currentPage--; // rollback
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
  // REFRESH
  // -------------------------------------------------
  Future<void> refreshAnnouncements() async {
    await fetchAnnouncements(isRefresh: true);
  }
}