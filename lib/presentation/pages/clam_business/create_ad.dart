import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/presentation/controllers/my_business/create_ad_controller.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import '../../../core/constants/app_text_style.dart';
import '../../widgets/custom_imagepicker.dart';
import '../../widgets/custom_text_field.dart';

class CreateAd extends StatefulWidget {
  const CreateAd({super.key});

  @override
  State<CreateAd> createState() => _CreateAdState();
}

class _CreateAdState extends State<CreateAd> {
  final _formKey = GlobalKey<FormState>();
  final _controller = Get.find<CreateAdController>();

  File? _adBanner;
  String? _imageError;

  // Controllers for TextField data handling
  final _titleController = TextEditingController();
  final _businessController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  // Real values backing the read-only date/time text fields.
  DateTime? _pickedDate;
  TimeOfDay? _pickedTime;

  /// True when the business name was supplied via Get.arguments (i.e. user
  /// opened this page from a specific business profile). In that case the
  /// field is locked so the ad can't be redirected to another business.
  bool _businessLocked = false;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map && args['businessName'] is String) {
      _businessController.text = args['businessName'] as String;
      _businessLocked = (args['businessName'] as String).isNotEmpty;
    }
  }

  // --- method for showing calendar
  Future<void> _showCalendar() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _pickedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null) {
      setState(() {
        _pickedDate = pickedDate;
        _dateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
      _formKey.currentState?.validate();
    }
  }

  // --- method for showing TimePicker
  Future<void> _showTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _pickedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) {
      setState(() {
        _pickedTime = pickedTime;
        _timeController.text = pickedTime.format(context);
      });
      _formKey.currentState?.validate();
    }
  }

  // --- submit
  Future<void> _onSubmit() async {
    // Image isn't a FormField, so validate it ourselves alongside the form.
    setState(() {
      _imageError = _adBanner == null ? "Please select an ad banner" : null;
    });
    final formOk = _formKey.currentState?.validate() ?? false;
    if (!formOk || _adBanner == null) return;

    final runtimeDate = DateTime(
      _pickedDate!.year,
      _pickedDate!.month,
      _pickedDate!.day,
      _pickedTime!.hour,
      _pickedTime!.minute,
    );

    final success = await _controller.submitAd(
      title: _titleController.text.trim(),
      businessName: _businessController.text.trim(),
      location: _locationController.text.trim(),
      runtimeDate: runtimeDate,
      image: _adBanner!,
    );

    if (!mounted) return;

    if (success) {
      SnackbarService.success("Ad submitted successfully");
      Get.back();
    } else {
      SnackbarService.error(_controller.errorMessage ?? "Failed to submit ad");
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _businessController.dispose();
    _locationController.dispose();
    _dateController.dispose();
    _timeController.dispose();
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
              GetBuilder<CreateAdController>(
                builder: (c) => CustomButton(
                  isLoading: c.isLoading,
                  onPressed: c.isLoading ? null : _onSubmit,
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
                ),
              ),
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
            //-- title
            CustomTextField(
              controller: _titleController,
              title: "Title",
              hintText: "e.g. Summer Sale - 30% Off All Items",
              borderColor: colorScheme.outline,
              hintTextColor: colorScheme.onSurfaceVariant,
              textColor: colorScheme.onSurface,
              titleStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? "Title is required" : null,
            ),
            const SizedBox(height: 16),

            //--business Name (pre-filled & locked when opened from a
            //   business profile, editable otherwise)
            CustomTextField(
              controller: _businessController,
              readOnly: _businessLocked,
              fillColor: _businessLocked
                  ? colorScheme.surfaceContainerHighest
                  : null,
              title: "Business",
              hintText: "Enter business name",
              borderColor: colorScheme.outline,
              hintTextColor: colorScheme.onSurfaceVariant,
              textColor: colorScheme.onSurface,
              titleStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? "Business name is required"
                  : null,
            ),
            const SizedBox(height: 16),

            //-- location
            CustomTextField(
              controller: _locationController,
              title: "Location",
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
              validator: (value) => value == null || value.trim().isEmpty
                  ? "Location is required"
                  : null,
            ),
            const SizedBox(height: 16),

            //--add duration
            Text(
              "Ads Runtime",
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
                    onTap: _showCalendar,
                    controller: _dateController,
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
                    validator: (_) =>
                        _pickedDate == null ? "Pick a date" : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: CustomTextField(
                    controller: _timeController,
                    onTap: _showTime,
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
                    validator: (_) =>
                        _pickedTime == null ? "Pick a time" : null,
                  ),
                ),
              ],
            ),

            //--add banner
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
            if (_imageError != null) ...[
              const SizedBox(height: 6),
              Text(
                _imageError!,
                style: TextStyle(color: colorScheme.error, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerArea() {
    final colorScheme = context.colorScheme;
    return CustomImagePicker(
      selectedImage: _adBanner,
      onImageSelected: (file) => setState(() {
        _adBanner = file;
        _imageError = null;
      }),
      height: 160,
      borderRadius: 12,
      backgroundColor: colorScheme.surfaceContainerHighest,
      borderColor: _imageError != null ? colorScheme.error : colorScheme.outline,
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
    );
  }
}
