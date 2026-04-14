import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_imagepicker.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';

import '../../../core/utils/date_parser.dart';
import '../../../core/utils/time_parser.dart';
import '../../../gen/assets.gen.dart';
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

  final TextEditingController titleController = TextEditingController(
    text: "Downtown Pub Crawl",
  );

  final TextEditingController detailsController = TextEditingController(
    text: "Experience the best craft beer spots in downtown...",
  );

  final TextEditingController timeTEController = TextEditingController();
  final TextEditingController locationController = TextEditingController(
    text: "Downtown District",
  );
  final TextEditingController mapUrlController = TextEditingController(
    text: "http://",
  );

  String? selectedDifficulty = "Easy";
  List<String> difficultyLevels = ["Easy", "Medium", "Hard"];
  bool isPublic = true;

  File ? bannerImage;

  @override
  void initState() {
    super.initState();
    var args = Get.arguments;
    appBarTitle = (args != null && args is Map) ? args["title"] ?? "Edit Route" : "Edit Route";
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
          data: MediaQuery.of(context).copyWith(
            alwaysUse24HourFormat: false,
          ),
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

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppbar(title: appBarTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBanner(colorScheme),
            const SizedBox(height: 18),
            _buildHeaderSection(colorScheme),
            const SizedBox(height: 6),
            Text(
              detailsController.text,
              style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
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
              title: "Marland Clutch",
              description: "Lorem Ipsum is simply dummy text...",
              imagePath: Assets.images.companyLogo.path,
            ),
            const SizedBox(height: 28),
            _buildBottomButtons(colorScheme),
          ],
        ),
      ),
    );
  }

  /// ===============================================================
  /// UI Components (Loci Project Structure)
  /// ===============================================================

  Widget _buildBanner(ColorScheme colorScheme) {
    return CustomImagePicker(
      height: 200,
      backgroundColor: colorScheme.surfaceContainerHigh,
      selectedImage: bannerImage,
      onImageSelected: (file) {
        setState(() {
          bannerImage=file;
        });
      },
      placeholder: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload_outlined, color: colorScheme.onSurface, size: 30),
            const SizedBox(height: 6),
            Text(
              "Browse image",
              style: AppTextStyle.textMd(color: colorScheme.onSurface, weight: FontWeight.w600),
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
            style: AppTextStyle.textMd(weight: FontWeight.w700, color: colorScheme.onSurface),
          ),
        ),
        IconButton(
          onPressed: () => _showEditBottomSheet(),
          icon: Icon(Icons.edit_outlined, color: colorScheme.primary, size: 20),
        ),
      ],
    );
  }

  Widget _buildLocationField(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Location", style: AppTextStyle.textSm(weight: FontWeight.w700, color: colorScheme.onSurface)),
        const SizedBox(height: 12),
        CustomTextField(
          controller: locationController,
          hintText: "Location",
          prefixIcon: Icon(Icons.location_on_outlined, size: 18, color: colorScheme.onSurfaceVariant),
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
        Text(
          "Routes detail",
          style: AppTextStyle.textSm(weight: FontWeight.w700, color: colorScheme.onSurface),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: timeTEController,
                hintText: "Select Time",
                readOnly: true,
                onTap: showTime,
                suffixIcon: Icon(Icons.access_time, size: 18, color: colorScheme.onSurfaceVariant),
                borderColor: colorScheme.outline,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomDropdown(
                value: selectedDifficulty,
                dropdownColor: colorScheme.surfaceContainerHigh,
                hintColor: colorScheme.onSurface,
                textColor: colorScheme.onSurface,
                items: difficultyLevels.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setState(() => selectedDifficulty = val),
                borderColor: colorScheme.outline,
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
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(Assets.images.location.path),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: mapUrlController,
              hintText: "http://",
              borderColor: colorScheme.outline,
              textColor: colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOwnerToggle(ColorScheme colorScheme) {
    return Row(
      children: [
        Text("Owner", style: AppTextStyle.textMd(weight: FontWeight.w700, color: colorScheme.onSurface)),
        const Spacer(),
        Text(isPublic ? "Public" : "Private", style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant)),
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
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  void _showEditBottomSheet() {
    final colorScheme = context.colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: titleController, hintText: "Title", borderColor: colorScheme.outline),
            const SizedBox(height: 16),
            CustomTextField(controller: detailsController, hintText: "Description", maxLine: 4, borderColor: colorScheme.outline),
            const SizedBox(height: 20),
            CustomButton(text: "Done", onPressed: (){
              //---get value
              final title=titleController.text;
              final description=detailsController.text;
              setState(() {
                titleController.text=title;
                detailsController.text=description;

              });
              Navigator.pop(context);
            }),
          ],
        ),
      ),
    );
  }
}