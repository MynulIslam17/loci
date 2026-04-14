import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/presentation/controllers/auth/pass_reset_controller.dart';
import 'package:loci/routes/app_routes.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ResetPassScreen extends StatefulWidget {
  const ResetPassScreen({super.key});

  @override
  State<ResetPassScreen> createState() => _ResetPassScreenState();
}

class _ResetPassScreenState extends State<ResetPassScreen> {
  // Form Key
  final _formKey = GlobalKey<FormState>();
  // Get x controller
  final passResetController = Get.find<PassResetController>();

  // Text controllers
  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmPasswordTEController =
      TextEditingController();

  // Data passed from previous screen
  late final String email;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // Receive arguments from previous screen
    final args = Get.arguments as Map<String, dynamic>?;
    email = args?["email"] ?? "";
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // Dispose controllers and focus node to avoid memory leaks
    passwordTEController.dispose();
    confirmPasswordTEController.dispose();
    super.dispose();
  }

  ///---pass reset handler
  void _passResetHandler() async {
    //hide keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    String password=confirmPasswordTEController.text.trim();

    bool success=await passResetController.resetPassword(email: email, newPassword: password);

    if(success){
      SnackbarService.success(passResetController.successMessage!);
      Get.offAllNamed(AppRoutes.login);
    }else{
      SnackbarService.error(passResetController.errorMessage!);
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
                        // 1. Logo
                        Image.asset(Assets.images.logoPng.path, height: 100),
                        const SizedBox(height: 40),

                        // 2. Title
                        Text(
                          "Reset Password",
                          style: AppTextStyle.displayXs(
                            color: context.colorScheme.onSurface,
                            weight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 3. Subtitle
                        Text(
                          "Enter and confirm your new password below to reset your account access. Your new password must be at least 8 characters long",
                          textAlign: TextAlign.center,
                          style: AppTextStyle.textXs(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // 4. New Password Field
                        CustomTextField(
                          controller: passwordTEController,
                          title: "New Password",
                          hintText: "Enter Password",
                          isPassword: true,
                          borderColor: context.colorScheme.outline,
                          textColor: context.colorScheme.onSurface,
                          titleStyle: AppTextStyle.textXs(
                            color: context.colorScheme.onSurface,
                            weight: FontWeight.w600,
                          ),
                          validator: validatePassword,
                        ),
                        const SizedBox(height: 20),

                        // 5. Confirm Password Field
                        CustomTextField(
                          controller: confirmPasswordTEController,
                          title: "Confirm Password",
                          hintText: "Enter Password",
                          isPassword: true,
                          borderColor: context.colorScheme.outline,
                          textColor: context.colorScheme.onSurface,
                          titleStyle: AppTextStyle.textXs(
                            color: context.colorScheme.onSurface,
                            weight: FontWeight.w600,
                          ),
                          validator: (value) => validateConfirmPassword(
                            value,
                            passwordTEController.text,
                          ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 40),

                        // 6. Action Button
                        GetBuilder<PassResetController>(builder: (controller){
                          return  CustomButton(
                            isLoading: controller.isLoading,
                            backgroundColor: context.colorScheme.primary,
                            textColor: context.colorScheme.onPrimary,
                            text: "Reset Password",
                            onPressed: _passResetHandler,
                          );
                        }),

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
