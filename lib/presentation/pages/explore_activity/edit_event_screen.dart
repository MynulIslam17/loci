import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_imagepicker.dart';

import '../../../core/utils/date_parser.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/common/company_info_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

/// ===============================================================
/// Edit Event Screen
/// ===============================================================
class EditEventScreen extends StatefulWidget {
  const EditEventScreen({super.key});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {

  /// ===============================================================
  /// Controllers
  /// ===============================================================

  late String title;

  final TextEditingController titleController = TextEditingController(
    text: "Spring Pub Crawl Festival",
  );

  final TextEditingController detailsController = TextEditingController(
    text:
    "Join us for the biggest pub crawl of the season! Visit 8 amazing bars...",
  );

  final TextEditingController dateTEController = TextEditingController();
  final TextEditingController timeTEController = TextEditingController();
  final TextEditingController personController = TextEditingController();

  final TextEditingController locationController = TextEditingController(
    text: "Downtown District",
  );

  final TextEditingController mapUrlController = TextEditingController(
    text: "http://",
  );

  bool isPublic = false;

  /// ===============================================================
  /// Lifecycle
  /// ===============================================================

  @override
  void initState() {
    super.initState();

    var args = Get.arguments;
    if (args != null && args is Map && args["title"] != null) {
      title = args["title"];
    } else {
      title = "Edit Event";
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    detailsController.dispose();
    dateTEController.dispose();
    timeTEController.dispose();
    personController.dispose();
    locationController.dispose();
    mapUrlController.dispose();
    super.dispose();
  }

  /// ===============================================================
  /// Date Picker
  /// ===============================================================

  void showCalendar() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      initialDate: DateTime.now(),
      lastDate: DateTime(2049),
    );

    if (pickedDate != null) {
      setState(() {
        dateTEController.text = DateParserHelper.toFriendlyDate(pickedDate);
      });
    }
  }

  /// ===============================================================
  /// Time Picker
  /// ===============================================================

  void showTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        timeTEController.text = pickedTime.format(context);
      });
    }
  }

  /// ===============================================================
  /// UI
  /// ===============================================================

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: title),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// Event Banner Image
            _buildBanner(colorScheme),

            const SizedBox(height: 18),

            /// Event Header (Title + Edit Button)
            _buildHeaderSection(colorScheme),

            const SizedBox(height: 6),

            /// Event Description
            Text(
              detailsController.text,
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
            ),

            const SizedBox(height: 22),

            /// Event Schedule
            _buildScheduleSection(colorScheme),

            const SizedBox(height: 20),

            /// Location Section
            _buildLocationSection(colorScheme),

            const SizedBox(height: 24),

            /// Organizer Toggle
            _buildOrganizerToggle(colorScheme),

            const SizedBox(height: 12),

            /// Company Info
            CompanyInfoCard(
              title: "Marland Clutch",
              description: "Lorem Ipsum is simply dummy text...",
              imagePath: Assets.images.companyLogo.path,
            ),

            const SizedBox(height: 28),

            /// Bottom Action Buttons
            _buildBottomButtons(colorScheme),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Banner Image
  /// ===============================================================

  Widget _buildBanner(ColorScheme colorScheme) {
    return CustomImagePicker(
      height: 200,
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedImage: null,
      onImageSelected: (file) {},
      placeholder: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              color: colorScheme.onSurface,
              size: 30,
            ),
            const SizedBox(height: 6),
            Text(
              "Browse image",
              style: AppTextStyle.textMd(
                color: colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// Event Title + Edit Button
  /// ===============================================================

  Widget _buildHeaderSection(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titleController.text,
            style: AppTextStyle.textMd(
              weight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            _showBottomSheet();
          },
          icon: Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Schedule Section
  /// ===============================================================

  Widget _buildScheduleSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Event Schedule and Seats",
          style: AppTextStyle.textSm(
            weight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _expandedInput(
              "Date",
              Icons.calendar_today_outlined,
              colorScheme,
              onTap: showCalendar,
              controller: dateTEController,
            ),
            const SizedBox(width: 10),
            _expandedInput(
              "Time",
              Icons.access_time,
              colorScheme,
              onTap: showTime,
              controller: timeTEController,
            ),
            const SizedBox(width: 10),
            _expandedInput(
              "200",
              Icons.people_outline,
              colorScheme,
              isNumber: true,
              controller: personController,
            ),
          ],
        ),
      ],
    );
  }

  /// Input Field
  Widget _expandedInput(
      String hint,
      IconData icon,
      ColorScheme colorScheme, {
        VoidCallback? onTap,
        TextEditingController? controller,
        bool isNumber = false,
      }) {
    return Expanded(
      child: CustomTextField(
        controller: controller,
        onTap: onTap,
        hintText: hint,
        readOnly: onTap != null,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textColor: colorScheme.onSurface,
        hintTextColor: colorScheme.onSurfaceVariant,
        suffixIcon: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        borderColor: colorScheme.outline,
      ),
    );
  }

  /// ===============================================================
  /// Location Section
  /// ===============================================================

  Widget _buildLocationSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Location",
          style: AppTextStyle.textSm(
            weight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: locationController,
          hintText: "Enter location",
          prefixIcon: Icon(
            Icons.location_on_outlined,
            size: 18,
            color: colorScheme.primary,
          ),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          margin: EdgeInsets.zero,
          color: colorScheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(Assets.images.location.path),
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  controller: mapUrlController,
                  hintText: "Enter map url",
                  borderColor: colorScheme.outline,
                  textColor: colorScheme.onSurface,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Organizer Toggle
  /// ===============================================================

  Widget _buildOrganizerToggle(ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          "Organizer",
          style: AppTextStyle.textMd(
            weight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          isPublic ? "Public" : "Private",
          style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
        ),
        Switch(
          value: isPublic,
          activeColor: colorScheme.primary,
          onChanged: (v) => setState(() => isPublic = v),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Bottom Buttons
  /// ===============================================================

  Widget _buildBottomButtons(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: "Cancel",
            backgroundColor: Colors.transparent,
            side: BorderSide(color: colorScheme.outline),
            textColor: colorScheme.onSurface,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: "Update",
            backgroundColor: colorScheme.primary,
            textColor: colorScheme.onPrimary,
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Bottom Sheet (Edit Title & Description)
  /// ===============================================================

  void _showBottomSheet() {
    final colorScheme = context.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add Task",
                      style: AppTextStyle.textLg(
                        weight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.cancel, color: colorScheme.onSurface),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// Title Field
                CustomTextField(
                  controller: titleController,
                  hintText: "Title",
                  borderColor: colorScheme.outline,
                  fontSize: 14,
                  textColor: colorScheme.onSurface,
                  hintTextColor: colorScheme.onSurfaceVariant,
                ),

                const SizedBox(height: 16),

                /// Description Field
                CustomTextField(
                  controller: detailsController,
                  hintText: "Description",
                  borderColor: colorScheme.outline,
                  fontSize: 14,
                  textColor: colorScheme.onSurface,
                  hintTextColor: colorScheme.onSurfaceVariant,
                  maxLine: 4,
                ),

                const SizedBox(height: 24),

                /// Done Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      width: 120,
                      height: 50,
                      text: "Done",
                      onPressed: () {

                        final title = titleController.text.trim();
                        final description = detailsController.text.trim();

                        if (title.isNotEmpty && description.isNotEmpty) {
                          setState(() {
                            titleController.text = title;
                            detailsController.text = description;
                          });

                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}