import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/my_business/presentation/controllers/create_ad_controller.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/shared/widgets/custom_imagepicker.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class CreateAd extends StatefulWidget {
  const CreateAd({super.key});

  @override
  State<CreateAd> createState() => _CreateAdState();
}

class _CreateAdState extends State<CreateAd> {
  static const int _titleMin = 2;
  static const int _titleMax = 200;
  static const int _businessNameMax = 200;

  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<CreateAdController>();

  final _adBanner = Rxn<File>();
  final _imageError = RxnString();
  final _endDateError = RxnString();

  final _titleController = TextEditingController();
  final _businessController = TextEditingController();
  final _locationController = TextEditingController();
  final _startDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endDateController = TextEditingController();
  final _endTimeController = TextEditingController();

  final _startDate = Rxn<DateTime>();
  final _startTime = Rxn<TimeOfDay>();
  final _endDate = Rxn<DateTime>();
  final _endTime = Rxn<TimeOfDay>();

  /// True when the business name was supplied via Get.arguments (i.e. user
  /// opened this page from a specific business profile). In that case the
  /// field is locked so the ad can't be redirected to another business.
  final _businessLocked = false.obs;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && args['businessName'] is String) {
      _businessController.text = args['businessName'] as String;
      _businessLocked.value = (args['businessName'] as String).isNotEmpty;
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart
        ? (_startDate.value ?? DateTime.now())
        : (_endDate.value ?? _startDate.value ?? DateTime.now());
    final first = isStart
        ? DateTime.now()
        : (_startDate.value ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(first) ? first : initial,
      firstDate: first,
      lastDate: DateTime(2050),
    );

    if (picked == null) return;
    if (isStart) {
      _startDate.value = picked;
      _startDateController.text =
          "${picked.day}/${picked.month}/${picked.year}";
      // If end is now before start, clear it so user re-picks.
      if (_endDate.value != null && _endDate.value!.isBefore(picked)) {
        _endDate.value = null;
        _endDateController.clear();
      }
    } else {
      _endDate.value = picked;
      _endDateController.text = "${picked.day}/${picked.month}/${picked.year}";
      _endDateError.value = null;
    }
    _formKey.currentState?.validate();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = isStart
        ? (_startTime.value ?? TimeOfDay.now())
        : (_endTime.value ?? TimeOfDay.now());
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    if (isStart) {
      _startTime.value = picked;
      _startTimeController.text = picked.format(context);
    } else {
      _endTime.value = picked;
      _endTimeController.text = picked.format(context);
    }
    _formKey.currentState?.validate();
  }

  DateTime? _combine(DateTime? date, TimeOfDay? time) {
    if (date == null) return null;
    final t = time ?? const TimeOfDay(hour: 0, minute: 0);
    return DateTime(date.year, date.month, date.day, t.hour, t.minute);
  }

  Future<void> _onSubmit() async {
    final start = _combine(_startDate.value, _startTime.value);
    final end = _combine(_endDate.value, _endTime.value);

    String? endErr;
    if (end == null) {
      endErr = "End date is required";
    } else if (start != null && !end.isAfter(start)) {
      endErr = "End must be after start";
    } else if (end.isBefore(DateTime.now())) {
      endErr = "End date must be in the future";
    }

    _imageError.value = _adBanner.value == null
        ? "Please select an ad banner"
        : null;
    _endDateError.value = endErr;

    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk || _adBanner.value == null || endErr != null) return;

    final success = await _controller.submitAd(
      title: _titleController.text.trim(),
      businessName: _businessController.text.trim().isEmpty
          ? null
          : _businessController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      startDate: start,
      endDate: end!,
      image: _adBanner.value!,
    );

    if (!mounted) return;

    if (success) {
      Get.back(result: true);
      SnackbarService.success(
        _controller.successMessage.value ?? "Ad submitted for review",
      );
    } else {
      SnackbarService.error(
        _controller.errorMessage.value ?? "Failed to submit ad",
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _businessController.dispose();
    _locationController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Create Ads",
          style: AppTextStyle.textLg(weight: FontWeight.w600),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text(
                "Ads Detail",
                style: AppTextStyle.textXl(
                  weight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Fill the details to run the ads",
                style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              _buildFormCard(),
              const SizedBox(height: 30),
              Obx(() {
                final c = Get.find<CreateAdController>();
                return CustomButton(
                  isLoading: c.isLoading.value,
                  onPressed: c.isLoading.value ? null : _onSubmit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: AppTextStyle.textMd(
                          weight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward,
                        color: colorScheme.onPrimary,
                        size: 20,
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    final colorScheme = context.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //-- title (required, 2–200)
            CustomTextField(
              controller: _titleController,
              title: "Title",
              hintText: "e.g. Summer Sale - 30% Off All Items",
              maxLength: _titleMax,
              borderColor: colorScheme.outline,
              hintTextColor: colorScheme.onSurfaceVariant,
              textColor: colorScheme.onSurface,
              titleStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return "Title is required";
                if (v.length < _titleMin) {
                  return "Title must be at least $_titleMin characters";
                }
                if (v.length > _titleMax) {
                  return "Title must be at most $_titleMax characters";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            //-- business name (optional, 1–200 if entered)
            CustomTextField(
              controller: _businessController,
              readOnly: _businessLocked.value,
              fillColor: _businessLocked.value
                  ? colorScheme.surfaceContainerHighest
                  : null,
              title: "Business (optional)",
              hintText: "Enter business name",
              maxLength: _businessNameMax,
              borderColor: colorScheme.outline,
              hintTextColor: colorScheme.onSurfaceVariant,
              textColor: colorScheme.onSurface,
              titleStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              validator: (value) {
                final v = value?.trim() ?? '';
                if (v.isEmpty) return null;
                if (v.length > _businessNameMax) {
                  return "Business name must be at most $_businessNameMax characters";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            //-- location (optional)
            CustomTextField(
              controller: _locationController,
              title: "Location (optional)",
              hintText: "Enter location",
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: colorScheme.primary,
                size: 20,
              ),
              borderColor: colorScheme.outline,
              hintTextColor: colorScheme.onSurfaceVariant,
              textColor: colorScheme.onSurface,
              titleStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            //-- start date (optional)
            _buildDateTimeRow(
              label: "Start Date (Optional)",
              dateController: _startDateController,
              timeController: _startTimeController,
              onDateTap: () => _pickDate(isStart: true),
              onTimeTap: () => _pickTime(isStart: true),
              // No validators — optional.
            ),
            const SizedBox(height: 16),

            //-- end date (required, must be after start, must be future)
            _buildDateTimeRow(
              label: "End Date",
              dateController: _endDateController,
              timeController: _endTimeController,
              onDateTap: () => _pickDate(isStart: false),
              onTimeTap: () => _pickTime(isStart: false),
              dateValidator: (_) =>
                  _endDate.value == null ? "Pick an end date" : null,
              timeValidator: (_) =>
                  _endTime.value == null ? "Pick an end time" : null,
            ),
            Obx(() {
              if (_endDateError.value == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    _endDateError.value!,
                    style: TextStyle(color: colorScheme.error, fontSize: 12),
                  ),
                ],
              );
            }),

            //-- ads banner (required)
            const SizedBox(height: 16),
            Text(
              "Ads Banner",
              style: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            _buildImagePickerArea(),
            Obx(() {
              if (_imageError.value == null) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  Text(
                    _imageError.value!,
                    style: TextStyle(color: colorScheme.error, fontSize: 12),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildDateTimeRow({
    required String label,
    required TextEditingController dateController,
    required TextEditingController timeController,
    required VoidCallback onDateTap,
    required VoidCallback onTimeTap,
    FormFieldValidator<String>? dateValidator,
    FormFieldValidator<String>? timeValidator,
  }) {
    final colorScheme = context.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyle.textSm(
            weight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CustomTextField(
                onTap: onDateTap,
                controller: dateController,
                readOnly: true,
                hintText: "Select Date",
                fontSize: 11,
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
                hintTextColor: colorScheme.onSurfaceVariant,
                textColor: colorScheme.onSurface,
                validator: dateValidator,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(
                controller: timeController,
                onTap: onTimeTap,
                readOnly: true,
                hintText: "Select Time",
                fontSize: 11,
                suffixIcon: Icon(
                  Icons.access_time,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
                hintTextColor: colorScheme.onSurfaceVariant,
                textColor: colorScheme.onSurface,
                validator: timeValidator,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePickerArea() {
    final colorScheme = context.colorScheme;
    return Obx(
      () => CustomImagePicker(
        selectedImage: _adBanner.value,
        onImageSelected: (file) {
          _adBanner.value = file;
          _imageError.value = null;
        },
        height: 160,
        borderRadius: 12,
        backgroundColor: colorScheme.surfaceContainerHighest,
        borderColor: _imageError.value != null
            ? colorScheme.error
            : colorScheme.outline,
        placeholder: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 32,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              "Browse image",
              style: AppTextStyle.textMd(
                color: colorScheme.onSurfaceVariant,
                weight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
