import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/network_type.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/features/network/presentation/controllers/connection_controller.dart';
import 'package:loci/features/network/presentation/controllers/schedule_meeting_controller.dart';
import 'package:loci/features/network/presentation/controllers/sent_meetings_controller.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  const ScheduleMeetingScreen({super.key});

  @override
  State<ScheduleMeetingScreen> createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ScheduleMeetingController _controller;

  final _ownerNameController = TextEditingController();
  final _ownerEmailController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _messageController = TextEditingController();

  final Rxn<DateTime> _selectedDate = Rxn<DateTime>();
  final Rxn<TimeOfDay> _selectedTime = Rxn<TimeOfDay>();

  static const int _messageMaxLength = 200;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ScheduleMeetingController>();
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerEmailController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  // --- Pickers ---

  Future<void> _showCalendar() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      _selectedDate.value = picked;
      _dateController.text = DateParserHelper.toFriendlyDate(picked);
    }
  }

  Future<void> _showTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime.value ?? TimeOfDay.now(),
    );

    if (picked != null) {
      _selectedTime.value = picked;
      _timeController.text = picked.format(context);
    }
  }

  // --- Custom validators ---

  String? _validateDate(String? value) {
    if (_selectedDate.value == null) return "Please select a date";
    return null;
  }

  String? _validateTime(String? value) {
    if (_selectedTime.value == null) return "Please select a time";
    return null;
  }

  // --- Submit ---

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final meetingDate = DateParserHelper.toApiDate(_selectedDate.value);

    final meetingTime =
        "${_selectedTime.value!.hour.toString().padLeft(2, '0')}:"
        "${_selectedTime.value!.minute.toString().padLeft(2, '0')}";

    final success = await _controller.scheduleMeeting(
      recipientName: _ownerNameController.text.trim(),
      recipientEmail: _ownerEmailController.text.trim(),
      meetingDate: meetingDate,
      meetingTime: meetingTime,
      location: _locationController.text.trim(),
      message: _messageController.text.trim(),
    );

    if (success) {
      Get.find<ConnectionController>().refreshDashboard(NetworkType.meetings);
      if (Get.isRegistered<SentMeetingsController>()) {
        final sentCtrl = Get.find<SentMeetingsController>();
        sentCtrl.fetchSentMeetings();
        sentCtrl.fetchMarkerDates();
      }
      Get.back();
      SnackbarService.success("Meeting scheduled successfully!");
    } else {
      SnackbarService.error(
        _controller.errorMessage ?? "Failed to schedule meeting",
      );
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
          "Schedule Meeting",
          style: AppTextStyle.textLg(weight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),

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
                      // --- Business Owner ---
                      _buildLabel("Business owner"),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _ownerNameController,
                        hintText: "Enter owner's name",
                        validator: validateFirstName,
                        borderColor: colorScheme.outline,
                        hintTextColor: colorScheme.onSurfaceVariant,
                        textColor: colorScheme.onSurface,
                      ),
                      const SizedBox(height: 12),
                      CustomTextField(
                        controller: _ownerEmailController,
                        hintText: "Enter owner's email",
                        keyboardType: TextInputType.emailAddress,
                        validator: validateEmail,
                        borderColor: colorScheme.outline,
                        hintTextColor: colorScheme.onSurfaceVariant,
                        textColor: colorScheme.onSurface,
                      ),
                      const SizedBox(height: 20),

                      // --- Meeting Schedule ---
                      _buildLabel("Meeting Schedule"),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CustomTextField(
                              onTap: _showCalendar,
                              controller: _dateController,
                              readOnly: true,
                              hintText: "Pick date",
                              fontSize: 12,
                              validator: _validateDate,
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
                              controller: _timeController,
                              onTap: _showTime,
                              readOnly: true,
                              hintText: "Pick time",
                              fontSize: 12,
                              validator: _validateTime,
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

                      // --- Location ---
                      _buildLabel("Location"),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _locationController,
                        hintText: "Downtown District",
                        validator: (v) =>
                            validateRequired(v, fieldName: "Location"),
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

                      // --- Message ---
                      _buildLabel("Message", isOptional: true),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _messageController,
                        hintText: "Let's do meeting about our future plan...",
                        maxLine: 4,
                        validator: (v) => validateMaxLength(
                          v,
                          _messageMaxLength,
                          fieldName: "Message",
                        ),
                        borderColor: colorScheme.outline,
                        hintTextColor: colorScheme.onSurfaceVariant,
                        textColor: colorScheme.onSurface,
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "Limit: $_messageMaxLength char",
                          style: AppTextStyle.textXs(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                Obx(() {
                  final ctrl = Get.find<ScheduleMeetingController>();
                  return CustomButton(
                    backgroundColor: colorScheme.primary,
                    onPressed: ctrl.isLoading ? null : _onSubmit,
                    child: ctrl.isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Row(
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
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
