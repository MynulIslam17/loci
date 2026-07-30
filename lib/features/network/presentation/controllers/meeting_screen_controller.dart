import 'package:get/get.dart';
import 'package:loci/features/network/presentation/controllers/incoming_meetings_controller.dart';
import 'package:loci/features/network/presentation/controllers/sent_meetings_controller.dart';
import 'package:table_calendar/table_calendar.dart';

/// Calendar UI state and coordination between sent/received meeting lists.
class MeetingScreenController extends GetxController {
  late final SentMeetingsController _sentCtrl;
  late final IncomingMeetingsController _incomingCtrl;

  final _selectedDate = DateTime.now().obs;
  final _focusedDate = DateTime.now().obs;
  final _calendarFormat = CalendarFormat.week.obs;
  final _markerRefresh = 0.obs;

  DateTime get selectedDate => _selectedDate.value;
  DateTime get focusedDate => _focusedDate.value;
  CalendarFormat get calendarFormat => _calendarFormat.value;
  int get markerRefresh => _markerRefresh.value;

  Set<DateTime> get markedDates => {
    ..._sentCtrl.markedDates,
    ..._incomingCtrl.markedDates,
  };

  @override
  void onInit() {
    super.onInit();
    _sentCtrl = Get.find<SentMeetingsController>();
    _incomingCtrl = Get.find<IncomingMeetingsController>();
    _selectedDate.value = _normalize(DateTime.now());
    _sentCtrl.addListener(_onMeetingListsUpdated);
    _incomingCtrl.addListener(_onMeetingListsUpdated);
  }

  @override
  void onClose() {
    _sentCtrl.removeListener(_onMeetingListsUpdated);
    _incomingCtrl.removeListener(_onMeetingListsUpdated);
    super.onClose();
  }

  void _onMeetingListsUpdated() => _markerRefresh.value++;

  DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void onDaySelected(DateTime selected, DateTime focused) {
    final normalized = _normalize(selected);
    _selectedDate.value = normalized;
    _focusedDate.value = focused;
    _sentCtrl.setSelectedDate(normalized);
    _incomingCtrl.setSelectedDate(normalized);
  }

  void onPageChanged(DateTime focused) => _focusedDate.value = focused;

  void onFormatChanged(CalendarFormat format) {
    _calendarFormat.value = format;
    _markerRefresh.value++;
  }

  void collapseToWeekView() => onFormatChanged(CalendarFormat.week);

  void expandToMonthView() => onFormatChanged(CalendarFormat.month);

  void toggleCalendarFormat() {
    if (_calendarFormat.value == CalendarFormat.week) {
      expandToMonthView();
    } else {
      collapseToWeekView();
    }
  }

  bool get isWeekView => _calendarFormat.value == CalendarFormat.week;
}
