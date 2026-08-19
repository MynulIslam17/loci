import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/features/auth/presentation/controllers/pass_reset_controller.dart';
import 'package:loci/features/auth/presentation/widgets/auth_logo_header.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class ResetPassScreen extends StatefulWidget {
  const ResetPassScreen({super.key});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  final _formKey = GlobalKey<FormState>();
  final passResetController = Get.find<PassResetController>();

  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmPasswordTEController =
      TextEditingController();

  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  late final String email;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?["email"] ?? "";
  }

  @override
  void dispose() {
    passwordTEController.dispose();
    confirmPasswordTEController.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _passResetHandler() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    TextInput.finishAutofillContext();
    HapticFeedback.lightImpact();

    final password = confirmPasswordTEController.text.trim();

    final success = await passResetController.resetPassword(
      email: email,
      newPassword: password,
    );

    if (success) {
      SnackbarService.success(passResetController.successMessage.value!);
      Get.offAllNamed(AppRoutes.login);
    } else {
      SnackbarService.error(
        passResetController.errorMessage.value!,
        title: 'Password reset failed',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const CustomAppbar(title: ''),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          const AuthLogoHeader(
                            title: "Reset Password",
                            subtitle:
                                "Enter and confirm your new password below to reset your account access. Must be at least 8 characters long.",
                          ),
                          const SizedBox(height: 36),

                          // New Password Field
                          CustomTextField(
                            controller: passwordTEController,
                            focusNode: passwordFocus,
                            title: "New Password",
                            hintText: "Enter new password",
                            isPassword: true,
                            isObscureText: true,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(confirmPasswordFocus),
                            borderColor:
                                colors.outlineVariant.withValues(alpha: 0.6),
                            textColor: colors.onSurface,
                            titleStyle: AppTextStyle.textSm(
                              color: colors.onSurface,
                              weight: FontWeight.w600,
                            ),
                            validator: validatePassword,
                          ),
                          const SizedBox(height: 18),

                          // Confirm Password Field
                          CustomTextField(
                            controller: confirmPasswordTEController,
                            focusNode: confirmPasswordFocus,
                            title: "Confirm Password",
                            hintText: "Confirm new password",
                            isPassword: true,
                            isObscureText: true,
                            autofillHints: const [AutofillHints.newPassword],
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _passResetHandler(),
                            borderColor:
                                colors.outlineVariant.withValues(alpha: 0.6),
                            textColor: colors.onSurface,
                            titleStyle: AppTextStyle.textSm(
                              color: colors.onSurface,
                              weight: FontWeight.w600,
                            ),
                            validator: (value) => validateConfirmPassword(
                              value,
                              passwordTEController.text,
                            ),
                          ),

                          const Spacer(),
                          const SizedBox(height: 32),

                          // Action Button
                          Obx(
                            () => CustomButton(
                              isLoading: passResetController.isLoading.value,
                              backgroundColor: colors.primary,
                              textColor: colors.onPrimary,
                              text: "Reset Password",
                              onPressed: _passResetHandler,
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
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
