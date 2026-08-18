import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/explore_activity/data/models/activity_attendee_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class TotalRsvpController extends GetxController {
  TotalRsvpController(this._service);

  final ExploreActivityService _service;

  final RxBool _isLoading = false.obs;
  final RxBool _isRefreshing = false.obs;
  final RxBool _isExporting = false.obs;
  final RxnString _errorMessage = RxnString();
  final RxList<RsvpAttendeeModel> _attendees = <RsvpAttendeeModel>[].obs;

  String? _eventId;
  String _searchQuery = '';
  Timer? _searchDebounce;

  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  bool get isExporting => _isExporting.value;
  String? get errorMessage => _errorMessage.value;
  String? get eventId => _eventId;

  List<RsvpAttendeeModel> get attendees {
    if (_searchQuery.trim().isEmpty) return _attendees;
    final query = _searchQuery.trim().toLowerCase();
    return _attendees.where((item) {
      final nameMatches = item.name.toLowerCase().contains(query);
      final emailMatches = item.email.toLowerCase().contains(query);
      return nameMatches || emailMatches;
    }).toList();
  }

  int get totalCount => attendees.length;

  void initForEvent(String eventId) {
    if (_eventId == eventId && _attendees.isNotEmpty) return;
    _eventId = eventId;
    fetchRsvpList();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _attendees.refresh();
    });
  }

  Future<void> fetchRsvpList({bool isRefresh = false}) async {
    final id = _eventId;
    if (id == null || id.isEmpty) return;

    if (isRefresh) {
      _isRefreshing.value = true;
    } else {
      _isLoading.value = true;
    }
    _errorMessage.value = null;

    try {
      final list = await _service.getEventRsvpList(
        eventId: id,
        page: 1,
        limit: 100,
      );
      _attendees.assignAll(list);
    } catch (e) {
      _errorMessage.value = AppErrorMessages.sanitize(e);
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  Future<void> exportCsv() async {
    final id = _eventId;
    if (id == null || id.isEmpty) {
      SnackbarService.error('Event ID not found');
      return;
    }

    try {
      _isExporting.value = true;
      final csv = await _service.exportEventRsvpCsv(eventId: id);
      if (csv.trim().isEmpty) {
        SnackbarService.error('No RSVP data to export');
        return;
      }

      final fileName = 'event-rsvp-$id.csv';
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save RSVP List',
        fileName: fileName,
        bytes: utf8.encode(csv),
      );

      if (savedPath != null) {
        SnackbarService.success('RSVP list saved successfully');
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
