import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/my_business/data/models/update_business_request_model.dart';
import 'package:loci/features/my_business/presentation/controllers/my_business_profile_controller.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class EditDescriptionForm extends StatefulWidget {
  const EditDescriptionForm({
    super.key,
    required this.initialValue,
    required this.onSubmit,
  });

  final String initialValue;
  final Future<bool> Function(Map<String, dynamic> body) onSubmit;

  @override
  State<EditDescriptionForm> createState() => _EditDescriptionFormState();
}

class _EditDescriptionFormState extends State<EditDescriptionForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  final _isSubmitting = false.obs;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final description = _controller.text.trim();
    final body = UpdateBusinessRequest(description: description).toJson();

    if (description == widget.initialValue.trim()) {
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
            controller: _controller,
            hintText: 'Enter Description',
            maxLine: 3,
            borderColor: colorScheme.outline,
            validator: (value) =>
                value == null || value.isEmpty ? 'Required' : null,
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
