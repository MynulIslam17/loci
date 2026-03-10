import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_text_field.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {

  /// -------------------------------
  /// STATE VARIABLES
  /// -------------------------------

  /// Dropdown selected value
  String? selectedType = "Notices";

  /// Dropdown options
  final List<String> announcementTypes = ["Offers", "Notices", "Activities"];

  /// Stores picked attachments
  final List<File> attachments = [];

  /// TextEditingControllers
  final TextEditingController activityController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();



  /// -------------------------------
  /// FILE PICKER
  /// -------------------------------

  /// Opens file picker and adds selected file to attachments list
  Future<void> _pickAttachment() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        attachments.add(File(result.files.single.path!));
      });
    }
  }



  /// -------------------------------
  /// MAIN BUILD METHOD
  /// -------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Create Announcement"),
      body: Column(
        children: [

          /// Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _headerSection(),

                  const SizedBox(height: 20),

                  _announcementDropdown(),

                  const SizedBox(height: 20),

                  /// Dynamic form based on dropdown
                  _formBuilder(selectedType),
                ],
              ),
            ),
          ),

          /// Publish Button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: CustomButton(
                onPressed: () {
                  print(activityController.text);
                  print(detailsController.text);
                },
                text: "Publish",
              ),
            ),
          ),
        ],
      ),
    );
  }



  /// -------------------------------
  /// HEADER SECTION
  /// -------------------------------

  Widget _headerSection() {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Announcement Detail",
          style: AppTextStyle.textLg(
            color: colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Please provide the necessary details to create an announcement for the community.",
          style: AppTextStyle.textSm(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }



  /// -------------------------------
  /// ANNOUNCEMENT TYPE DROPDOWN
  /// -------------------------------

  Widget _announcementDropdown() {
    final colorScheme = context.colorScheme;

    return CustomDropdown(
      title: "Announcement type",
      dropdownColor: colorScheme.surfaceContainerHigh,
      borderColor: colorScheme.outline,
      hintText: "Select Category",
      textFontSize: 14,
      hintFontSize: 14,
      hintColor: colorScheme.onSurfaceVariant,
      textColor: colorScheme.onSurface,
      value: selectedType,
      items: announcementTypes
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
      onChanged: (value) {
        setState(() {
          selectedType = value;
        });
      },
    );
  }



  /// -------------------------------
  /// FORM BUILDER
  /// Returns form based on dropdown selection
  /// -------------------------------

  Widget _formBuilder(String? type) {
    switch (type) {
      case "Activities":
        return _activityForm();

      case "Offers":
        return _offerForm();

      case "Notices":
        return _noticeForm();

      default:
        return const SizedBox();
    }
  }



  /// -------------------------------
  /// ACTIVITIES FORM
  /// -------------------------------

  Widget _activityForm() {
    final colorScheme = context.colorScheme;

    return Column(
      children: [

        /// Activity Search
        CustomTextField(
          controller: activityController,
          title: "Activity",
          hintText: "Search your activity",
          borderColor: colorScheme.outline,
          fontSize: 14,
          textColor: colorScheme.onSurface,
          hintTextColor: colorScheme.onSurfaceVariant,
          suffixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 20),

        _detailsField(),
      ],
    );
  }



  /// -------------------------------
  /// OFFERS FORM
  /// -------------------------------

  Widget _offerForm() {
    return Column(
      children: [
        _detailsField(),
        const SizedBox(height: 20),
        _attachmentSection(),
      ],
    );
  }



  /// -------------------------------
  /// NOTICES FORM
  /// -------------------------------

  Widget _noticeForm() {
    return Column(
      children: [
        _detailsField(),
      ],
    );
  }



  /// -------------------------------
  /// DETAILS TEXT FIELD (Reusable)
  /// -------------------------------

  Widget _detailsField() {
    final colorScheme = context.colorScheme;

    return Column(
      children: [
        CustomTextField(
          controller: detailsController,
          title: "Details",
          hintText: "Enter details...",
          maxLine: 4,
          borderColor: colorScheme.outline,
          textColor: colorScheme.onSurface,
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "Limit: 200 char",
            style: AppTextStyle.textXs(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }



  /// -------------------------------
  /// ATTACHMENT SECTION
  /// -------------------------------

  Widget _attachmentSection() {
    final colorScheme = context.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          "Attachment",
          style: AppTextStyle.textMd(
            color: colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        /// Fixed height scrollable file list — always visible
        Container(
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outline,
            ),
            color: colorScheme.surfaceContainer,
          ),
          child: attachments.isEmpty
              ? Center(
            child: Text(
              "No attachments added",
              style: AppTextStyle.textSm(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            itemCount: attachments.length,
            itemBuilder: (context, index) {
              final file = attachments[index];
              final isPdf = file.path.endsWith(".pdf");
              return _buildFileItem(
                file: file,
                icon: isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                color: isPdf ? Colors.red : colorScheme.onSurfaceVariant,
                scheme: colorScheme,
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        /// Add attachment button
        InkWell(
          onTap: _pickAttachment,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: colorScheme.onPrimaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline
              ),
            ),
            child:  Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.attach_file, size: 20,color: colorScheme.onSurface,),
                SizedBox(width: 8),
                Text("Add Attachment",style:AppTextStyle.textSm(weight: FontWeight.w600,color: colorScheme.onSurface),),
              ],
            ),
          ),
        ),
      ],
    );
  }



  /// -------------------------------
  /// FILE ITEM WIDGET
  /// Shows selected attachment
  /// -------------------------------

  Widget _buildFileItem({
    required File file,
    required IconData icon,
    required Color color,
    required ColorScheme scheme,
  }) {
    final isImage = !file.path.endsWith(".pdf");

    String fullName = file.path.split("/").last;
    int dotIndex = fullName.lastIndexOf('.');
    String name = dotIndex != -1 ? fullName.substring(0, dotIndex) : fullName;
    String extension = dotIndex != -1 ? fullName.substring(dotIndex) : '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Card(
        color: scheme.surfaceContainerHigh,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: AppTextStyle.textSm(weight: FontWeight.w500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          extension,
                          style: AppTextStyle.textSm(weight: FontWeight.w500),
                        ),
                      ],
                    ),
                    Text(
                      isImage ? "Image" : "PDF",
                      style: AppTextStyle.textXs(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => attachments.remove(file)),
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// -------------------------------
  /// DISPOSE CONTROLLERS
  /// -------------------------------

  @override
  void dispose() {
    activityController.dispose();
    detailsController.dispose();
    super.dispose();
  }
}