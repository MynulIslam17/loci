import 'package:flutter/material.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import '../../widgets/custom_appbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  /// -------------------------------
  /// TEXT EDITING CONTROLLERS
  /// -------------------------------
  final TextEditingController currentPassController = TextEditingController();
  final TextEditingController newPassController = TextEditingController();
  final TextEditingController confirmPassController = TextEditingController();

  final _formKey=GlobalKey<FormState>();

  @override
  void dispose() {
    // Dispose controllers to free memory
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

                // Password instruction
                Text(
                  "Your password must be at least 6 characters and should include raffles combination of numbers, letters, and special characters (!\$@%)",
                  style: AppTextStyle.textXs(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 20),

                // Current Password
                CustomTextField(
                  controller: currentPassController,
                  hintText: "Current password",
                  isPassword: true,
                  borderColor: colorScheme.outline,
                  validator: (value) => validatePassword(value),
                ),
                const SizedBox(height: 20),

                // New Password
                CustomTextField(
                  controller: newPassController,
                  hintText: "New password",
                  isPassword: true,
                  borderColor: colorScheme.outline,
                  validator: (value) => validatePassword(value),
                ),
                const SizedBox(height: 20),

                // Confirm Password
                CustomTextField(
                  controller: confirmPassController,
                  hintText: "Confirm password",
                  isPassword: true,
                  borderColor: colorScheme.outline,
                  validator:(value) => validateConfirmPassword(value, confirmPassController.text) ,
                ),
                const SizedBox(height: 50),

                // Submit Button
                CustomButton(
                  text: "Change Password",
                  textColor: colorScheme.onPrimary,
                  onPressed: _handleChangePassword,

                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// -------------------------------
  /// HANDLE PASSWORD CHANGE
  /// -------------------------------
  void _handleChangePassword() {
    final current = currentPassController.text.trim();
    final newPass = newPassController.text.trim();
    final confirm = confirmPassController.text.trim();


        if(_formKey.currentState!.validate()){
          SnackbarService.success("success");
        }else{
          SnackbarService.error("error");
        }


     }
}