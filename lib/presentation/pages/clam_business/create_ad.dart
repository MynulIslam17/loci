import 'dart:io';
import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
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
  File? _adBanner;

  // Controllers for TextField data handling
  final _businessController = TextEditingController();
  final _locationController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();

  // --- method for showing calendar
  Future<void> _showCalendar() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2050),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  // --- method for showing TimePicker
  Future<void> _showTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _timeController.text = pickedTime.format(context);
      });
    }
  }

  @override
  void dispose() {
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
      body: SingleChildScrollView(
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
            CustomButton(
              onPressed: () {
                // Logic for ad creation
              },
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
            const SizedBox(height: 20),
          ],
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
            //--business Name
            CustomTextField(
              controller: _businessController,
              title: "Business",
              hintText: "Enter owner's name",
              // Solid border color
              borderColor: colorScheme.outline,
              hintTextColor: colorScheme.onSurfaceVariant,
              textColor: colorScheme.onSurface,
              titleStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
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
              // Solid border color
              borderColor: colorScheme.outline,
              hintTextColor: colorScheme.onSurfaceVariant,
              textColor: colorScheme.onSurface,
              titleStyle: AppTextStyle.textSm(
                weight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
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
                    // Solid border color
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
                    hintText: "Select Time",
                    fontSize: 11,
                    suffixIcon: Icon(
                      Icons.access_time,
                      size: 14,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    // Solid border color
                    borderColor: colorScheme.outline,
                    hintTextColor: colorScheme.onSurfaceVariant,
                    textColor: colorScheme.onSurface,
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
          ],
        ),
      ),
    );
  }

  Widget _buildImagePickerArea() {
    final colorScheme = context.colorScheme;
    return CustomImagePicker(
      selectedImage: _adBanner,
      onImageSelected: (file) => setState(() => _adBanner = file),
      height: 160,
      borderRadius: 12,
      backgroundColor: colorScheme.surfaceContainerHighest,
      // Solid border color
      borderColor: colorScheme.outline,
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
