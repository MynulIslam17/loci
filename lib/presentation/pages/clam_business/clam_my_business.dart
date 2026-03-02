import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import 'package:loci/presentation/widgets/custom_image_container.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/custom_imagepicker.dart';

class ClamMyBusiness extends StatefulWidget {
  const ClamMyBusiness({super.key});

  @override
  State<ClamMyBusiness> createState() => _ClamMyBusinessState();
}

class _ClamMyBusinessState extends State<ClamMyBusiness> {
  String? selectedCategory;
  final List<String> categories = [
    "Food & Beverage",
    "Manufacturing",
    "Retail",
  ];

  bool isFromManualClaim = false;
  File? _pickedImage;

  // List to store attachments
  List<File> attachments = [];

  @override
  void initState() {
    super.initState();

    // Receive arguments from previous page
    final args = Get.arguments;
    if (args != null && args is Map) {
      isFromManualClaim = args['isFromManualClaim'] ?? false;
    }
  }

  //---- for picke file or attachment

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final brandColor = colorScheme.primary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Business Claim",
          style: AppTextStyle.textLg(weight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Business Card ---
            // --- 1. Top Business Card ---
            Card(
              color: colorScheme.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // --- DYNAMIC IMAGE PICKER / VIEWER ---
                        SizedBox(
                          width: 120,
                          height: 90,
                          child: isFromManualClaim == true
                              ? CustomImagePicker(
                                  height: 90,
                                  selectedImage: _pickedImage,
                                  borderColor: colorScheme.outline,
                                  backgroundColor: colorScheme.surface,
                                  onImageSelected: (file) {
                                    setState(() {
                                      _pickedImage = file;
                                    });
                                  },
                                  placeholder: Icon(
                                    Icons.add_a_photo_outlined,
                                    color: colorScheme.primary.withOpacity(0.5),
                                    size: 30,
                                  ),
                                )
                              : CustomCachedImage(
                                  width: 120,
                                  height: 90,
                                  imageUrl: "assets/images/finedine.png",
                                ),
                        ),
                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildContactRow(
                                Icons.location_on_outlined,
                                isFromManualClaim == true
                                    ? "Location not set"
                                    : "30 Frank Lloyd Wright Dr...",
                                colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(height: 6),
                              _buildContactRow(
                                Icons.phone_outlined,
                                isFromManualClaim == true
                                    ? "Phone not set"
                                    : "+1 800-216-3515",
                                brandColor,
                              ),
                              const SizedBox(height: 6),
                              // Hide reviews for manual claim as it's a new entry
                              if (isFromManualClaim != true)
                                Row(
                                  children: [
                                    Text(
                                      "0 Review",
                                      style: AppTextStyle.textXs(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    ...List.generate(
                                      5,
                                      (index) => Icon(
                                        Icons.star,
                                        size: 14,
                                        color: AppColors.starColor,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      isFromManualClaim == true
                          ? "New Business Listing"
                          : "Dominos Pizza",
                      style: AppTextStyle.textSm(
                        weight: FontWeight.w600,
                      ).copyWith(color: brandColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isFromManualClaim == true
                          ? "Upload a logo and set the category to begin your manual claim process."
                          : "Dominos Pizza, founded in 1931, is a prominent global manufacturer...",
                      style: AppTextStyle.textXs(
                        color: colorScheme.onSurfaceVariant,
                      ).copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Category Dropdown ---
            SizedBox(
              width: 220,
              child: Card(
                color: colorScheme.surfaceContainerHigh,
                child: CustomDropdown(
                  dropdownColor: colorScheme.surfaceContainerHigh,
                  value: selectedCategory,
                  borderColor: colorScheme.outline,
                  hintText: "Select Category",
                  textFontSize: 14,
                  hintFontSize: 14,
                  hintColor: colorScheme.onSurfaceVariant,
                  textColor: colorScheme.onSurface,
                  onChanged: (value) =>
                      setState(() => selectedCategory = value),
                  items: categories
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- Attachments ---
            Row(
              children: [
                Text(
                  "Attachment ",
                  style: AppTextStyle.textSm(weight: FontWeight.w600),
                ),
                Text(
                  "(Proof)",
                  style: AppTextStyle.textSm(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
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
                          "Please upload a business document that verifies you own this business (e.g. business license, registration certificate, or utility bill).\n\nBy uploading, you agree to our Privacy Policy and confirm this document will be reviewed securely.",
                          style: AppTextStyle.textXs(
                            color: colorScheme.onSurfaceVariant,
                          ).copyWith(height: 1.6),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // TODO: Navigate to Privacy Policy page
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Read Privacy Policy",
                              style: AppTextStyle.textXs(color: brandColor),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              "Got it",
                              style: AppTextStyle.textXs(
                                weight: FontWeight.w600,
                                color: brandColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Icon(Icons.help_outline, size: 16, color: brandColor),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // --- Attachments List ---
            if (attachments.isNotEmpty)
              ...attachments.map((file) {
                final isPdf = file.path.endsWith(".pdf");
                return _buildFileItem(
                  file: file,
                  icon: isPdf ? Icons.picture_as_pdf : Icons.image_outlined,
                  color: isPdf ? Colors.red : colorScheme.onSurfaceVariant,
                  scheme: colorScheme,
                );
              }).toList(),



            const SizedBox(height: 16),

            // --- Add Attachment Button ---
            InkWell(
              onTap:_pickAttachment, // Add file picker logic here
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: colorScheme.outline,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.link, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Add Attachment",
                      style: AppTextStyle.textSm(weight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            CustomButton(
              text: "Claim Business",
              backgroundColor: colorScheme.primary,
              textColor: colorScheme.onPrimary,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyle.textXs(color: color),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFileItem({
    required File file,
    required IconData icon,
    required Color color,
    required ColorScheme scheme,
  }) {
    final isImage = !file.path.endsWith(".pdf");

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(file.path.split("/").last,
                      style: AppTextStyle.textSm(weight: FontWeight.w500)),
                  Text(
                      isImage ? "Image" : "PDF",
                      style: AppTextStyle.textXs(color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                setState(() => attachments.remove(file));
              },
              icon: Icon(Icons.delete_outline, color: AppColors.danger),
            ),
          ],
        ),
      ),
    );
  }
}
