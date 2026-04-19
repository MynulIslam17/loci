import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/routeType.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/data/models/routes/routes_model.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_imagepicker.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';

import '../../../core/utils/time_parser.dart';
import '../../../gen/assets.gen.dart';
import '../../controllers/explore_acitivity/business_route_details_controller.dart';
import '../../widgets/common/company_info_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';


class EditRoutesScreen extends StatefulWidget {
  const EditRoutesScreen({super.key});

  @override
  State<EditRoutesScreen> createState() => _EditRoutesScreenState();
}

class _EditRoutesScreenState extends State<EditRoutesScreen> {
  /// ===============================================================
  /// Controllers & State
  /// ===============================================================
  late String appBarTitle;
  late String routeId;

  RouteType? selectedDifficulty;
  bool isPublic = true;
  File? bannerImage;
  String? bannerUrl;

  final GlobalKey<FormState> _mainFormKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController timeTEController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController mapUrlController = TextEditingController();

  late final BusinessRouteDetailsController _routeController;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    appBarTitle = (args != null && args is Map)
        ? args["title"] ?? "Edit Route"
        : "Edit Route";
    routeId = (args != null && args is Map) ? args["routeId"] ?? "" : "";

    _routeController = Get.find<BusinessRouteDetailsController>();

