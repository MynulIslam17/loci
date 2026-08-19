import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/features/network/presentation/controllers/schedule_meeting_controller.dart';
import 'package:loci/shared/widgets/adaptive_pickers.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/persistent_action_bar.dart';

class ScheduleMeetingScreen extends StatefulWidget {
  const ScheduleMeetingScreen({super.key});

  @override
  State<ScheduleMeetingScreen> createState() => _ScheduleMeetingScreenState();
}

class _ScheduleMeetingScreenState extends State<ScheduleMeetingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final ScheduleMeetingController _controller;

  final _recipientNameController = TextEditingController();
  final _recipientEmailController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _messageController = TextEditingController();

  static const int _messageMaxLength = 200;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<ScheduleMeetingController>();
  }

  @override
  void dispose() {
    _recipientNameController.dispose();
    _recipientEmailController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _locationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _showCalendar() async {
    final picked = await showAdaptiveDatePicker(
      context: context,
      initialDate: _controller.selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );

    if (picked != null) {
      _controller.setSelectedDate(picked);
      _dateController.text = DateParserHelper.toFriendlyDate(picked);
    }
  }

  Future<void> _showTime() async {
    final picked = await showAdaptiveTimePicker(
      context: context,
      initialTime: _controller.selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null) {
      _controller.setSelectedTime(picked);
      if (mounted) {
        _timeController.text = picked.format(context);
      }
    }
  }

  String? _validateDate(String? value) {
    if (_controller.selectedDate == null) return 'Please select a date';
    return null;
  }

  String? _validateTime(String? value) {
    if (_controller.selectedTime == null) return 'Please select a time';
    return null;
  }

  String? _optionalValue(TextEditingController controller) {
    final value = controller.text.trim();
    return value.isEmpty ? null : value;
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    final meetingDate = DateParserHelper.toApiDate(_controller.selectedDate);
    final selectedTime = _controller.selectedTime!;
    final meetingTime =
        '${selectedTime.hour.toString().padLeft(2, '0')}:'
        '${selectedTime.minute.toString().padLeft(2, '0')}';

    final success = await _controller.scheduleMeeting(
      recipientName: _recipientNameController.text.trim(),
      recipientEmail: _recipientEmailController.text.trim(),
      meetingDate: meetingDate,
      meetingTime: meetingTime,
      location: _locationController.text.trim(),
      message: _optionalValue(_messageController),
    );

    if (!mounted) return;

    if (success) {
      await _controller.onScheduleSuccess();
      Get.back();
      SnackbarService.success('Meeting scheduled successfully');
    } else {
      SnackbarService.error(
        _controller.errorMessage ?? 'Failed to schedule meeting',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: 'Schedule Meeting'),
      bottomNavigationBar: PersistentActionBar(
        child: Obx(
          () => SizedBox(
            width: double.infinity,
            height: 48,
            child: CustomButton(
              backgroundColor: colorScheme.primary,
              onPressed: _controller.isLoading ? null : _onSubmit,
              child: _controller.isLoading
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
                          'Schedule Meeting',
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
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('Recipient details'),
                    const SizedBox(height: 12),
                    _buildField(
                      label: 'Full name',
                      hint: "Enter recipient's full name",
                      controller: _recipientNameController,
                      validator: validateFullName,
                      isNameField: true,
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      label: 'Email',
                      hint: "Enter recipient's email",
                      controller: _recipientEmailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 20),
                    _buildSectionLabel('Meeting details'),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildField(
                            label: 'Date',
                            hint: 'Pick date',
                            controller: _dateController,
                            readOnly: true,
                            onTap: _showCalendar,
                            validator: _validateDate,
                            suffixIcon: Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildField(
                            label: 'Time',
                            hint: 'Pick time',
                            controller: _timeController,
                            readOnly: true,
                            onTap: _showTime,
                            validator: _validateTime,
                            suffixIcon: Icon(
                              Icons.access_time,
                              size: 18,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildField(
                      label: 'Location',
                      hint: 'Enter meeting location',
                      controller: _locationController,
                      validator: (v) =>
                          validateRequired(v, fieldName: 'Location'),
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildField(
                      label: 'Message',
                      isRequired: false,
                      hint: "Let's meet to discuss our plans...",
                      controller: _messageController,
                      maxLines: 4,
                      maxLength: _messageMaxLength,
                      validator: (v) => validateMaxLength(
                        v,
                        _messageMaxLength,
                        fieldName: 'Message',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Meeting', style: AppTextStyle.textXl(weight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          'Schedule a meeting with someone in your network',
          style: AppTextStyle.textSm(
            color: context.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            text: 'Fields marked ',
            style: AppTextStyle.textXs(
              color: context.colorScheme.onSurfaceVariant,
            ),
            children: [
              TextSpan(
                text: '*',
                style: AppTextStyle.textXs(
                  color: context.colorScheme.error,
                  weight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: ' are required'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label, {bool optional = false}) {
    final colorScheme = context.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                text: label,
                style: AppTextStyle.textMd(
                  color: colorScheme.primary,
                  weight: FontWeight.w700,
                ),
                children: [
                  if (optional)
                    TextSpan(
                      text: ' (optional)',
                      style: AppTextStyle.textSm(
                        color: colorScheme.onSurfaceVariant,
                        weight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isRequired = true,
    int maxLines = 1,
    int? maxLength,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    VoidCallback? onTap,
    bool readOnly = false,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isNameField = false,
  }) {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired),
        const SizedBox(height: 6),
        CustomTextField(
          controller: controller,
          hintText: hint,
          maxLine: maxLines,
          maxLength: maxLength,
          keyboardType: isNameField ? TextInputType.name : keyboardType,
          textCapitalization:
              isNameField ? TextCapitalization.words : TextCapitalization.none,
          inputFormatters: isNameField ? nameInputFormatters : null,
          validator: validator,
          onTap: onTap,
          readOnly: readOnly,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          hintTextColor: colorScheme.onSurfaceVariant,
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
        ),
      ],
    );
  }

  Widget _buildFieldLabel(String label, bool isRequired) {
    final colorScheme = context.colorScheme;

    return RichText(
      text: TextSpan(
        text: label,
        style: AppTextStyle.textSm(
          color: colorScheme.onSurfaceVariant,
          weight: FontWeight.w500,
        ),
        children: [
          if (isRequired)
            TextSpan(
              text: ' *',
              style: AppTextStyle.textSm(
                color: colorScheme.error,
                weight: FontWeight.w700,
              ),
            )
          else
            TextSpan(
              text: ' (optional)',
              style: AppTextStyle.textXs(
                color: colorScheme.onSurfaceVariant,
                weight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}
