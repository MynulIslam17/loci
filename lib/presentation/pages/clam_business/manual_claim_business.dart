import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';

import '../../../routes/app_routes.dart'; // Ensure path is correct

class ManualClaimBusiness extends StatefulWidget {
  const ManualClaimBusiness({super.key});

  @override
  State<ManualClaimBusiness> createState() => _ManualClaimBusinessState();
}

class _ManualClaimBusinessState extends State<ManualClaimBusiness> {
  // Controllers to manage input data
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String? phoneNumber;
  final _forKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _detailsController.dispose();
    super.dispose();
  }



  void _submitFormHandler() {
    if (!_forKey.currentState!.validate()) return;

    // Prepare the data to pass to the next screen
    final businessData = {
      "name": _nameController.text.trim(),
      "location": _locationController.text.trim(),
      "phone": phoneNumber,
      "website": _websiteController.text.trim(),
      "description": _detailsController.text.trim(),
      "isFromManualClaim": true,

    };

    Get.toNamed(
      AppRoutes.clamBusinessProfile,
      arguments: businessData,
    );
  }








  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final brandTeal = colorScheme.primary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add New Business",
          style: AppTextStyle.textLg(weight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _forKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Business Details",
                      style: AppTextStyle.textLg(weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tell us know about your business",
                      style: AppTextStyle.textSm(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Card(
                      color: colorScheme.surfaceContainerHigh,
                      elevation: 2,

                      child: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Column(
                          children: [
                            CustomTextField(
                              borderColor: colorScheme.outline,
                              title: "Business Name",
                              hintText: "Enter business name",
                              textColor: colorScheme.onSurface,
                              fontSize: 14,
                              controller: _nameController,
                              fillColor: Colors.transparent,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? "Required"
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              borderColor: colorScheme.outline,
                              title: "Location",
                              hintText: "Enter full location",
                              textColor: colorScheme.onSurface,
                              fontSize: 14,
                              controller: _locationController,
                              fillColor: Colors.transparent,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? "Required"
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            IntlPhoneField(

                              decoration: InputDecoration(
                                labelText: 'Phone',
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: colorScheme.outline,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              initialCountryCode: 'BD',
                              dropdownIconPosition: IconPosition.trailing,
                              style: TextStyle(color: colorScheme.onSurface),
                              validator: (phone) {
                                if (phone == null || phone.number.isEmpty) return 'Phone number is required';
                                if (!phone.isValidNumber()) return 'Enter a valid phone number';
                                return null;
                              },
                              onChanged: (phone) {
                                phoneNumber = phone.completeNumber;
                              },
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              title: "Website (optional)",
                              hintText: "URL of your business website",
                              borderColor: colorScheme.outline,
                              textColor: colorScheme.onSurface,
                              fontSize: 14,
                              controller: _websiteController,
                              fillColor: Colors.transparent,
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? "Required"
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            CustomTextField(
                              title: "Business Details",
                              hintText: "Enter details here...",
                              maxLine: 5,
                              borderColor: colorScheme.outline,
                              textColor: colorScheme.onSurface,
                              fontSize: 14,
                              controller: _detailsController,
                              fillColor: Colors.transparent,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return "Required";
                                }
                                if (v.length > 200) {
                                  return "Limit: 200 char";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8),
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
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Action Button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandTeal,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed:_submitFormHandler,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: AppTextStyle.textMd(weight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
