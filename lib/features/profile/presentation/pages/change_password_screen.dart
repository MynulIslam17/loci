import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/features/profile/presentation/controllers/change_password_controller.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController currentPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  final ChangePasswordController _controller = Get.find<ChangePasswordController>();

  @override
  void dispose() {
    currentPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Scaffold(
      appBar: const CustomAppbar(title: "Change Password"),
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),

                Text(
                  "Your password must be at least 8 characters and include a "
                  "combination of uppercase, lowercase letters and numbers.",
                  style: AppTextStyle.textXs(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                // Current Password — same rules as account creation.
                CustomTextField(
                  controller: currentPassController,
                  hintText: "Current password",
                  isPassword: true,
                  borderColor: colorScheme.outline,
                  validator: validatePassword,
                ),
                const SizedBox(height: 20),

                // New Password
                CustomTextField(
                  controller: newPassController,
                  hintText: "New password",
                  isPassword: true,
                  borderColor: colorScheme.outline,
                  validator: validatePassword,
                ),
                const SizedBox(height: 20),

                // Confirm Password — compared against the NEW password.
                CustomTextField(
                  controller: confirmPassController,
                  hintText: "Confirm password",
                  isPassword: true,
                  borderColor: colorScheme.outline,
                  validator: (value) =>
                      validateConfirmPassword(value, newPassController.text),
                ),
                const SizedBox(height: 50),

                // Submit Button
                Obx(
                  () => CustomButton(
                    text: "Change Password",
                    textColor: colorScheme.onPrimary,
                    isLoading: _controller.isLoading,
                    onPressed: _handleChangePassword,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await _controller.changePassword(
      currentPassword: currentPassController.text.trim(),
      newPassword: newPassController.text.trim(),
    );

    if (success && mounted) Get.back();
  }
}
