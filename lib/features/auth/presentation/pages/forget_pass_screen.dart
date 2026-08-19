import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/features/auth/presentation/controllers/forget_pass_controller.dart';
import 'package:loci/features/auth/presentation/widgets/auth_logo_header.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  final emailTEController = TextEditingController();
  final FocusNode emailFocus = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final forgetPassController = Get.find<ForgetPassController>();

  @override
  void dispose() {
    emailTEController.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  void _emailVerifyHandler() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    TextInput.finishAutofillContext();
    HapticFeedback.lightImpact();

    final email = emailTEController.text.trim();
    final success = await forgetPassController.sendForgotOtp(email: email);

    if (success) {
      SnackbarService.success(
        forgetPassController.successMessage.value ?? "OTP sent successfully",
      );

      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          "email": email,
          "message": forgetPassController.successMessage.value,
          "type": "forgot",
        },
      );
    } else {
      SnackbarService.error(
        forgetPassController.errorMessage.value ?? 'Something went wrong',
        title: 'Could not send code',
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
                            title: "Forgot Password",
                            subtitle:
                                "Enter your email address to receive a verification code.",
                          ),
                          const SizedBox(height: 36),

                          // Email Field
                          CustomTextField(
                            controller: emailTEController,
                            focusNode: emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.email],
                            onFieldSubmitted: (_) => _emailVerifyHandler(),
                            title: "Email",
                            hintText: "example@gmail.com",
                            borderColor:
                                colors.outlineVariant.withValues(alpha: 0.6),
                            textColor: colors.onSurface,
                            titleStyle: AppTextStyle.textSm(
                              color: colors.onSurface,
                              weight: FontWeight.w600,
                            ),
                            validator: validateEmail,
                          ),

                          const Spacer(),
                          const SizedBox(height: 32),

                          // Action Button
                          Obx(
                            () => CustomButton(
                              isLoading: forgetPassController.isLoading.value,
                              backgroundColor: colors.primary,
                              textColor: colors.onPrimary,
                              text: "Send Code",
                              onPressed: _emailVerifyHandler,
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
