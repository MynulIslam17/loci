import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/form_labels.dart';
import 'package:loci/shared/widgets/location/location_picker_field.dart';

import 'package:loci/routes/app_routes.dart';

class ManualClaimBusiness extends StatefulWidget {
  const ManualClaimBusiness({super.key});

  @override
  State<ManualClaimBusiness> createState() => _ManualClaimBusinessState();
}

class _ManualClaimBusinessState extends State<ManualClaimBusiness> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _websiteController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();

  String? phoneNumber;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _websiteController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submitFormHandler() async {
    // Dismiss the keyboard so it doesn't linger after navigating back.
    FocusManager.instance.primaryFocus?.unfocus();

    if (!_formKey.currentState!.validate()) return;

    final result = await Get.toNamed(
      AppRoutes.clamBusinessProfile,
      arguments: {
        'isManualClaim': true,
        'name': _nameController.text.trim(),
        'location': _locationController.text.trim(),
        'phone': phoneNumber,
        'website': _websiteController.text.trim(),
        'description': _detailsController.text.trim(),
      },
    );

    // Pass the server result (incl. its message) straight back to the search
    // screen, which shows the message and resets its fields.
    if (result != null && result['success'] == true) {
      Get.back(result: result);
    }
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
          'Add New Business',
          style: AppTextStyle.textLg(weight: FontWeight.w600),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Business Details',
                      style: AppTextStyle.textLg(weight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter your business info, then continue to claim it.',
                      style: AppTextStyle.textSm(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const RequiredFieldsNote(),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: colorScheme.outline.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const FormSectionLabel(label: 'Business details'),
                          const SizedBox(height: 16),
                          CustomTextField(
                            borderColor: colorScheme.outline,
                            title: 'Business name',
                            isRequired: true,
                            hintText: 'Enter business name',
                            textColor: colorScheme.onSurface,
                            fontSize: 14,
                            controller: _nameController,
                            fillColor: Colors.transparent,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              if (v.length < 2) {
                                return 'Business name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          LocationPickerField(
                            controller: _locationController,
                            title: 'Location',
                            isRequired: true,
                            hintText: 'Search business address',
                            borderColor: colorScheme.outline,
                            fillColor: Colors.transparent,
                            fontSize: 14,
                            validator: (v) => v == null || v.trim().isEmpty
                                ? 'Required'
                                : null,
                            // Business claim only needs the address text.
                          ),
                          const SizedBox(height: 16),
                          FormField<String>(
                            validator: (_) {
                              if (phoneNumber == null ||
                                  phoneNumber!.isEmpty) {
                                return 'Phone number is required';
                              }
                              return null;
                            },
                            builder: (state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const FormFieldLabel(
                                    label: 'Phone',
                                    isRequired: true,
                                  ),
                                  const SizedBox(height: 6),
                                  IntlPhoneField(
                                    decoration: InputDecoration(
                                      hintText: 'Enter phone number',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline,
                                          width: 1.2,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.outline,
                                          width: 1.2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.primary,
                                          width: 1.2,
                                        ),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.error,
                                          width: 1.2,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(
                                          color: colorScheme.error,
                                          width: 1.2,
                                        ),
                                      ),
                                      errorText: state.errorText,
                                    ),
                                    initialCountryCode: 'BD',
                                    dropdownIconPosition: IconPosition.trailing,
                                    onChanged: (phone) {
                                      phoneNumber = phone.completeNumber;
                                      state.didChange(phone.completeNumber);
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            title: 'Website',
                            isRequired: false,
                            hintText: 'URL of your business website',
                            borderColor: colorScheme.outline,
                            textColor: colorScheme.onSurface,
                            fontSize: 14,
                            controller: _websiteController,
                            fillColor: Colors.transparent,
                          ),
                          const SizedBox(height: 16),
                          CustomTextField(
                            title: 'Business details',
                            isRequired: true,
                            hintText: 'Enter details here...',
                            maxLine: 5,
                            borderColor: colorScheme.outline,
                            textColor: colorScheme.onSurface,
                            fontSize: 14,
                            controller: _detailsController,
                            fillColor: Colors.transparent,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              if (v.length > 200) return 'Limit: 200 char';
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              'Limit: 200 char',
                              style: AppTextStyle.textXs(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                  onPressed: _submitFormHandler,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
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
