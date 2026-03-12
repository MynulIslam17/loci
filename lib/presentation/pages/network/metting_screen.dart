import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/presentation/pages/network/widget/meeting_card.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/utils/status.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  // --- Dummy meeting data ---
  final List<Map<String, dynamic>> meetings = [
    {
      "status": ReferralStatus.confirm,
      "fromName": "John Doe",
      "fromCompany": "Google",
      "toName": "Sarah Smith",
      "toCompany": "Meta",
      "location": "Dhaka",
      "time": "10:30 AM",
      "message": "Looking forward to meeting.",
      "date": DateTime(2026, 2, 12),
    },
    {
      "status": ReferralStatus.pending,
      "fromName": "Alice Johnson",
      "fromCompany": "Amazon",
      "toName": "Bob Brown",
      "toCompany": "Tesla",
      "location": "New York",
      "time": "2:00 PM",
      "message": "Please review the agenda.",
      "date": DateTime(2026, 2, 13),
    },
    {
      "status": ReferralStatus.pending,
      "fromName": "Alice Johnson",
      "fromCompany": "Amazon",
      "toName": "Bob Brown",
      "toCompany": "Tesla",
      "location": "New York",
      "time": "2:00 PM",
      "message": "Please review the agenda.",
      "date": DateTime(2026, 2, 13),
    },
    {
      "status": ReferralStatus.rejected,
      "fromName": "David Lee",
      "fromCompany": "Microsoft",
      "toName": "Emma Watson",
      "toCompany": "Apple",
      "location": "San Francisco",
      "time": "11:00 AM",
      "message": "Rescheduling due to conflict.",
      "date": DateTime(2026, 2, 14),
    },
  ];

  // Selected and focused date initialized to today
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();

  // Map to track meetings per date
  late final Map<DateTime, List<Map<String, dynamic>>> _events;

  @override
  void initState() {
    super.initState();

    // Build _events map: group meetings by date (normalized to midnight)
    _events = {};
    for (var meeting in meetings) {
      final date = DateTime(
        meeting['date'].year,
        meeting['date'].month,
        meeting['date'].day,
      );
      if (_events[date] == null) {
        _events[date] = [meeting];
      } else {
        _events[date]!.add(meeting);
      }
    }

    // Initialize selected and focused date to today (normalized)
    _selectedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    _focusedDate = _selectedDate;
  }

  // Helper to normalize any DateTime to midnight
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  @override
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Calendar Section ---
            _buildTopCalendar(),

            // --- Content Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(colorScheme),
                  const SizedBox(height: 16),
                  _buildActionButton(context),
                  const SizedBox(height: 24),
                  _buildMeetingList(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Calendar ---
  Widget _buildTopCalendar() {
    return Container(
      color: context.colorScheme.surface,
      child: TableCalendar(
        firstDay: DateTime(1940),
        lastDay: DateTime(2050),
        focusedDay: _focusedDate,
        selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
        eventLoader: (day) {
          final date = _normalizeDate(day);
          return _events[date] ?? [];
        },
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.blueAccent,
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: context.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDate = _normalizeDate(selectedDay); // normalize on select
            _focusedDate = focusedDay;
          });
        },
      ),
    );
  }

  // --- Header showing selected date info ---
  Widget _buildHeader(ColorScheme colorScheme) {
    final meetingsForSelectedDay = _events[_selectedDate] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Meetings on ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
          style: AppTextStyle.textMd(
            color: colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${meetingsForSelectedDay.length} meetings scheduled",
          style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  // --- Action Button ---
  Widget _buildActionButton(BuildContext context) {
    return CustomButton(
      backgroundColor: context.colorScheme.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add, color: context.colorScheme.onPrimary, size: 20),
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

  // --- Meeting List for Selected Day ---
  Widget _buildMeetingList() {
    final meetingsForSelectedDay = _events[_selectedDate] ?? [];

    if (meetingsForSelectedDay.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: Text(
            "No meetings scheduled.",
            style: AppTextStyle.textSm(
              color: context.colorScheme.onSurfaceVariant,
              weight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meetingsForSelectedDay.length,
      itemBuilder: (context, index) {
        final meeting = meetingsForSelectedDay[index];
        return MeetingCard(
          status: meeting["status"],
          fromName: meeting["fromName"],
          fromCompany: meeting["fromCompany"],
          toName: meeting["toName"],
          toCompany: meeting["toCompany"],
          location: meeting["location"],
          time: meeting["time"],
          message: meeting["message"],
          date: DateParserHelper.toFriendlyDate(meeting["date"]),
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 15),
    );
  }
}
