import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_appbar.dart';
import 'package:loci/presentation/widgets/custom_dropdown.dart';
import '../../widgets/custom_text_field.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  String? selectedType = "Offers";

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppbar(title: "Create Announcement"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Announcement Detail",
              style: AppTextStyle.textLg(
                color: colorScheme.onSurface,
                weight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Please provide the necessary details to create an announcement for the community.",
              style: AppTextStyle.textSm(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            // Announcement Type Dropdown
            Text(
              "Announcement type",
              style: AppTextStyle.textMd(
                color: colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            // Using a container to mimic your style or you can use CustomDropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colorScheme.outline),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: ["Offers", "Events", "General"].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() => selectedType = newValue);
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Details TextField
            Text(
              "Details",
              style: AppTextStyle.textMd(
                color: colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              hintText: "Enter details...",
              maxLine: 4,
              borderColor: colorScheme.outline,
              textColor: colorScheme.onSurface,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "Limit: 200 char",
                style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
              ),
            ),

            const SizedBox(height: 20),

            // Attachment Section
            Row(
              children: [
                Text(
                  "Attachment",
                  style: AppTextStyle.textMd(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.help_outline, size: 16, color: colorScheme.primary),
              ],
            ),
            const SizedBox(height: 12),

            // Existing Attachments
            _buildAttachmentItem(
              context,
              "Black Friday Discount.pdf",
              "2.4 MB",
              Icons.picture_as_pdf,
              Colors.red,
            ),
            _buildAttachmentItem(
              context,
              "Black Friday Discount.jpg",
              "2.4 MB",
              Icons.image,
              Colors.blue,
            ),

            // Add Attachment Button
            InkWell(
              onTap: () {}, // Add image picker logic here
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                    style: BorderStyle.solid, // Use DottedBorder package if available
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.attach_file, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      "Add Attachment",
                      style: AppTextStyle.textMd(color: colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Publish Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5CB8AC), // Your brand teal
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Publish",
                  style: AppTextStyle.textMd(weight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentItem(BuildContext context, String title, String size,
      IconData icon, Color iconColor) {
    final colorScheme = context.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.textSm(
                    color: colorScheme.onSurface,
                    weight: FontWeight.w500,
                  ),
                ),
                Text(
                  size,
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }
}