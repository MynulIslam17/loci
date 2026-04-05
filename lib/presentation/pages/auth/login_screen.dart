import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_rich_text.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:logger/logger.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../gen/assets.gen.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth/login_controller.dart';
import '../../widgets/tittle_subtitle.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Form Key
  final _formKey = GlobalKey<FormState>();

  // textField Controllers
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();

  // Remember me toggle
  bool isRememberMe = false;

  final _loginController = Get.find<LoginController>();

  /// Login handler
  void _loginHandler() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final isSuccess = await _loginController.login(
      email: emailTEController.text.trim(),
      password: passwordTEController.text,
    );

    if (isSuccess) {
      Get.offAllNamed(AppRoutes.bottomNav);
    } else {
      SnackbarService.error(_loginController.errorMessage!);
    }
  }
  /// Login with google handler

  void _loginWithGoogleHandler()async{

  }



  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.70;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SlidingUpPanel(
        maxHeight: MediaQuery.of(context).size.height,
        minHeight: panelHeight,
        color: context.colorScheme.surface,
        parallaxOffset: .5,
        parallaxEnabled: true,
        body: _buildBackgroundImageSection(context),
        panelBuilder: (sc) => _buildLoginForm(sc),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black12)],
      ),
    );
  }

  /// Background Image Section
  Widget _buildBackgroundImageSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(color: context.colorScheme.surface),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background decorative shape
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(-10.0, -10.0)
                      ..rotateZ(-0.20),
                    child: Container(
                      width: 300,
                      height: 260,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer.withOpacity(
                          0.6,
                        ),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                  // Left image
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(-45.0, 15.0)
                      ..rotateZ(-0.55),
                    child: _buildImageCard(Assets.images.onimg5),
                  ),
                  // Right (top) image
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(50.0, -10.0)
                      ..rotateZ(0.62),
                    child: _buildImageCard(Assets.images.onimg6),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Login Form
  Widget _buildLoginForm(ScrollController sc) {
    return Form(
      key: _formKey,
      child: ListView(
        controller: sc,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          // Header Section
          Center(
            child: CustomRichText(
              parts: [
                TextPart(
                  text: "Let’s",
                  style: AppTextStyle.displayXs(
                    color: context.colorScheme.onSurface,
                    weight: FontWeight.w400,
                  ),
                ),
                TextPart(
                  text: " Sign In",
                  style: AppTextStyle.displayXs(
                    color: context.colorScheme.onSurface,
                    weight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Please enter your credential access to your account",
            style: AppTextStyle.textXs(
              color: context.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),

          // Input Fields
          const SizedBox(height: 32),
          CustomTextField(
            controller: emailTEController,
            borderColor: context.colorScheme.outline,
            hintTextColor: context.colorScheme.onSurfaceVariant,
            hintText: "exmple@gmail.com",
            title: "Email",
            textColor: context.colorScheme.onSurface,
            titleStyle: AppTextStyle.textXs(
              color: context.colorScheme.onSurface,
              weight: FontWeight.w600,
            ),
            validator: validateEmail,
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: passwordTEController,
            borderColor: context.colorScheme.outline,
            hintTextColor: context.colorScheme.onSurfaceVariant,
            hintText: "Enter password",
            title: "Password",
            textColor: context.colorScheme.onSurface,
            isPassword: true,
            isObscureText: true,
            titleStyle: AppTextStyle.textXs(
              color: context.colorScheme.onSurface,
              weight: FontWeight.w600,
            ),
            validator: validatePassword,
          ),

          // Remember me & Forgot password
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: isRememberMe,
                      onChanged: (value) {
                        setState(() {
                          isRememberMe = value!;
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Remember me",
                    style: AppTextStyle.textXs(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.forgetPass);
                },
                child: Text(
                  "Forgot password",
                  style: AppTextStyle.textXs(
                    color: context.colorScheme.primary,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Action Buttons
          const SizedBox(height: 32),

          GetBuilder<LoginController>(
            builder: (controller) {
              return CustomButton(
                isLoading: controller.isLoading,
                backgroundColor: context.colorScheme.primary,
                textColor: context.colorScheme.onPrimary,
                text: "Log In",
                onPressed: _loginHandler,
              );
            },
          ),

          // Divider
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Divider(color: context.colorScheme.outlineVariant),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Or login with",
                  style: AppTextStyle.textXs(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: Divider(color: context.colorScheme.outlineVariant),
              ),
            ],
          ),

          // Social Login
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _loginWithGoogleHandler,
            icon: SvgPicture.asset("assets/icons/google.svg"),
            label: Text(
              "Continue with Google",
              style: AppTextStyle.textSm(
                color: context.colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: BorderSide(color: context.colorScheme.outlineVariant),
            ),
          ),

          // Registration Link
          const SizedBox(height: 32),
          Center(
            child: CustomRichText(
              parts: [
                TextPart(
                  text: "Don't have an account? ",
                  style: AppTextStyle.textSm(
                    color: context.colorScheme.onSurface,
                  ),
                ),
                TextPart(
                  text: "Register",
                  style: AppTextStyle.textSm(
                    color: context.colorScheme.primary,
                    weight: FontWeight.w700,
                  ),
                  onTap: () {
                    Get.toNamed(AppRoutes.signup);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// Image Card Widget
  Widget _buildImageCard(AssetGenImage asset) {
    return Container(
      width: 180,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: asset.image(fit: BoxFit.fill),
      ),
    );
  }
}
