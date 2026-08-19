import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/app_error_messages.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/explore_activity/data/models/activity_attendee_model.dart';
import 'package:loci/features/explore_activity/domain/services/explore_activity_service.dart';

class TotalParticipantsController extends GetxController {
  TotalParticipantsController(this._service);

  final ExploreActivityService _service;

  final RxBool _isLoading = false.obs;
  final RxBool _isRefreshing = false.obs;
  final RxBool _isExporting = false.obs;
  final RxnString _errorMessage = RxnString();
  final RxList<RaffleParticipantAttendeeModel> _participants =
      <RaffleParticipantAttendeeModel>[].obs;

  String? _raffleId;
  String _searchQuery = '';
  Timer? _searchDebounce;

  bool get isLoading => _isLoading.value;
  bool get isRefreshing => _isRefreshing.value;
  bool get isExporting => _isExporting.value;
  String? get errorMessage => _errorMessage.value;
  String? get raffleId => _raffleId;

  List<RaffleParticipantAttendeeModel> get participants {
    if (_searchQuery.trim().isEmpty) return _participants;
    final query = _searchQuery.trim().toLowerCase();
    return _participants.where((item) {
      final nameMatches = item.name.toLowerCase().contains(query);
      final emailMatches = item.email.toLowerCase().contains(query);
      final phoneMatches = item.phone.toLowerCase().contains(query);
      final companyMatches = item.company.toLowerCase().contains(query);
      final voucherMatches =
          item.voucherCode?.toLowerCase().contains(query) ?? false;
      return nameMatches ||
          emailMatches ||
          phoneMatches ||
          companyMatches ||
          voucherMatches;
    }).toList();
  }

  int get totalCount => participants.length;

  void initForRaffle(String raffleId) {
    if (_raffleId == raffleId && _participants.isNotEmpty) return;
    _raffleId = raffleId;
    fetchParticipants();
  }

  void onSearchChanged(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    if (query.trim().isEmpty) {
      _participants.refresh();
    } else {
      _searchDebounce = Timer(const Duration(milliseconds: 300), () {
        _participants.refresh();
      });
    }
  }

  Future<void> fetchParticipants({bool isRefresh = false}) async {
    final id = _raffleId;
    if (id == null || id.isEmpty) return;

    if (isRefresh) {
      _isRefreshing.value = true;
    } else {
      _isLoading.value = true;
    }
    _errorMessage.value = null;

    try {
      final list = await _service.getRaffleParticipants(
        raffleId: id,
        page: 1,
        limit: 100,
      );
      _participants.assignAll(list);
    } catch (e) {
      _errorMessage.value = AppErrorMessages.sanitize(e);
    } finally {
      _isLoading.value = false;
      _isRefreshing.value = false;
    }
  }

  Future<void> exportCsv() async {
    final id = _raffleId;
    if (id == null || id.isEmpty) {
      SnackbarService.error('Raffle ID not found');
      return;
    }

    try {
      _isExporting.value = true;
      final csv = await _service.exportRaffleParticipantsCsv(raffleId: id);
      if (csv.trim().isEmpty) {
        SnackbarService.error('No participant data to export');
        return;
      }

      final fileName = 'raffle-participants-$id.csv';
      final savedPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Raffle Participants List',
        fileName: fileName,
        bytes: utf8.encode(csv),
      );

      if (savedPath != null) {
        SnackbarService.success('Participants list saved successfully');
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
