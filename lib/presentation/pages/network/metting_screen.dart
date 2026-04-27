import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/presentation/pages/network/widget/empty_meeting.dart';
import 'package:loci/presentation/pages/network/widget/meeting_card.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../../core/enums/network_type.dart';
import '../../../data/models/network/metting_item.dart';
import '../../controllers/network_dash/connection_controller.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final meetingController = Get.find<ConnectionController>();

  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      meetingController.fetchDashboard(NetworkType.meetings);
    });

    _selectedDate = _normalize(DateTime.now());
  }

  // ================= NORMALIZE =================
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  // ================= EVENTS MAP(group) =================
  Map<DateTime, List<MeetingModel>> get _events {
    final Map<DateTime, List<MeetingModel>> map = {};

    for (final m in meetingController.meetings) {
      final key = _normalize(m.dateTime);

      map.putIfAbsent(key, () => []);
      map[key]!.add(m);
    }

    return map;
  }

  List<MeetingModel> get _selectedMeetings => _events[_selectedDate] ?? [];

  // ================= UI =================
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Meetings",
          style: AppTextStyle.textXl(weight: FontWeight.w600),
        ),
      ),
      body: GetBuilder<ConnectionController>(
        builder: (controller) {
          return RefreshIndicator(
            onRefresh: () async {
              await meetingController.fetchDashboard(NetworkType.meetings);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildCalendar(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(colorScheme),
                      const SizedBox(height: 16),
                      _buildButton(context),
                      const SizedBox(height: 24),
                      _buildList(controller),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= CALENDAR =================
  Widget _buildCalendar() {
    return TableCalendar(
      firstDay: DateTime(1940),
      lastDay: DateTime(2050),
      focusedDay: _focusedDate,
      selectedDayPredicate: (day) => isSameDay(day, _selectedDate),

      eventLoader: (day) {
        return _events[_normalize(day)] ?? [];
      },

      onDaySelected: (selected, focused) {
        setState(() {
          _selectedDate = _normalize(selected);
          _focusedDate = focused;
        });
      },

      calendarStyle: CalendarStyle(
        todayDecoration: const BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
        ),
        markerDecoration: BoxDecoration(
          color: context.colorScheme.primary,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateParserHelper.toCalendarHeader(_selectedDate),
          style: AppTextStyle.textMd(weight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          "${_selectedMeetings.length} meetings",
          style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  // ================= BUTTON =================
  Widget _buildButton(BuildContext context) {
    return CustomButton(
      backgroundColor: context.colorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: context.colorScheme.onPrimary),
          const SizedBox(width: 8),
          Text(
            "Schedule New",
            style: AppTextStyle.textMd(
              weight: FontWeight.w600,
              color: context.colorScheme.onPrimary,
            ),
          ),
        ],
      ),
      onPressed: () {
        Get.toNamed(AppRoutes.scheduleMeeting);
      },
    );
  }

  // ================= LIST =================
  Widget _buildList(ConnectionController controller) {
    if (controller.isLoading && controller.meetings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final meetings = _selectedMeetings;

    if (meetings.isEmpty) {
      return const EmptyMeetingWidget();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meetings.length,
      itemBuilder: (context, index) {
        final m = meetings[index];

        return MeetingCard(
          status: m.status,
          fromName: m.fromName,
          fromCompany: m.fromCompany,
          toName: m.toName,
          toCompany: m.toCompany,
          location: m.location,
          time: m.formatedTime,
          message: m.message,
          date: DateParserHelper.eventDateTime(m.dateTime),
        );
      },
      separatorBuilder: (_, __) => const SizedBox(height: 12),
    );
  }
}
