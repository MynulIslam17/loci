import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/network_dash/incoming_meetings_controller.dart';
import 'package:loci/presentation/controllers/network_dash/sent_meetings_controller.dart';
import 'package:loci/presentation/pages/network/meetings/tabs/received_meetings_tab.dart';
import 'package:loci/presentation/pages/network/meetings/tabs/sent_meetings_tab.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:table_calendar/table_calendar.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  late final SentMeetingsController _sentCtrl;
  late final IncomingMeetingsController _incomingCtrl;

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final initialTab = (args is Map && args['initialTab'] == 'received') ? 1 : 0;
    _tabController =
        TabController(length: 2, vsync: this, initialIndex: initialTab);
    _selectedDate = _normalize(DateTime.now());

    // Subscribe directly so any markedDates change rebuilds the calendar.
    _sentCtrl = Get.find<SentMeetingsController>();
    _incomingCtrl = Get.find<IncomingMeetingsController>();
    _sentCtrl.addListener(_onControllerUpdate);
    _incomingCtrl.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    _sentCtrl.removeListener(_onControllerUpdate);
    _incomingCtrl.removeListener(_onControllerUpdate);
    _tabController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Union of marked dates across both meeting lists so the calendar can dot
  /// every date that has a sent or incoming meeting.
  Set<DateTime> get _markerSet =>
      {..._sentCtrl.markedDates, ..._incomingCtrl.markedDates};

  void _onDaySelected(DateTime selected, DateTime focused) {
    final normalized = _normalize(selected);
    setState(() {
      _selectedDate = normalized;
      _focusedDate = focused;
    });
    _sentCtrl.setSelectedDate(normalized);
    _incomingCtrl.setSelectedDate(normalized);
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: AppBar(
        title: Text(
          'Meetings',
          style: AppTextStyle.textLg(weight: FontWeight.w700),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// CALENDAR — compact card driven by both meeting lists
          Builder(
            builder: (_) {
              final marks = _markerSet;
              return _CalendarCard(
                key: ValueKey('cal_${marks.length}_${_calendarFormat.index}'),
                selectedDate: _selectedDate,
                focusedDate: _focusedDate,
                format: _calendarFormat,
                markedDates: marks,
                onDaySelected: _onDaySelected,
                onPageChanged: (focused) => _focusedDate = focused,
                onFormatChanged: (fmt) =>
                    setState(() => _calendarFormat = fmt),
              );
            },
          ),

          /// SCHEDULE BUTTON
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: CustomButton(
              backgroundColor: color.primary,
              onPressed: () => Get.toNamed(AppRoutes.scheduleMeeting),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: color.onPrimary),
                  const SizedBox(width: 8),
                  Text(
                    'Schedule New',
                    style: AppTextStyle.textMd(
                      weight: FontWeight.w600,
                      color: color.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// TAB BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: TabBar(
              controller: _tabController,
              labelStyle: AppTextStyle.textSm(weight: FontWeight.w600),
              unselectedLabelStyle: AppTextStyle.textSm(),
              labelColor: color.primary,
              unselectedLabelColor: color.onSurfaceVariant,
              indicatorColor: color.primary,
              indicatorWeight: 4,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: const [
                Tab(text: 'Sent'),
                Tab(text: 'Received'),
              ],
            ),
          ),

          const SizedBox(height: 4),

          /// TAB CONTENT
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                SentMeetingsTab(),
                ReceivedMeetingsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────────────────────────────────────
/// Calendar card — week-by-default, format toggle, dot markers per meeting day.
/// ─────────────────────────────────────────────────────────────────────────────
class _CalendarCard extends StatelessWidget {
  final DateTime selectedDate;
  final DateTime focusedDate;
  final CalendarFormat format;
  final Set<DateTime> markedDates;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(DateTime) onPageChanged;
  final void Function(CalendarFormat) onFormatChanged;

  const _CalendarCard({
    super.key,
    required this.selectedDate,
    required this.focusedDate,
    required this.format,
    required this.markedDates,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onFormatChanged,
  });

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Container(
        decoration: BoxDecoration(
          color: color.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.outline.withOpacity(0.15)),
        ),
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
        child: TableCalendar(
          firstDay: DateTime(2020),
          lastDay: DateTime(2050),
          focusedDay: focusedDate,
          selectedDayPredicate: (day) => isSameDay(day, selectedDate),
          calendarFormat: format,
          availableCalendarFormats: const {
            CalendarFormat.month: 'Month',
            CalendarFormat.week: 'Week',
          },
          startingDayOfWeek: StartingDayOfWeek.monday,
          rowHeight: 46,
          daysOfWeekHeight: 22,
          eventLoader: (day) =>
              markedDates.contains(_normalize(day)) ? const <int>[0] : const <int>[],
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonShowsNext: true,
            formatButtonDecoration: BoxDecoration(
              color: color.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(8),
            ),
            formatButtonTextStyle: AppTextStyle.textXs(
              color: color.primary,
              weight: FontWeight.w600,
            ),
            formatButtonPadding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            titleTextStyle: AppTextStyle.textMd(weight: FontWeight.w700),
            leftChevronIcon:
                Icon(Icons.chevron_left, color: color.onSurfaceVariant),
            rightChevronIcon:
                Icon(Icons.chevron_right, color: color.onSurfaceVariant),
            headerPadding: const EdgeInsets.symmetric(vertical: 4),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: AppTextStyle.textXs(
              color: color.onSurfaceVariant,
              weight: FontWeight.w600,
            ),
            weekendStyle: AppTextStyle.textXs(
              color: color.onSurfaceVariant,
              weight: FontWeight.w600,
            ),
          ),
          calendarStyle: CalendarStyle(
            outsideDaysVisible: false,
            cellMargin: const EdgeInsets.all(4),
            todayDecoration: BoxDecoration(
              color: color.primary.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            todayTextStyle: AppTextStyle.textSm(
              color: color.primary,
              weight: FontWeight.w700,
            ),
            selectedDecoration: BoxDecoration(
              color: color.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: AppTextStyle.textSm(
              color: color.onPrimary,
              weight: FontWeight.w700,
            ),
            defaultTextStyle: AppTextStyle.textSm(color: color.onSurface),
            weekendTextStyle: AppTextStyle.textSm(color: color.onSurface),
          ),
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return const SizedBox.shrink();
              final isSelected = isSameDay(day, selectedDate);
              return Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: 7,
                  height: 7,
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? color.onPrimary : color.primary,
                  ),
                ),
              );
            },
          ),
          onDaySelected: onDaySelected,
          onPageChanged: onPageChanged,
          onFormatChanged: onFormatChanged,
        ),
      ),
    );
  }
}
