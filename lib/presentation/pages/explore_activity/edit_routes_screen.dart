import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/routeType.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/data/models/routes/routes_model.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_imagepicker.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';

import '../../../core/utils/time_parser.dart';
import '../../../data/models/explore_activity/route_update_request_model.dart';
import '../../../gen/assets.gen.dart';
import '../../controllers/explore_acitivity/business_route_details_controller.dart';
import '../../controllers/explore_acitivity/business_route_update_controller.dart';
import '../../widgets/common/company_info_card.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditRoutesScreen extends StatefulWidget {
  const EditRoutesScreen({super.key});

  @override
  State<EditRoutesScreen> createState() => _EditRoutesScreenState();
}

class _EditRoutesScreenState extends State<EditRoutesScreen> {
  late final String routeId;

  // Controllers
  final _routeController = Get.find<BusinessRouteDetailsController>();
  final _routeUpdateController = Get.find<BusinessRouteUpdateController>();

  // State Variables
  TimeOfDay? selectedTime;
  RouteType? selectAvailabilityType;
  bool isPublic = true;
  File? bannerImage;
  Map<String, dynamic>? _initialData;

  final GlobalKey<FormState> _mainFormKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController titleTEController = TextEditingController();
  final TextEditingController detailsTEController = TextEditingController();
  final TextEditingController timeTEController = TextEditingController();
  final TextEditingController locationTEController = TextEditingController();
  final TextEditingController mapUrlTEController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;
    routeId = args?["routeId"] ?? "";

