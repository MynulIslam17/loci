import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/routes/app_routes.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../gen/assets.gen.dart';
import '../../controllers/auth/forget_pass_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
  // textField Controllers
  final emailTEController = TextEditingController();

  // Form Key
  final _formKey = GlobalKey<FormState>();

  final forgetPassController = Get.find<ForgetPassController>();

  ///---- emailVerifyHandler

  void _emailVerifyHandler() async {

    //  Hide keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    String email = emailTEController.text.trim();

    bool success = await forgetPassController.sendForgotOtp(email: email);

    if (success) {
      SnackbarService.success(
        forgetPassController.successMessage ?? "OTP sent successfully",
      );

      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          "email": email,
          "message": forgetPassController.successMessage,
          "type": "forgot",
        },
      );
    } else {
      SnackbarService.error(
        forgetPassController.errorMessage ?? "Something went wrong",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colorScheme.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo centered
                        Image.asset(
                          Assets.images.logoPng.path,
                          height: 90,
                          width: 169,
                        ),
                        const SizedBox(height: 48),

                        // Title text
                        Text(
                          "Forgot Password",
                          style: AppTextStyle.displayXs(
                            color: context.colorScheme.onSurface,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle text
                        Text(
                          "Enter email address to reset your password.",
                          textAlign: TextAlign.center,
                          style: AppTextStyle.textXs(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Email Field with theme-aware colors
                        CustomTextField(
                          controller: emailTEController,
                          title: "Email",
                          hintText: "example@gmail.com",
                          borderColor: context.colorScheme.outline,
                          textColor: context.colorScheme.onSurface,
                          titleStyle: AppTextStyle.textXs(
                            color: context.colorScheme.onSurface,
                            weight: FontWeight.w600,
                          ),
                          validator: validateEmail,
                        ),

                        const Spacer(),

                        const SizedBox(height: 40),

                        // Action Button
                        GetBuilder<ForgetPassController>(
                          builder: (controller) {
                            return CustomButton(
                              isLoading: controller.isLoading,
                              backgroundColor: context.colorScheme.primary,
                              textColor: context.colorScheme.onPrimary,
                              text: "Send Code",
                              onPressed: _emailVerifyHandler,
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                      ],
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
