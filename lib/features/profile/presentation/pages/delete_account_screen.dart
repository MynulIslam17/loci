import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/profile/domain/services/profile_service.dart';
import 'package:loci/features/profile/presentation/controllers/delete_account_controller.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/core/utils/dialog_helper.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late final DeleteAccountController _controller = Get.put(
    DeleteAccountController(
      Get.find<ProfileService>(),
      Get.find<AuthController>(),
    ),
  );

  @override
  void dispose() {
    _passwordController.dispose();
    Get.delete<DeleteAccountController>();
    super.dispose();
  }

  void _confirmDelete() {
    if (!_formKey.currentState!.validate()) return;

    showDeleteDialog(
      context: context,
      title: "Delete Account",
      message:
          "Are you sure you want to delete your account? This action cannot be undone.",
      onDelete: () =>
          _controller.deleteAccount(_passwordController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: const CustomAppbar(title: "Delete Account"),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - 48,
              ),
              child: IntrinsicHeight(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// --- Instruction Text ---
                      Text(
                        "Please enter your password to confirm account removal",
                        style: AppTextStyle.textSm(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// --- Password Field ---
                      CustomTextField(
                        controller: _passwordController,
                        hintText: "Current password",
                        isPassword: true,
                        borderColor: colorScheme.outline,
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                            ? "Password is required"
                            : null,
                      ),

                      const Spacer(),

                      /// --- Warning Text ---
                      Align(
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "This will permanently delete your account and all personal data from our system. This action cannot be undone.",
                            textAlign: TextAlign.center,
                            style: AppTextStyle.textXs(
                              color: colorScheme.onSurfaceVariant,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// --- Delete Button ---
                      Obx(
                        () => CustomButton(
                          text: "Delete Account",
                          textColor: colorScheme.onPrimary,
                          backgroundColor: colorScheme.error,
                          isLoading: _controller.isLoading,
                          onPressed: _confirmDelete,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
