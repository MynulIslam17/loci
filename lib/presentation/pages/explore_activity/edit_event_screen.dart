import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/models/event/event_model.dart';
import 'package:loci/presentation/controllers/explore_acitivity/business_event_details_controller.dart';
import 'package:loci/presentation/controllers/explore_acitivity/business_event_update_controller.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_imagepicker.dart';

import '../../../core/utils/date_parser.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../core/utils/time_parser.dart';
import '../../../data/models/explore_activity/event_update_request_model.dart';
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
  // Controllers
  final eventController = Get.find<BusinessEventDetailsController>();
  final eventUpdateController = Get.find<BusinessEventUpdateController>();
  late final String eventId;
  Map<String, dynamic>? _initialData;
  File? bannerImage;
  bool isPublic = false;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  // Text Controllers
  final TextEditingController titleTEController = TextEditingController();
  final TextEditingController detailsTEController = TextEditingController();
  final TextEditingController dateTEController = TextEditingController();
  final TextEditingController timeTEController = TextEditingController();
  final TextEditingController personTEController = TextEditingController();
  final TextEditingController locationTEController = TextEditingController();
  final TextEditingController mapUrlTEController = TextEditingController();

  final GlobalKey<FormState> _mainFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    var args = Get.arguments as Map<String, dynamic>?;
    eventId = args?["eventId"] ?? "";

    //  Add Listeners to all controllers to trigger _isChanged check
    [
      titleTEController,
      detailsTEController,
      dateTEController,
      timeTEController,
      personTEController,
      locationTEController,
      mapUrlTEController,
    ].forEach((controller) => controller.addListener(_onStateChange));

    // 2. Fetch and Populate
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await eventController.fetchEventDetails(eventId);
      _populateFields();
    });
  }

  void _onStateChange() => setState(() {});

  /// ===============================================================
  /// Populate Fields from API

  void _populateFields() {
    final details = eventController.eventDetails;
    final event = details?.eventModel;

    if (event == null) return;

    // 1. Parse Date and Time for Logical Objects (used by Pickers)
    final DateTime parsedDate = DateTime.parse(event.date).toLocal();
    selectedDate = parsedDate;

    // Using your custom parser from time_parser.dart
    selectedTime = parseTime(event.eventTime);

    // 2. Format friendly strings for the UI Comparison
    final String friendlyDate = DateParserHelper.toFriendlyDate(parsedDate);
    final String friendlyTime = event.eventTime;

    // 3. Store initial data to compare later in the _isChanged getter
    _initialData = {
      'title': event.title,
      'details': event.description,
      'date': friendlyDate,
      'time': friendlyTime,
      'location': event.location,
      'mapUrl': details?.mapUrl ?? "",
      'maxParticipants': event.maxAttendees.toString(),
      'isPublic': event.isPublic,
    };

    // 4. Fill the TextControllers with the correct keys
    titleTEController.text = _initialData!['title'];
    detailsTEController.text = _initialData!['details'];
    locationTEController.text = _initialData!['location'];
    mapUrlTEController.text = _initialData!['mapUrl'];
    personTEController.text = _initialData!['maxParticipants'];
    dateTEController.text = _initialData!['date'];
    timeTEController.text = _initialData!['time'];

    // 5. Set Toggle state
    isPublic = event.isPublic;

    setState(() {});
  }

  /// ===============================================================
  /// Change Detection Logic
  /// ===============================================================
  bool get _isChanged {
    if (_initialData == null) return false;

    return titleTEController.text != _initialData!['title'] ||
        detailsTEController.text != _initialData!['details'] ||
        locationTEController.text != _initialData!['location'] ||
        mapUrlTEController.text != _initialData!['mapUrl'] ||
        personTEController.text != _initialData!['maxParticipants'] ||
        dateTEController.text != _initialData!['date'] ||
        timeTEController.text != _initialData!['time']||
        isPublic != _initialData!['isPublic'] ||
        bannerImage != null;
  }


  void _updateHandler() async {
    FocusScope.of(context).unfocus();

    if (!(_mainFormKey.currentState?.validate() ?? false)) return;

    final event = eventController.eventDetails?.eventModel;
    final eventDetails = eventController.eventDetails;
    if (event == null) return;

    final request = EventUpdateRequest(
      eventId: eventId,
      title: titleTEController.text != event.title ? titleTEController.text : null,
      details: detailsTEController.text != event.description ? detailsTEController.text : null,
      location: locationTEController.text != event.location ? locationTEController.text : null,
      url: mapUrlTEController.text != eventDetails?.mapUrl ? mapUrlTEController.text : null,
      maxParticipants: personTEController.text != _initialData?['maxParticipants']
          ? int.tryParse(personTEController.text)
          : null,
      isPublic: isPublic != event.isPublic ? isPublic : null,

      eventTime: timeTEController.text != _initialData?['time']
          ? timeTEController.text
          : null,

      eventDate: dateTEController.text != _initialData?['date']
          ? selectedDate?.toUtc().toIso8601String()
          : null,

      banner: bannerImage,
    );

    final success = await eventUpdateController.updateEvent(request);

    if (success) {
      Get.back(result: true);
      SnackbarService.success("Event updated successfully");
    } else {
      SnackbarService.error(
        eventUpdateController.errorMessage ?? "Update failed",
      );
    }
  }


  @override
  void dispose() {
    titleTEController.dispose();
    detailsTEController.dispose();
    dateTEController.dispose();
    timeTEController.dispose();
    personTEController.dispose();
    locationTEController.dispose();
    mapUrlTEController.dispose();
    super.dispose();
  }

  /// ===============================================================
  /// Date Picker
  /// ===============================================================

  void showCalendar() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      firstDate: DateTime(1940),
      initialDate: selectedDate ?? DateTime.now(), // Uses populated date
      lastDate: DateTime(2049),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
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
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
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
      appBar: CustomAppbar(title: "Edit Event"),
      body: GetBuilder<BusinessEventDetailsController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          if (controller.eventDetails == null) {
            return Center(child: Text("No event fount"));
          }

          final details = controller.eventDetails;
          final event = details?.eventModel;

          return Form(
            key: _mainFormKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Event Banner Image
                  _buildBanner(colorScheme, event!),

                  const SizedBox(height: 18),

                  /// Event Header (Title + Edit Button)
                  _buildHeaderSection(colorScheme),

                  const SizedBox(height: 6),

                  /// Event Description
                  Text(
                    detailsTEController.text,
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
        },
      ),
    );
  }

  /// ===============================================================
  /// Banner Image
  /// ===============================================================

  Widget _buildBanner(ColorScheme colorScheme, EventModel event) {
    return CustomImagePicker(
      imageUrl: event.coverImage,
      height: 200,
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedImage: bannerImage,
      onImageSelected: (file) => setState(() => bannerImage = file),
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
            titleTEController.text,
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
          "Event Schedule and Seats : ",
          style: AppTextStyle.textSm(
            weight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _expandedInput(
              "Date",
              "Date",
              Icons.calendar_today_outlined,
              colorScheme,
              onTap: showCalendar,
              controller: dateTEController,
            ),
            const SizedBox(width: 10),
            _expandedInput(
              "Time",
              "Time",
              Icons.access_time,
              colorScheme,
              onTap: showTime,
              controller: timeTEController,
            ),
            const SizedBox(width: 10),
            _expandedInput(
              "200",
              "Person",
              Icons.people_outline,
              colorScheme,
              isNumber: true,
              controller: personTEController,
            ),
          ],
        ),
      ],
    );
  }

  /// Input Field
  Widget _expandedInput(
    String hint,
    String title,
    IconData icon,
    ColorScheme colorScheme, {
    VoidCallback? onTap,
    TextEditingController? controller,
    bool isNumber = false,
  }) {
    return Expanded(
      child: CustomTextField(
        title: title,
        controller: controller,
        onTap: onTap,
        hintText: hint,
        fontSize: 10,
        readOnly: onTap != null,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        textColor: colorScheme.onSurface,
        hintTextColor: colorScheme.onSurfaceVariant,
        suffixIcon: Icon(icon, size: 18, color: colorScheme.onSurfaceVariant),
        borderColor: colorScheme.outline,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "$title required";
          } else {
            return null;
          }
        },
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
          controller: locationTEController,
          hintText: "Enter location",
          prefixIcon: Icon(
            Icons.location_on_outlined,
            size: 18,
            color: colorScheme.primary,
          ),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Location required";
            }
            return null;
          },
        ),
        const SizedBox(height: 12),

        CustomTextField(
          title: "Map url",
          controller: mapUrlTEController,
          hintText: "Enter map url",
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Map url required";
            }
            return null;
          },
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
          child: GetBuilder<BusinessEventUpdateController>(builder: (controller){
            return CustomButton(
              isLoading: controller.isLoading,
              text: "Update",
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
              onPressed:_isChanged ? _updateHandler : null,
            );
          }),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Bottom Sheet (Edit Title & Description)
  /// ===============================================================

  void _showBottomSheet() {
    final colorScheme = context.colorScheme;

    final localTitleController = TextEditingController(text: titleTEController.text);
    final localDetailsController = TextEditingController(text: detailsTEController.text);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Form(
          key: formKey,
          child: Padding(
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
                  // ... (Handle bar and Header remain the same)

                  CustomTextField(
                    title: "Title",
                    controller: localTitleController,
                    // ... props
                    validator: (v) => (v == null || v.isEmpty) ? "Title required" : null,
                  ),

                  const SizedBox(height: 16),

                  CustomTextField(
                    title: "Description",
                    controller: localDetailsController,
                    maxLine: 4,
                    // ... props
                    validator: (v) => (v == null || v.isEmpty) ? "Description required" : null,
                  ),

                  const SizedBox(height: 24),

                  CustomButton(
                    width: double.infinity,
                    height: 50,
                    text: "Done",
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;


                      setState(() {
                        titleTEController.text = localTitleController.text.trim();
                        detailsTEController.text = localDetailsController.text.trim();
                      });

                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
