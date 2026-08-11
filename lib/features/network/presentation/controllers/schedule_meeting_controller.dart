import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/features/network/domain/services/network_service.dart';
import 'package:loci/features/network/presentation/controllers/sent_meetings_controller.dart';

class ScheduleMeetingController extends GetxController {
  ScheduleMeetingController(this._service);

  final NetworkService _service;

  final RxBool _isLoading = false.obs;
  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<DateTime> _selectedDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> _selectedTime = Rxn<TimeOfDay>();

  bool get isLoading => _isLoading.value;
  String? get errorMessage => _errorMessage.value;
  DateTime? get selectedDate => _selectedDate.value;
  TimeOfDay? get selectedTime => _selectedTime.value;

  void setSelectedDate(DateTime date) => _selectedDate.value = date;

  void setSelectedTime(TimeOfDay time) => _selectedTime.value = time;

  Future<bool> scheduleMeeting({
    required String recipientName,
    required String recipientEmail,
    required String meetingDate,
    required String meetingTime,
    required String location,
    String? message,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = null;

    try {
      await _service.scheduleMeeting(
        recipientName: recipientName,
        recipientEmail: recipientEmail,
        meetingDate: meetingDate,
        meetingTime: meetingTime,
        location: location,
        message: message,
      );
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> onScheduleSuccess() async {
    if (!Get.isRegistered<SentMeetingsController>()) return;

    final sentCtrl = Get.find<SentMeetingsController>();
    await sentCtrl.fetchSentMeetings();
    await sentCtrl.fetchMarkerDates();
  }
}