    //  ADD LISTENERS: This makes the Update button respond to typing
    titleTEController.addListener(_onStateChange);
    detailsTEController.addListener(_onStateChange);
    locationTEController.addListener(_onStateChange);
    mapUrlTEController.addListener(_onStateChange);
    timeTEController.addListener(_onStateChange);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _routeController.fetchRouteDetails(routeId);
      _populateFields();
    });
  }

  // Helper to trigger UI refresh when any field changes
  void _onStateChange() => setState(() {});

  @override
  void dispose() {
    // Clean up listeners and controllers
    titleTEController.dispose();
    detailsTEController.dispose();
    timeTEController.dispose();
    locationTEController.dispose();
    mapUrlTEController.dispose();
    super.dispose();
  }

  void _populateFields() {
    final route = _routeController.routeDetails?.routeModel;
    final details = _routeController.routeDetails;
    if (route == null) return;

    final parsedTime = parseTime(route.openingTime);

    // Store original state for comparison logic
    _initialData = {
      'title': route.title,
      'details': route.details,
      'location': route.location,
      'mapUrl': details?.mapUrl ?? "",
      'isPublic': route.isRoutePublic,
      'availabilityType': RouteType.fromString(route.activityType),
      'time': parsedTime != null ? formatTime(parsedTime) : "",
    };

    // Fill the UI with initial data
    titleTEController.text = _initialData!['title'];
    detailsTEController.text = _initialData!['details'];
    locationTEController.text = _initialData!['location'];
    mapUrlTEController.text = _initialData!['mapUrl'];
    isPublic = _initialData!['isPublic'];
    selectAvailabilityType = _initialData!['availabilityType'];
    selectedTime = parsedTime;
    timeTEController.text = _initialData!['time'];

    setState(() {});
  }

  // GETTER: Compares current state vs original data
  bool get _isChanged {
    if (_initialData == null) return false;

    return titleTEController.text != _initialData!['title'] ||
        detailsTEController.text != _initialData!['details'] ||
        locationTEController.text != _initialData!['location'] ||
        mapUrlTEController.text != _initialData!['mapUrl'] ||
        isPublic != _initialData!['isPublic'] ||
        selectAvailabilityType != _initialData!['availabilityType'] ||
        timeTEController.text != _initialData!['time'] ||
        bannerImage != null;
  }


  //-----update handler---------------
  void _handleUpdate() async {
    FocusScope.of(context).unfocus();
    if (!_mainFormKey.currentState!.validate()) return;

    final route = _routeController.routeDetails!.routeModel;
    final details = _routeController.routeDetails!;


    //---check if value not change then not sent
    final request = RouteUpdateRequest(
      routeId: routeId,
      title: titleTEController.text != route.title ? titleTEController.text : null,
      details: detailsTEController.text != route.details ? detailsTEController.text : null,
      location: locationTEController.text != route.location ? locationTEController.text : null,
      url: mapUrlTEController.text != (details.mapUrl ?? "") ? mapUrlTEController.text : null,
      isPublic: isPublic != route.isRoutePublic ? isPublic : null,
      availabilityType: selectAvailabilityType?.apiValue != route.activityType ? selectAvailabilityType : null,
      openingTime: timeTEController.text != _initialData!['time'] ? timeTEController.text : null,
      bannerFile: bannerImage,
    );

    final success = await _routeUpdateController.updateRoute(request);

    if (success) {
      Get.back(result: true);
      SnackbarService.success("Route updated successfully");
    } else {
      SnackbarService.success(_routeUpdateController.errorMessage!);
    }
  }

  void _showTimePicker() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );

    if (picked == null) return;

    setState(() {
      selectedTime = picked;
      timeTEController.text = formatTime(picked);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Edit Route"),
      body: GetBuilder<BusinessRouteDetailsController>(
        builder: (controller) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.errorMessage != null) {
            return Center(child: Text(controller.errorMessage!));
          }

          final routeDetails = controller.routeDetails;
          final route = routeDetails?.routeModel;

          if (route == null) {
            return const Center(child: Text("No route found"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(14),
            child: Form(
              key: _mainFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBanner(colorScheme, route),
                  const SizedBox(height: 18),
                  _buildHeaderSection(colorScheme, route),
                  const SizedBox(height: 6),
                  Text(
                    detailsTEController.text,
                    style: AppTextStyle.textXs(
                      color: colorScheme.onSurfaceVariant,
                    ),
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
                  CompanyInfoCard(
                    title: routeDetails?.organizerBusiness.name ?? "",
                    description:
                        routeDetails?.organizerBusiness.description ?? "",
                    imagePath:
                        routeDetails?.organizerBusiness.logo ??
                        Assets.images.companyLogo.path,
                  ),
                  const SizedBox(height: 28),
                  _buildBottomButtons(colorScheme),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBanner(ColorScheme colorScheme, RouteModel route) {
    return CustomImagePicker(
      imageUrl: route.banner,
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

  Widget _buildHeaderSection(ColorScheme colorScheme, RouteModel route) {
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
          onPressed: _showEditBottomSheet,
          icon: Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20),
        ),
      ],
    );
  }

  Widget _buildLocationField(ColorScheme colorScheme) {
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
          hintText: "Location",
          prefixIcon: Icon(
            Icons.location_on_outlined,
            size: 18,
            color: colorScheme.onSurfaceVariant,
          ),
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? "Location cannot be empty"
              : null,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          controller: mapUrlTEController,
          title: "Map url",
          hintText: "http://",
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
          validator: (value){
            if(value==null ||value.isEmpty){
              return  "Map url required";
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildRouteDetailSection(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Routes detail",
          style: AppTextStyle.textSm(
            weight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                title: "Opening Time",
                controller: timeTEController,
                hintText: "Select Time",
                readOnly: true,
                onTap: _showTimePicker,
                suffixIcon: Icon(
                  Icons.access_time,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                borderColor: colorScheme.outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDropdown(
                dropdownColor: colorScheme.surfaceContainerHigh,
                borderColor: colorScheme.outline,
                hintColor: colorScheme.onSurfaceVariant,
                textColor: colorScheme.onSurface,
                textFontSize: 14,
                hintFontSize: 14,
                title: "Availability types",
                value: selectAvailabilityType,
                hintText: "Select type",
                items: RouteType.values
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text(e.label)),
                    )
                    .toList(),
                onChanged: (v) => setState(() => selectAvailabilityType = v),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(Assets.images.location.path),
        ),
      ),
    );
  }

  Widget _buildOwnerToggle(ColorScheme colorScheme) {
    return Row(
      children: [
        Text(
          "Owner",
          style: AppTextStyle.textMd(
            weight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        const Spacer(),
        Text(isPublic ? "Public" : "Private"),
        Switch(value: isPublic, onChanged: (v) => setState(() => isPublic = v)),
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
          child: GetBuilder<BusinessRouteUpdateController>(
            builder: (updateController) {
              return CustomButton(
                isLoading: updateController.isLoading,
                text: "Update",

                onPressed: !_isChanged ? null
                    : _handleUpdate
              );
            },
          ),
        ),
      ],
    );
  }

  void _showEditBottomSheet() {
    final colorScheme = context.colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        final formKey = GlobalKey<FormState>();
        // Initialize with current text from the screen
        final t = TextEditingController(text: titleTEController.text);
        final d = TextEditingController(text: detailsTEController.text);

        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            top: 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Update Info",
                  style: AppTextStyle.textMd(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  title: "Title",
                  borderColor: colorScheme.outline,
                  controller: t,
                  hintText: "Title",
                  validator: (value) => (value == null || value.isEmpty) ? "Title required" : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  title: "Description",
                  controller: d,
                  hintText: "Description",
                  borderColor: colorScheme.outline,
                  maxLine: 4,
                  validator: (value) => (value == null || value.isEmpty) ? "Description required" : null,
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: "Done",
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;

                    // SAVE TO SCREEN CONTROLLERS
                    setState(() {
                      titleTEController.text = t.text;
                      detailsTEController.text = d.text;
                    });

                    Navigator.pop(context); // Close sheet
                    // The main Update button will now enable because title/details are changed
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
