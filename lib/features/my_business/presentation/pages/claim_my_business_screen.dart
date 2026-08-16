import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/my_business/data/models/business_claim_request_model.dart';
import 'package:loci/features/my_business/data/models/create_business_request_model.dart';
import 'package:loci/features/my_business/presentation/controllers/business_claim_controller.dart';
import 'package:loci/shared/widgets/confirm_dialog.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';
import 'package:loci/shared/widgets/custom_image_container.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/file_picker.dart';

import 'package:loci/core/theme/app_colors.dart';

/// Unified claim screen for Google-discovered and manually created businesses.
class ClamMyBusiness extends StatefulWidget {
  const ClamMyBusiness({super.key});

  @override
  State<ClamMyBusiness> createState() => _ClamMyBusinessState();
}

class _ClamMyBusinessState extends State<ClamMyBusiness> {
  final claimController = Get.find<BusinessClaimController>();
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  final selectedCategory = Rxn<BusinessCategory>();
  late final Map<String, dynamic> businessData;
  final proofFiles = <File>[].obs;

  String? get _placeId => businessData['placeId'] as String?;
  bool get _isGoogleClaim => _placeId != null && _placeId!.trim().isNotEmpty;
  bool get _isManualClaim => businessData['isManualClaim'] == true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _initData() {
    businessData = Get.arguments as Map<String, dynamic>? ?? {};

    if (businessData['suggestedCategory'] != null) {
      selectedCategory.value = BusinessCategory.fromString(
        businessData['suggestedCategory'] as String?,
      );
    }
  }

  Future<void> _handleClaimBusiness() async {
    // Dismiss the keyboard so it doesn't linger after navigating back.
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (proofFiles.isEmpty) {
      SnackbarService.error('Please add at least one proof document');
      return;
    }

    if (_isManualClaim) {
      final createRequest = CreateBusinessRequestModel.fromManualData(
        businessData,
        category: selectedCategory.value!.toJson,
      );

      final created = await claimController.createBusiness(
        createRequest,
        attachments: proofFiles.toList(),
      );

      if (created != null) {
        Get.back(
          result: {
            'success': true,
            'message':
                claimController.successMessage.value ?? 'Business created',
            'businessId': created.id,
          },
        );
      } else {
        SnackbarService.error(
          claimController.errorMessage.value ?? 'Failed to create business',
        );
      }
      return;
    }

    if (!_isGoogleClaim || _placeId == null || _placeId!.isEmpty) {
      SnackbarService.error('Missing Google business reference');
      return;
    }

    final request = BusinessClaimRequestModel(
      placeId: _placeId,
      category: selectedCategory.value!.toJson,
      message: _messageController.text.trim(),
      proof: proofFiles.toList(),
    );

    final success = await claimController.claimBusiness(request);

    if (success) {
      Get.back(
        result: {
          'success': true,
          'message': claimController.successMessage.value,
        },
      );
    } else {
      SnackbarService.error(
        claimController.errorMessage.value ?? 'Claim failed',
      );
    }
  }

