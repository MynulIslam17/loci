import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_rich_text.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/gen/assets.gen.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/features/auth/presentation/controllers/login_controller.dart';

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
  final isRememberMe = false.obs;

  final _loginController = Get.find<LoginController>();

  /// Login handler
  void _loginHandler() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final isSuccess = await _loginController.login(
      email: emailTEController.text.trim(),
      password: passwordTEController.text,
      isRememberMe: isRememberMe.value,
    );

    if (isSuccess) {
      Get.offAllNamed(AppRoutes.bottomNav);
    } else {
      SnackbarService.error(_loginController.errorMessage.value!);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadRememberedPreference();
  }

  Future<void> _loadRememberedPreference() async {
    final pref = await _loginController.getRememberedPreference();
    if (pref.remember && pref.email != null && pref.email!.isNotEmpty) {
      emailTEController.text = pref.email!;
      isRememberMe.value = true;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = context.colorScheme.surface;

    return Scaffold(
      backgroundColor: surfaceColor,
      body: ColoredBox(
        color: surfaceColor,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              backgroundColor: surfaceColor,
              expandedHeight: 360,
              toolbarHeight: 0,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                stretchModes: const [StretchMode.zoomBackground],
                background: _buildBackgroundImageSection(context),
              ),
            ),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -40),
                child: Container(
                  padding: const EdgeInsets.only(bottom: 40),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: _buildLoginForm(),
                ),
              ),
            ),
          ],
        ),
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
                      ..translateByDouble(-10.0, -10.0, 0.0, 1.0)
                      ..rotateZ(-0.20),
                    child: Container(
                      width: 300,
                      height: 260,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer.withValues(alpha: 0.6,),
                        borderRadius: BorderRadius.circular(40),
                      ),
                    ),
                  ),
                  // Left image
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translateByDouble(-45.0, 15.0, 0.0, 1.0)
                      ..rotateZ(-0.55),
                    child: _buildImageCard(Assets.images.onimg5),
                  ),
                  // Right (top) image
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translateByDouble(50.0, -10.0, 0.0, 1.0)
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
  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
        child: Column(
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
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              autoValidateMode: AutovalidateMode.onUnfocus,
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
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              autoValidateMode: AutovalidateMode.onUnfocus,
              titleStyle: AppTextStyle.textXs(
                color: context.colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
              // Sign-in only checks that a password was entered; strength rules
              // are for signup / reset password screens.
              validator: validateLoginPassword,
            ),

            // Remember me & Forgot password
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Checkbox(
                          value: isRememberMe.value,
                          onChanged: (value) {
                            isRememberMe.value = value ?? false;
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

            Obx(
              () => CustomButton(
                isLoading: _loginController.isLoading.value,
                backgroundColor: context.colorScheme.primary,
                textColor: context.colorScheme.onPrimary,
                text: "Log In",
                onPressed: _loginHandler,
              ),
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

            // Decorative only — Google Sign-In is disabled for now.
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {},
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
            color: Colors.black.withValues(alpha: 0.08),
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