    // Fetch & populate
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _routeController.fetchRouteDetails(routeId);
      _populateFields();
    });
  }

  /// API data দিয়ে field গুলো fill করুন
  void _populateFields() {
    final routeDetails= _routeController.routeDetails;
    final route = routeDetails?.routeModel;

    if (route == null) return;

    setState(() {
      titleController.text = route.title;
      detailsController.text = route.details;
      timeTEController.text = route.openingTime;
      locationController.text = route.location;
      isPublic = route.isRoutePublic;
      selectedDifficulty = RouteType.fromString(route.activityType);
      //
      mapUrlController.text = routeDetails?.mapUrl ??"";
      bannerUrl=route.banner;
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    detailsController.dispose();
    timeTEController.dispose();
    locationController.dispose();
    mapUrlController.dispose();
    super.dispose();
  }

  /// ===============================================================
  /// Helper Methods
  /// ===============================================================
  void showTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        timeTEController.text = formatTime(pickedTime);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return GetBuilder<BusinessRouteDetailsController>(
      builder: (controller) {
        // Loading state
        if (controller.isLoading) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: CustomAppbar(title: appBarTitle),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        // Error state
        if (controller.errorMessage != null) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: CustomAppbar(title: appBarTitle),
            body: Center(
              child: Text(
                controller.errorMessage!,
                style: AppTextStyle.textSm(color: colorScheme.error),
              ),
            ),
          );
        }

        final routeDetails= controller.routeDetails;
        final route = routeDetails?.routeModel;
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: CustomAppbar(title: appBarTitle),
          body: Form(
            key: _mainFormKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBanner(colorScheme,route!),
                  const SizedBox(height: 18),
                  _buildHeaderSection(colorScheme),
                  const SizedBox(height: 6),
                  Text(
                    detailsController.text,
                    style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  _buildLocationField(colorScheme),
                  const SizedBox(height: 20),
                  _buildRouteDetailSection(colorScheme),
                  const SizedBox(height: 20),
                  _buildMapSection(colorScheme),
                  const SizedBox(height: 24),
                  _buildOwnerToggle(colorScheme),
                  const SizedBox(height: 12),
                  // OrganizerBusiness থেকে data
                  CompanyInfoCard(
                    title: controller.routeDetails?.organizerBusiness.name ?? "",
                    description: controller.routeDetails?.organizerBusiness.description ?? "",
                    imagePath: controller.routeDetails?.organizerBusiness.logo ?? Assets.images.companyLogo.path,
                  ),
                  const SizedBox(height: 28),
                  _buildBottomButtons(colorScheme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// ===============================================================
  /// UI Components
  /// ===============================================================

  Widget _buildBanner(ColorScheme colorScheme,RouteModel route) {
    return CustomImagePicker(
      imageUrl: bannerUrl,
      height: 200,
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedImage: bannerImage,
      onImageSelected: (file) {
        setState(() {
          bannerImage = file;
        });
      },
      placeholder: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined,
                color: colorScheme.onSurface, size: 30),
            const SizedBox(height: 6),
            Text(
              "Browse image",
              style: AppTextStyle.textMd(
                  color: colorScheme.onSurface, weight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titleController.text,
            style: AppTextStyle.textMd(
                weight: FontWeight.w700, color: colorScheme.onSurface),
          ),
        ),
        IconButton(
          onPressed: () => _showEditBottomSheet(),
          icon:
          Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20),
        ),
      ],
    );
  }

  Widget _buildLocationField(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Location",
            style: AppTextStyle.textSm(
                weight: FontWeight.w700, color: colorScheme.onSurface)),
        const SizedBox(height: 12),
        CustomTextField(
          controller: locationController,
          hintText: "Location",
          prefixIcon: Icon(Icons.location_on_outlined,
              size: 18, color: colorScheme.onSurfaceVariant),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Location cannot be empty";
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: mapUrlController,
          title: "Map url",
          hintText: "http://",
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
        ),
      ],
    );
  }

  Widget _buildRouteDetailSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Routes detail",
            style: AppTextStyle.textSm(
                weight: FontWeight.w700, color: colorScheme.onSurface)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: timeTEController,
                hintText: "Select Time",
                readOnly: true,
                onTap: showTime,
                suffixIcon: Icon(Icons.access_time,
                    size: 18, color: colorScheme.onSurfaceVariant),
                borderColor: colorScheme.outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Select a time";
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDropdown(
                value: selectedDifficulty,
                hintText: "select type",
                dropdownColor: colorScheme.surfaceContainerHigh,
                borderColor: colorScheme.outline,
                hintColor: colorScheme.onSurfaceVariant,
                textColor: colorScheme.onSurface,
                textFontSize: 14,
                hintFontSize: 14,
                items: RouteType.values
                    .map((type) => DropdownMenuItem(
                    value: type, child: Text(type.label)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => selectedDifficulty = value),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: colorScheme.surfaceContainerHigh,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(Assets.images.location.path),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerToggle(ColorScheme colorScheme) {
    return Row(
      children: [
        Text("Owner",
            style: AppTextStyle.textMd(
                weight: FontWeight.w700, color: colorScheme.onSurface)),
        const Spacer(),
        Text(isPublic ? "Public" : "Private",
            style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant)),
        const SizedBox(width: 8),
        Switch(
          value: isPublic,
          activeColor: colorScheme.primary,
          onChanged: (v) => setState(() => isPublic = v),
        ),
      ],
    );
  }

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
            onPressed: () {
              // ✅ Full screen validation
              if (!_mainFormKey.currentState!.validate()) return;

              // TODO: API call with updated data
              // title: titleController.text
              // details: detailsController.text
              // location: locationController.text
              // time: timeTEController.text
              // activityType: selectedDifficulty?.apiValue
              // isPublic: isPublic
            },
          ),
        ),
      ],
    );
  }

  /// ===============================================================
  /// Bottom Sheet — শুধু title & description edit
  /// ===============================================================
  void _showEditBottomSheet() {
    final colorScheme = context.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        final tempTitleController = TextEditingController(text: titleController.text);
        final tempDetailsController = TextEditingController(text: detailsController.text);

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: tempTitleController,
                  hintText: "Title",
                  borderColor: colorScheme.outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Title cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: tempDetailsController,
                  hintText: "Description",
                  maxLine: 4,
                  borderColor: colorScheme.outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Description cannot be empty";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: "Done",
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    setState(() {
                      titleController.text = tempTitleController.text;
                      detailsController.text = tempDetailsController.text;
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}