  Future<void> _pickProof() async {
    try {
      final file = await AppFilePicker.pickSingle();
      if (file != null) proofFiles.add(file);
    } catch (e) {
      SnackbarService.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final brandColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          _isManualClaim ? 'Create Business' : 'Business Claim',
          style: AppTextStyle.textLg(weight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBusinessCard(colorScheme, brandColor),
              const SizedBox(height: 24),
              _buildCategoryDropdown(colorScheme),
              if (_isGoogleClaim) ...[
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _messageController,
                  title: 'Message (optional)',
                  hintText: 'I am the owner of this establishment',
                  maxLine: 3,
                  maxLength: 500,
                  borderColor: colorScheme.outline,
                  textColor: colorScheme.onSurface,
                  hintTextColor: colorScheme.onSurfaceVariant,
                  fontSize: 14,
                ),
              ],
              const SizedBox(height: 24),
              _buildProofHeader(colorScheme, brandColor),
              const SizedBox(height: 12),
              _buildProofList(colorScheme),
              const SizedBox(height: 16),
              _buildAddProofButton(colorScheme),
              const SizedBox(height: 40),
              _buildClaimButton(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBusinessCard(ColorScheme scheme, Color brandColor) {
    final name = businessData['name'] as String? ?? 'Business';
    final description = businessData['description'] as String?;
    final logo = businessData['logo'] as String?;

    return Card(
      color: scheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLogo(logo, scheme),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildContactRow(
                        Icons.location_on_outlined,
                        businessData['location'] as String? ?? '',
                        scheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 6),
                      _buildContactRow(
                        Icons.phone_outlined,
                        businessData['phone'] as String? ?? '',
                        brandColor,
                      ),
                      if (_isGoogleClaim) ...[
                        const SizedBox(height: 6),
                        _buildContactRow(
                          Icons.storefront_outlined,
                          'Google business',
                          scheme.onSurfaceVariant,
                        ),
                      ] else if (_isManualClaim) ...[
                        const SizedBox(height: 6),
                        _buildContactRow(
                          Icons.edit_outlined,
                          'Manual listing',
                          scheme.onSurfaceVariant,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: AppTextStyle.textSm(
                weight: FontWeight.w600,
              ).copyWith(color: brandColor),
            ),
            if (description != null && description.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: AppTextStyle.textXs(
                  color: scheme.onSurfaceVariant,
                ).copyWith(height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(String? logo, ColorScheme scheme) {
    if (logo != null && logo.isNotEmpty) {
      return CustomCachedImage(width: 120, height: 90, imageUrl: logo);
    }

    return Container(
      width: 120,
      height: 90,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.storefront_outlined,
        color: scheme.primary.withValues(alpha: 0.5),
        size: 32,
      ),
    );
  }

  Widget _buildCategoryDropdown(ColorScheme scheme) {
    return SizedBox(
      width: 220,
      child: Card(
        child: CustomDropdown(
          dropdownColor: scheme.surfaceContainerHigh,
          value: selectedCategory.value,
          borderColor: scheme.outline,
          hintText: 'Select Category',
          textFontSize: 14,
          hintFontSize: 14,
          hintColor: scheme.onSurfaceVariant,
          textColor: scheme.onSurface,
          onChanged: (value) => selectedCategory.value = value,
          items: BusinessCategory.values
              .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
              .toList(),
          validator: (value) => value == null ? 'Required' : null,
        ),
      ),
    );
  }

  Widget _buildProofHeader(ColorScheme scheme, Color brandColor) {
    return Row(
      children: [
        Text('Proof ', style: AppTextStyle.textSm(weight: FontWeight.w600)),
        Text(
          '(Required)',
          style: AppTextStyle.textSm(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: _showInfoDialog,
          child: Icon(Icons.help_outline, size: 16, color: brandColor),
        ),
      ],
    );
  }

  void _showInfoDialog() {
    showInfoDialog(
      context,
      title: 'Proof of Ownership',
      message:
          'Upload business license, utility bill, or other ownership documents.',
      buttonText: 'Got it',
    );
  }

  Widget _buildProofList(ColorScheme scheme) {
    return Obx(() {
      if (proofFiles.isEmpty) return const SizedBox.shrink();

      return Column(
        children: proofFiles.map((file) {
          final isPdf = file.path.toLowerCase().endsWith('.pdf');
          return Card(
            color: scheme.surfaceContainerHigh,
            child: ListTile(
              leading: Icon(
                isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                color: isPdf ? Colors.red : scheme.onSurfaceVariant,
              ),
              title: Text(file.path.split(Platform.pathSeparator).last),
              subtitle: Text(isPdf ? 'PDF' : 'Image'),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                onPressed: () => proofFiles.remove(file),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildAddProofButton(ColorScheme scheme) {
    return InkWell(
      onTap: _pickProof,
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
            Icon(Icons.upload_file),
            SizedBox(width: 8),
            Text('Add Proof'),
          ],
        ),
      ),
    );
  }

  Widget _buildClaimButton(ColorScheme scheme) {
    return Obx(() {
      final controller = Get.find<BusinessClaimController>();
      return CustomButton(
        isLoading: controller.isLoading.value,
        text: _isManualClaim ? 'Create Business' : 'Claim Business',
        backgroundColor: scheme.primary,
        textColor: scheme.onPrimary,
        onPressed: _handleClaimBusiness,
      );
    });
  }

  Widget _buildContactRow(IconData icon, String label, Color color) {
    if (label.isEmpty) return const SizedBox.shrink();

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
