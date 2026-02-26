import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import '../../../core/utils/status.dart';
import '../../widgets/referral_card.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Meeting",
          style: AppTextStyle.textXl(weight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Calendar Section (No Horizontal Padding)
            _buildTopCalendar(),

            // 2. Content Section (With Padding)
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
                  const SizedBox(height: 20), // Bottom breathing room
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Widget Components ---

  Widget _buildTopCalendar() {
    return Container(
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
      ),
      height: 270,
      width: double.infinity,
      child: CalendarDatePicker(
        initialDate: _selectedDate,
        firstDate: DateTime(1940),
        lastDate: DateTime(2050),
        onDateChanged: (DateTime newDate) {
          setState(() {
            _selectedDate = newDate;
          });
        },
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Upcoming Meeting",
          style: AppTextStyle.textXl(
            color: colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "5 meetings within next week",
          style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

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
      onPressed: () {},
    );
  }

  Widget _buildMeetingList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const ReferralCard(
          status: ReferralStatus.pending,
          fromName: "Sarah Johnson",
          fromCompany: "TechCorp",
          toName: "Michael Chen",
          toCompany: "Innovate Labs",
          message: "Michael would be a great fit for your enterprise sales team!",
          date: "Jan 12, 2026",
        );
      },
      separatorBuilder: (context, index) => const SizedBox(height: 15),
    );
  }
}