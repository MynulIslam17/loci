import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/category_enum.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/my_business/data/models/business_profile_model.dart';
import 'package:loci/features/my_business/data/models/update_business_request_model.dart';
import 'package:loci/features/my_business/presentation/controllers/my_business_profile_controller.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_dropdown.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class EditBusinessInfoForm extends StatefulWidget {
  const EditBusinessInfoForm({
    super.key,
    required this.business,
    required this.onSubmit,
  });

  final BusinessProfileModel business;
  final Future<bool> Function(Map<String, dynamic> body) onSubmit;

  @override
  State<EditBusinessInfoForm> createState() => _EditBusinessInfoFormState();
}

class _EditBusinessInfoFormState extends State<EditBusinessInfoForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final Rx<BusinessCategory> _category;
  final _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.business.name);
    _locationController = TextEditingController(text: widget.business.location);
    _category = Rx(BusinessCategory.fromString(widget.business.category));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final body = UpdateBusinessRequest(
      name: _nameController.text.trim(),
      location: _locationController.text.trim(),
      category: _category.value.toJson,
    ).diffFrom(widget.business);

    if (body.isEmpty) {
      if (mounted) Navigator.pop(context);
      return;
    }

    _isSubmitting.value = true;
    try {
      final success = await widget.onSubmit(body);
      if (!mounted) return;
      if (success) {
        Navigator.pop(context);
      } else {
        final message = Get.find<MyBusinessProfileController>()
            .errorMessage
            .value;
        SnackbarService.error(message ?? 'Update failed. Please try again.');
      }
    } finally {
      if (mounted) _isSubmitting.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomTextField(
            controller: _nameController,
            borderColor: colorScheme.outline,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Name is required'
                : null,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _locationController,
            borderColor: colorScheme.outline,
            validator: (value) => value == null || value.trim().isEmpty
                ? 'Location required'
                : null,
          ),
          const SizedBox(height: 12),
          Obx(
            () => CustomDropdown<BusinessCategory>(
              value: _category.value,
              onChanged: (value) {
                if (value == null) return;
                _category.value = value;
              },
              items: BusinessCategory.values
                  .map(
                    (category) => DropdownMenuItem<BusinessCategory>(
                      value: category,
                      child: Text(category.label),
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => CustomButton(
              isLoading: _isSubmitting.value,
              text: 'Update',
              onPressed: _isSubmitting.value ? null : _submit,
            ),
          ),
        ],
      ),
    );
  }
}
