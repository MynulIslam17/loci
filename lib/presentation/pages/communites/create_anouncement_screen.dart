import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/acitivty_ref_type.dart';
import 'package:loci/core/enums/announcement_type.dart';
import 'package:loci/core/theme/app_colors.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/controllers/community/create_announcement_controller.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';

class CreateAnnouncementScreen extends StatefulWidget {


  const CreateAnnouncementScreen({super.key,});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  AnnouncementType _type = AnnouncementType.notice;
  ActivityRefType _activityRefType = ActivityRefType.event;

  // Single file for offer (image or pdf)
  File? _attachment;

  final _detailsController = TextEditingController();
  final _activityIdController = TextEditingController();

  late final String communityId;

  @override
  void initState() {
    super.initState();
    communityId = (Get.arguments as Map)['communityId'] as String;
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _activityIdController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );
    if (result != null && result.files.single.path != null) {
      setState(() => _attachment = File(result.files.single.path!));
    }
  }

  Future<void> _publish() async {
    final ctrl = Get.find<CreateAnnouncementController>();

    final fields = <String, String>{
      'type': _type.toJson,
      'communityId': communityId,
    };

    switch (_type) {
      case AnnouncementType.notice:
      case AnnouncementType.question:
      case AnnouncementType.offer:
        fields['details'] = _detailsController.text.trim();
      case AnnouncementType.activity:
        fields['activityRefType'] = _activityRefType.name;
        fields['activityId'] = _activityIdController.text.trim();
    }

    final success = await ctrl.createAnnouncement(
      fields: fields,
      image: _type == AnnouncementType.offer ? _attachment : null,
    );

    if (success && mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const CustomAppbar(title: "Create Announcement"),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(colors),
                  const SizedBox(height: 20),
                  _typeDropdown(colors),
                  const SizedBox(height: 20),
                  _buildForm(colors),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: GetBuilder<CreateAnnouncementController>(
              builder: (ctrl) => SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomButton(
                  onPressed: ctrl.isLoading ? null : _publish,
                  text: ctrl.isLoading ? "Publishing..." : "Publish",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Announcement Detail",
          style: AppTextStyle.textLg(color: colors.onSurface, weight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          "Please provide the necessary details to create an announcement for the community.",
          style: AppTextStyle.textSm(color: colors.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _typeDropdown(ColorScheme colors) {
    return CustomDropdown(
      title: "Announcement type",
      dropdownColor: colors.surfaceContainerHigh,
      borderColor: colors.outline,
      hintText: "Select type",
      textFontSize: 14,
      hintFontSize: 14,
      hintColor: colors.onSurfaceVariant,
      textColor: colors.onSurface,
      value: _type.label,
      items: AnnouncementType.values
          .map((t) => DropdownMenuItem(value: t.label, child: Text(t.label)))
          .toList(),
      onChanged: (value) {
        final picked = AnnouncementType.values.firstWhere(
          (t) => t.label == value,
          orElse: () => AnnouncementType.notice,
        );
        setState(() {
          _type = picked;
          _attachment = null;
        });
      },
    );
  }

  Widget _buildForm(ColorScheme colors) {
    switch (_type) {
      case AnnouncementType.activity:
        return _activityForm(colors);
      case AnnouncementType.offer:
        return _offerForm(colors);
      case AnnouncementType.notice:
      case AnnouncementType.question:
        return _detailsField(colors);
    }
  }

  Widget _activityForm(ColorScheme colors) {
    final refTypes = [ActivityRefType.event, ActivityRefType.route, ActivityRefType.raffle];

    return Column(
      children: [
        CustomDropdown(
          title: "Activity Type",
          dropdownColor: colors.surfaceContainerHigh,
          borderColor: colors.outline,
          hintText: "Select activity type",
          textFontSize: 14,
          hintFontSize: 14,
          hintColor: colors.onSurfaceVariant,
          textColor: colors.onSurface,
          value: _activityRefType.name,
          items: refTypes
              .map((t) => DropdownMenuItem(value: t.name, child: Text(t.name.capitalize!)))
              .toList(),
          onChanged: (value) {
            setState(() => _activityRefType = ActivityRefType.fromString(value));
          },
        ),
        const SizedBox(height: 20),
        CustomTextField(
          controller: _activityIdController,
          title: "Activity ID",
          hintText: "Enter activity ID",
          borderColor: colors.outline,
          fontSize: 14,
          textColor: colors.onSurface,
          hintTextColor: colors.onSurfaceVariant,
        ),
      ],
    );
  }

  Widget _offerForm(ColorScheme colors) {
    return Column(
      children: [
        _detailsField(colors),
        const SizedBox(height: 20),
        _attachmentPicker(colors),
      ],
    );
  }

  Widget _detailsField(ColorScheme colors) {
    return Column(
      children: [
        CustomTextField(
          controller: _detailsController,
          title: "Details",
          hintText: "Enter details...",
          maxLine: 4,
          borderColor: colors.outline,
          textColor: colors.onSurface,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "Limit: 200 char",
            style: AppTextStyle.textXs(color: colors.onSurfaceVariant),
          ),
        ),
      ],
    );
  }

  Widget _attachmentPicker(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Attachment",
          style: AppTextStyle.textMd(color: colors.onSurface, weight: FontWeight.w600),
        ),
        const SizedBox(height: 12),

        // Show the selected file preview, or the pick button — never both
        if (_attachment != null)
          _filePreview(colors)
        else
          _pickButton(colors),
      ],
    );
  }

  Widget _filePreview(ColorScheme colors) {
    final file = _attachment!;
    final isPdf = file.path.toLowerCase().endsWith('.pdf');
    final fileName = file.path.split('/').last;

    return Card(
      color: colors.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
              color: isPdf ? Colors.red : colors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: AppTextStyle.textSm(weight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isPdf ? "PDF Document" : "Image",
                    style: AppTextStyle.textXs(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => setState(() => _attachment = null),
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pickButton(ColorScheme colors) {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: colors.onPrimaryContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_file, size: 20, color: colors.onSurface),
            const SizedBox(width: 8),
            Text(
              "Add Attachment",
              style: AppTextStyle.textSm(weight: FontWeight.w600, color: colors.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}
