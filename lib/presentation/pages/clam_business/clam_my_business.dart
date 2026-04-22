import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/data/models/busniess/business_claim_request_model.dart';
import 'package:loci/presentation/controllers/my_business/business_claim_controller.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import 'package:loci/presentation/widgets/file_picker.dart';
import 'package:loci/routes/app_routes.dart';

import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_imagepicker.dart';

class ClamMyBusiness extends StatefulWidget {
  const ClamMyBusiness({super.key});

  @override
  State<ClamMyBusiness> createState() => _ClamMyBusinessState();
}

class _ClamMyBusinessState extends State<ClamMyBusiness> {
  final claimController = Get.find<BusinessClaimController>();

  final _formKey = GlobalKey<FormState>();

  BusinessCategory? selectedCategory;
  bool isFromManualClaim = false;

  late final Map<String, dynamic> businessData;

  File? _pickedImage;
  List<File> attachments = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    businessData = Get.arguments as Map<String, dynamic>? ?? {};
    isFromManualClaim = businessData['isFromManualClaim'] ?? false;
  }

  // ---------------- ACTIONS ----------------

  void _handleClaimBusiness() async {
    // TODO: handle API call

    if (!_formKey.currentState!.validate()) return;

    if (attachments.isEmpty) {
      SnackbarService.error("Please add at least one ownership document");
      return;
    }

    final request = BusinessClaimRequestModel(
      name: businessData['name'],
      category: selectedCategory?.toJson,
      description: businessData['description'],
      phone: businessData['phone'],
      website: businessData['website'],
      location: businessData['location'],
      logo: _pickedImage,
      attachments: attachments,
    );

    bool success = await claimController.claimBusiness(request);

    if (success) {
      Get.back(
        result: {"success": true, "message": claimController.successMessage},
      );
    } else {
      SnackbarService.error(claimController.errorMessage!);
    }
  }

  Future<void> _pickAttachment() async {
    final file = await AppFilePicker.pickSingle();
    if (file != null) {
      setState(() => attachments.add(file));
    }
  }

  // ---------------- UI BUILD ----------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final brandColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //---top section
              _buildBusinessCard(colorScheme, brandColor),
              const SizedBox(height: 24),

              //---category section
              _buildCategoryDropdown(colorScheme),
              const SizedBox(height: 24),

              //--attachment section
              _buildAttachmentHeader(colorScheme, brandColor),
              const SizedBox(height: 12),

              _buildAttachmentList(colorScheme),
              const SizedBox(height: 16),
              _buildAddAttachmentButton(colorScheme),
              const SizedBox(height: 40),

              //---submit button
              _buildClaimButton(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- APP BAR ----------------

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        "Business Claim",
        style: AppTextStyle.textLg(weight: FontWeight.w600),
      ),
    );
  }

  // ---------------- BUSINESS CARD ----------------

  Widget _buildBusinessCard(ColorScheme scheme, Color brandColor) {
    return Card(
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _buildBusinessHeader(scheme, brandColor),
            const SizedBox(height: 20),
            _buildBusinessTitle(brandColor),
            const SizedBox(height: 8),
            _buildBusinessDescription(scheme),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHeader(ColorScheme scheme, Color brandColor) {
    return Row(
      children: [
        _buildImageSection(scheme),
        const SizedBox(width: 12),
        Expanded(child: _buildBusinessInfo(scheme, brandColor)),
      ],
    );
  }

  Widget _buildImageSection(ColorScheme scheme) {
    return SizedBox(
      width: 120,
      height: 90,
      child: isFromManualClaim
          ? CustomImagePicker(
              height: 90,
              selectedImage: _pickedImage,
              borderColor: scheme.outline,
              backgroundColor: scheme.surface,
              onImageSelected: (file) {
                setState(() => _pickedImage = file);
              },
              placeholder: Icon(
                Icons.add_a_photo_outlined,
                color: scheme.primary.withOpacity(0.5),
                size: 30,
              ),
            )
          : CustomCachedImage(
              width: 120,
              height: 90,
              imageUrl: "assets/images/finedine.png",
            ),
    );
  }

  Widget _buildBusinessInfo(ColorScheme scheme, Color brandColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildContactRow(
          Icons.location_on_outlined,
          businessData['location'],
          scheme.onSurfaceVariant,
        ),
        const SizedBox(height: 6),
        _buildContactRow(
          Icons.phone_outlined,
          businessData["phone"],
          brandColor,
        ),
        const SizedBox(height: 6),
        if (!isFromManualClaim) _buildRatingRow(scheme),
      ],
    );
  }

  Widget _buildRatingRow(ColorScheme scheme) {
    return Row(
      children: [
        Text(
          "0 Review",
          style: AppTextStyle.textXs(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 6),
        ...List.generate(
          5,
          (index) =>
              const Icon(Icons.star, size: 14, color: AppColors.starColor),
        ),
      ],
    );
  }

  Widget _buildBusinessTitle(Color brandColor) {
    return Text(
      isFromManualClaim ? "New Business Listing" : "Dominos Pizza",
      style: AppTextStyle.textSm(
        weight: FontWeight.w600,
      ).copyWith(color: brandColor),
    );
  }

  Widget _buildBusinessDescription(ColorScheme scheme) {
    return Text(
      isFromManualClaim
          ? "Upload raffles logo and set the category to begin your manual claim process."
          : "Dominos Pizza, founded in 1931, is raffles prominent global manufacturer...",
      style: AppTextStyle.textXs(
        color: scheme.onSurfaceVariant,
      ).copyWith(height: 1.5),
    );
  }

  // ---------------- CATEGORY ----------------

  Widget _buildCategoryDropdown(ColorScheme scheme) {
    return SizedBox(
      width: 220,
      child: Card(
        child: CustomDropdown(
          dropdownColor: scheme.surfaceContainerHigh,
          value: selectedCategory,
          borderColor: scheme.outline,
          hintText: "Select Category",
          textFontSize: 14,
          hintFontSize: 14,
          hintColor: scheme.onSurfaceVariant,
          textColor: scheme.onSurface,
          onChanged: (value) => setState(() => selectedCategory = value),
          items: BusinessCategory.values
              .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
              .toList(),
          validator: (value) => value == null ? "Required" : null,
        ),
      ),
    );
  }

  // ---------------- ATTACHMENTS ----------------

  Widget _buildAttachmentHeader(ColorScheme scheme, Color brandColor) {
    return Row(
      children: [
        Text(
          "Attachment ",
          style: AppTextStyle.textSm(weight: FontWeight.w600),
        ),
        Text(
          "(Proof)",
          style: AppTextStyle.textSm(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _showInfoDialog(scheme, brandColor),
          child: Icon(Icons.help_outline, size: 16, color: brandColor),
        ),
      ],
    );
  }

  void _showInfoDialog(ColorScheme scheme, Color brandColor) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: brandColor, size: 20),
            const SizedBox(width: 8),
            Text(
              "Proof of Ownership",
              style: AppTextStyle.textSm(weight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          "Please upload business document...",
          style: AppTextStyle.textXs(color: scheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Got it"),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentList(ColorScheme scheme) {
    if (attachments.isEmpty) return const SizedBox();

    return Column(
      children: attachments.map((file) {
        final isPdf = file.path.endsWith(".pdf");
        return _buildFileItem(file, isPdf, scheme);
      }).toList(),
    );
  }

  Widget _buildFileItem(File file, bool isPdf, ColorScheme scheme) {
    return Card(
      color: scheme.surfaceContainerHigh,
      child: ListTile(
        leading: Icon(
          isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
          color: isPdf ? Colors.red : scheme.onSurfaceVariant,
        ),
        title: Text(file.path.split("/").last),
        subtitle: Text(isPdf ? "PDF" : "Image"),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: AppColors.danger),
          onPressed: () => setState(() => attachments.remove(file)),
        ),
      ),
    );
  }

  Widget _buildAddAttachmentButton(ColorScheme scheme) {
    return InkWell(
      onTap: _pickAttachment,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: scheme.outline),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.link),
            SizedBox(width: 8),
            Text("Add Attachment"),
          ],
        ),
      ),
    );
  }

  // ---------------- CLAIM BUTTON ----------------

  Widget _buildClaimButton(ColorScheme scheme) {
    return GetBuilder<BusinessClaimController>(
      builder: (controller) {
        return CustomButton(
          isLoading: controller.isLoading,
          text: "Claim Business",
          backgroundColor: scheme.primary,
          textColor: scheme.onPrimary,
          onPressed: _handleClaimBusiness,
        );
      },
    );
  }

  // ---------------- COMMON ----------------

  Widget _buildContactRow(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyle.textXs(color: color),
          ),
        ),
      ],
    );
  }
}
