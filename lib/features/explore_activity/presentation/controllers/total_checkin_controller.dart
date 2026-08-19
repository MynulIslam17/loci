import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/explore_activity/data/models/activity_attendee_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class TotalCheckinController extends GetxController {
  TotalCheckinController(this._service);

  final ExploreActivityService _service;

  final RxBool _isLoading = false.obs;
  final RxBool _isRefreshing = false.obs;
  final RxBool _isExporting = false.obs;
  final RxnString _errorMessage = RxnString();
  final RxList<CheckInAttendeeModel> _attendees = <CheckInAttendeeModel>[].obs;

  String? _entityId;
  String _activityType = 'event'; // 'event' or 'route'
  String _searchQuery = '';
  Timer? _searchDebounce;

  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  bool get isExporting => _isExporting.value;
  String? get errorMessage => _errorMessage.value;
  String? get entityId => _entityId;
  String get activityType => _activityType;

  List<CheckInAttendeeModel> get attendees {
    if (_searchQuery.trim().isEmpty) return _attendees;
    final query = _searchQuery.trim().toLowerCase();
    return _attendees.where((item) {
      final nameMatches = item.name.toLowerCase().contains(query);
      final emailMatches = item.email.toLowerCase().contains(query);
      final phoneMatches = item.phone.toLowerCase().contains(query);
      final companyMatches = item.company.toLowerCase().contains(query);
      return nameMatches || emailMatches || phoneMatches || companyMatches;
    }).toList();
  }

  int get totalCount => attendees.length;

  void initForActivity({required String entityId, String type = 'event'}) {
    if (_entityId == entityId &&
        _activityType == type &&
        _attendees.isNotEmpty) {
      return;
    }
    _entityId = entityId;
    _activityType = type;
    fetchCheckins();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      _attendees.refresh();
    } else {
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        _attendees.refresh();
      });
    }
  }

  Future<void> fetchCheckins({bool isRefresh = false}) async {
    final id = _entityId;
    if (id == null || id.isEmpty) return;

    if (isRefresh) {
      _isRefreshing.value = true;
    } else {
      _isLoading.value = true;
    }
    _errorMessage.value = null;

    try {
      final List<CheckInAttendeeModel> list;
      if (_activityType == 'route') {
        list = await _service.getRouteCheckins(routeId: id);
      } else {
        list = await _service.getEventCheckins(eventId: id);
      }
      _attendees.assignAll(list);
    } catch (e) {
      _errorMessage.value = AppErrorMessages.sanitize(e);
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  Future<void> exportCsv() async {
    final id = _entityId;
    if (id == null || id.isEmpty) {
      SnackbarService.error('Activity ID not found');
      return;
    }

    try {
      _isExporting.value = true;
      final String csv;
      if (_activityType == 'route') {
        csv = await _service.exportRouteCheckinsCsv(routeId: id);
      } else {
        csv = await _service.exportEventCheckinsCsv(eventId: id);
      }

      if (csv.trim().isEmpty) {
        SnackbarService.error('No check-in data to export');
        return;
      }

      final fileName = '$_activityType-checkins-$id.csv';
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Check-in Leads',
        fileName: fileName,
        bytes: utf8.encode(csv),
      );

      if (savedPath != null) {
        SnackbarService.success('Check-in leads saved successfully');
      }
    } catch (e) {
      SnackbarService.error(AppErrorMessages.sanitize(e));
    } finally {
      _isExporting.value = false;
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }
}
