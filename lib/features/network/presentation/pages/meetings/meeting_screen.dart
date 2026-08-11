import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/network/presentation/controllers/meeting_screen_controller.dart';
import 'package:loci/features/network/presentation/widgets/meetings/received_meetings_tab.dart';
import 'package:loci/features/network/presentation/widgets/meetings/sent_meetings_tab.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/sticky_tab_bar.dart';
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
  final _calendarController = Get.find<MeetingScreenController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final initialTab = (args is Map && args['initialTab'] == 'received')
        ? 1
        : 0;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverToBoxAdapter(child: _buildHeader(color)),
          stickyTabBarSliver(
            backgroundColor: color.surface,
            tabBar: appStickyTabBar(
              controller: _tabController,
              colorScheme: color,
              labels: const ['Sent', 'Received'],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: const [SentMeetingsTab(), ReceivedMeetingsTab()],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme color) {
    return Obx(() {
      final format = _calendarController.calendarFormat;
      _calendarController.markerRefresh;
      return Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CalendarViewToggle(
              isWeekView: format == CalendarFormat.week,
              onWeekTap: _calendarController.collapseToWeekView,
              onMonthTap: _calendarController.expandToMonthView,
            ),
            const SizedBox(height: 8),
            _CalendarCard(
              key: ValueKey('cal_${_calendarController.markedDates.length}'),
              selectedDate: _calendarController.selectedDate,
              focusedDate: _calendarController.focusedDate,
              format: format,
              markedDates: _calendarController.markedDates,
              onDaySelected: _calendarController.onDaySelected,
              onPageChanged: _calendarController.onPageChanged,
              onFormatChanged: _calendarController.onFormatChanged,
            ),
            const SizedBox(height: 12),
            Text(
              'Meetings',
              style: AppTextStyle.textXl(weight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Schedule and manage your meetings',
              style: AppTextStyle.textSm(color: color.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            CustomButton(
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
            const SizedBox(height: 12),
          ],
        ),
      );
    });
  }
}

/// Toggle between compact week view and full month view.
class _CalendarViewToggle extends StatelessWidget {
  const _CalendarViewToggle({
    required this.isWeekView,
    required this.onWeekTap,
    required this.onMonthTap,
  });

  final bool isWeekView;
  final VoidCallback onWeekTap;
  final VoidCallback onMonthTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleOption(
              label: 'Week',
              icon: Icons.view_week_outlined,
              selected: isWeekView,
              onTap: onWeekTap,
            ),
          ),
          Expanded(
            child: _ToggleOption(
              label: 'Month',
              icon: Icons.calendar_month_outlined,
              selected: !isWeekView,
              onTap: onMonthTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Material(
      color: selected ? color.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? color.onPrimary : color.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyle.textSm(
                  color: selected ? color.onPrimary : color.onSurfaceVariant,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
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

  final DateTime selectedDate;
  final DateTime focusedDate;
  final CalendarFormat format;
  final Set<DateTime> markedDates;
  final void Function(DateTime, DateTime) onDaySelected;
  final void Function(DateTime) onPageChanged;
  final void Function(CalendarFormat) onFormatChanged;

  static DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.4)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: TableCalendar(
        firstDay: DateTime(2020),
        lastDay: DateTime(2050),
        focusedDay: focusedDate,
        selectedDayPredicate: (day) => isSameDay(day, selectedDate),
        calendarFormat: format,
        availableCalendarFormats: const {
          CalendarFormat.week: 'Week',
          CalendarFormat.month: 'Month',
        },
        startingDayOfWeek: StartingDayOfWeek.monday,
        rowHeight: 46,
        daysOfWeekHeight: 22,
        eventLoader: (day) => markedDates.contains(_normalize(day))
            ? const <int>[0]
            : const <int>[],
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: AppTextStyle.textMd(weight: FontWeight.w700),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: color.onSurfaceVariant,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: color.onSurfaceVariant,
          ),
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
            color: color.primary.withValues(alpha: 0.12),
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
    );
  }
}
