import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/features/auth/presentation/controllers/login_controller.dart';
import 'package:loci/features/auth/presentation/widgets/auth_bottom_link.dart';
import 'package:loci/features/auth/presentation/widgets/auth_divider.dart';
import 'package:loci/features/auth/presentation/widgets/auth_parallax_header.dart';
import 'package:loci/features/auth/presentation/widgets/auth_social_button.dart';
import 'package:loci/gen/assets.gen.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_rich_text.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  final isRememberMe = false.obs;
  final _loginController = Get.find<LoginController>();

  void _loginHandler() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    TextInput.finishAutofillContext();
    HapticFeedback.lightImpact();

    final isSuccess = await _loginController.login(
      email: emailTEController.text.trim(),
      password: passwordTEController.text,
      isRememberMe: isRememberMe.value,
    );

    if (isSuccess) {
      Get.offAllNamed(AppRoutes.bottomNav);
    } else {
      SnackbarService.error(
        _loginController.errorMessage.value!,
        title: 'Login failed',
      );
    }
  }

  void _googleLoginHandler() async {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    final isSuccess = await _loginController.loginWithGoogle();
    if (isSuccess) {
      Get.offAllNamed(AppRoutes.bottomNav);
    } else if (_loginController.errorMessage.value != null) {
      SnackbarService.error(
        _loginController.errorMessage.value!,
        title: 'Google Sign-In failed',
      );
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
    emailTEController.dispose();
    passwordTEController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
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
                background: AuthParallaxHeader(
                  firstImage: Assets.images.onimg5,
                  secondImage: Assets.images.onimg6,
                ),
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
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
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

  Widget _buildLoginForm() {
    final colors = context.colorScheme;

    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 44, 24, 32),
          child: Column(
            children: [
              Center(
                child: CustomRichText(
                  parts: [
                    TextPart(
                      text: "Let’s",
                      style: AppTextStyle.displayXs(
                        color: colors.onSurface,
                        weight: FontWeight.w400,
                      ),
                    ),
                    TextPart(
                      text: " Sign In",
                      style: AppTextStyle.displayXs(
                        color: colors.onSurface,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Please enter your credential access to your account",
                style: AppTextStyle.textSm(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Email field
              CustomTextField(
                controller: emailTEController,
                focusNode: emailFocus,
                borderColor: colors.outlineVariant.withValues(alpha: 0.6),
                hintTextColor: colors.onSurfaceVariant.withValues(alpha: 0.6),
                hintText: "example@gmail.com",
                title: "Email",
                textColor: colors.onSurface,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    FocusScope.of(context).requestFocus(passwordFocus),
                autofillHints: const [AutofillHints.email, AutofillHints.username],
                autoValidateMode: AutovalidateMode.onUnfocus,
                titleStyle: AppTextStyle.textSm(
                  color: colors.onSurface,
                  weight: FontWeight.w600,
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 18),

              // Password field
              CustomTextField(
                controller: passwordTEController,
                focusNode: passwordFocus,
                borderColor: colors.outlineVariant.withValues(alpha: 0.6),
                hintTextColor: colors.onSurfaceVariant.withValues(alpha: 0.6),
                hintText: "Enter password",
                title: "Password",
                textColor: colors.onSurface,
                isPassword: true,
                isObscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _loginHandler(),
                autofillHints: const [AutofillHints.password],
                autoValidateMode: AutovalidateMode.onUnfocus,
                titleStyle: AppTextStyle.textSm(
                  color: colors.onSurface,
                  weight: FontWeight.w600,
                ),
                validator: validateLoginPassword,
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        isRememberMe.toggle();
                      },
                      child: Row(
                        children: [
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: Checkbox(
                              value: isRememberMe.value,
                              onChanged: (value) {
                                HapticFeedback.selectionClick();
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
                              color: colors.onSurface,
                              weight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      Get.toNamed(AppRoutes.forgetPass);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      child: Text(
                        "Forgot password?",
                        style: AppTextStyle.textXs(
                          color: colors.primary,
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              Obx(
                () => CustomButton(
                  isLoading: _loginController.isLoading.value,
                  backgroundColor: colors.primary,
                  textColor: colors.onPrimary,
                  text: "Log In",
                  onPressed: _loginHandler,
                ),
              ),

              const SizedBox(height: 24),
              const AuthDivider(text: "Or login with"),
              const SizedBox(height: 18),

              Obx(
                () => AuthSocialButton.google(
                  isLoading: _loginController.isGoogleLoading.value,
                  onPressed: _googleLoginHandler,
                ),
              ),

              const SizedBox(height: 28),
              AuthBottomLink(
                promptText: "Don't have an account? ",
                actionText: "Register",
                onTap: () => Get.toNamed(AppRoutes.signup),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
