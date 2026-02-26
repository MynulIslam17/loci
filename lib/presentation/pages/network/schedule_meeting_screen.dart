import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  const ScheduleMeetingScreen({super.key});

  @override
  State<ScheduleMeetingScreen> createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  // ----controller for textFiled
  final dateTEController = TextEditingController();
  final timeTEController = TextEditingController();

  String? selectedDate;
  String? selectTime;



  // --- method for showing calendar
  Future<void> showCalendar() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1940),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate.toString();
        dateTEController.text = DateParserHelper.toFriendlyDate(pickedDate);
      });
    }
  }

  // --- method for showing TimPicker
  Future<void> showTime() async {

    TimeOfDay ? pickedTime=await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now());

    if(pickedTime!=null){
      setState(() {
        selectTime=pickedTime.toString();
        timeTEController.text=pickedTime.format(context);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text(
          "Schedule a meeting",
          style: AppTextStyle.textMd(weight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header Section
              _buildHeader(),
              const SizedBox(height: 20),

              // 2. Main Form Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //---- Business Owner Section
                    _buildLabel("Business owner"),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Enter owner's name",
                      borderColor: colorScheme.outline,
                      hintTextColor: colorScheme.onSurfaceVariant,
                      textColor: colorScheme.onSurface,
                    ),
                    const SizedBox(height: 12),
                    CustomTextField(
                      hintText: "Enter owner's email",
                      borderColor: colorScheme.outline,
                      hintTextColor: colorScheme.onSurfaceVariant,
                      textColor: colorScheme.onSurface,
                    ),

                    const SizedBox(height: 20),

                    //---- Meeting Schedule Section (Row with Date and Time)
                    _buildLabel("Meeting Schedule"),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CustomTextField(
                            onTap: showCalendar,
                            controller: dateTEController,
                            readOnly: true,
                            hintText: "Mon, Jan 19",
                            fontSize: 11,
                            suffixIcon: Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            borderColor: colorScheme.outline,
                            hintTextColor: colorScheme.onSurfaceVariant,
                            textColor: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: CustomTextField(
                            controller: timeTEController,
                            onTap: showTime,
                            readOnly: true,
                            hintText: "24:50 PM",
                            fontSize: 11,
                            suffixIcon: Icon(
                              Icons.access_time,
                              size: 14,
                              color: colorScheme.onSurfaceVariant,
                            ),

                            borderColor: colorScheme.outline,
                            hintTextColor: colorScheme.onSurfaceVariant,
                            textColor: colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Location Section
                    _buildLabel("Location"),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Downtown District",
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      borderColor: colorScheme.outline,
                      hintTextColor: colorScheme.onSurfaceVariant,
                      textColor: colorScheme.onSurface,
                    ),

                    const SizedBox(height: 20),

                    // Message Section
                    _buildLabel("Message", isOptional: true),
                    const SizedBox(height: 8),
                    CustomTextField(
                      hintText: "Let's do meeting about our future plan...",
                      maxLine: 4,
                      borderColor: colorScheme.outline,
                      hintTextColor: colorScheme.onSurfaceVariant,
                      textColor: colorScheme.onSurface,
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Limit: 200 char",
                        style: AppTextStyle.textXs(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 3. Bottom Action Button
              CustomButton(
                backgroundColor: colorScheme.primary,
                onPressed: () {},
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Schedule Meeting",
                      style: AppTextStyle.textMd(
                        color: colorScheme.onPrimary,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.send_outlined,
                      color: colorScheme.onPrimary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //--- Helper to build the top titles
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Meeting", style: AppTextStyle.textXl(weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          "Schedule a meeting with business owner",
          style: AppTextStyle.textSm(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  //-- Helper to build consistent labels (with optional support)
  Widget _buildLabel(String text, {bool isOptional = false}) {
    return Row(
      children: [
        Text(
          text,
          style: AppTextStyle.textSm(
            weight: FontWeight.w600,
            color: context.colorScheme.onSurface,
          ),
        ),
        if (isOptional)
          Text(
            " (optional)",
            style: AppTextStyle.textSm(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}
