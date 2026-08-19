import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/features/auth/presentation/controllers/login_controller.dart';
import 'package:loci/features/auth/presentation/controllers/signup_controller.dart';
import 'package:loci/features/auth/presentation/widgets/auth_bottom_link.dart';
import 'package:loci/features/auth/presentation/widgets/auth_divider.dart';
import 'package:loci/features/auth/presentation/widgets/auth_parallax_header.dart';
import 'package:loci/features/auth/presentation/widgets/auth_social_button.dart';
import 'package:loci/gen/assets.gen.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/adaptive_pickers.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_rich_text.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final signupController = Get.find<SignupController>();
  final loginController = Get.find<LoginController>();

  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameTEController = TextEditingController();
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController zipTEController = TextEditingController();
  final TextEditingController dateTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmPasswordTEController =
      TextEditingController();

  final FocusNode nameFocus = FocusNode();
  final FocusNode zipFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();
  final FocusNode confirmPasswordFocus = FocusNode();

  final isAgreed = false.obs;

  @override
  void dispose() {
    nameTEController.dispose();
    emailTEController.dispose();
    zipTEController.dispose();
    dateTEController.dispose();
    passwordTEController.dispose();
    confirmPasswordTEController.dispose();

    nameFocus.dispose();
    zipFocus.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();
    super.dispose();
  }

  void _fieldFocusChange(FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  void _showCalender() async {
    FocusScope.of(context).unfocus();

    final pickedDate = await showAdaptiveDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      dateTEController.text = DateParserHelper.toApiDate(pickedDate);
    }
  }

  void _signupHandler() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!isAgreed.value) {
      SnackbarService.error("Please agree to the terms and conditions");
      return;
    }

    TextInput.finishAutofillContext();
    HapticFeedback.lightImpact();

    final name = nameTEController.text.trim();
    final email = emailTEController.text.trim();
    final password = passwordTEController.text;
    final zipCode = zipTEController.text.trim();
    final dateOfBirth = dateTEController.text.trim();

    final success = await signupController.signup(
      name: name,
      email: email,
      password: password,
      zipCode: zipCode,
      dateOfBirth: dateOfBirth,
    );

    if (success) {
      Get.toNamed(
        AppRoutes.otp,
        arguments: {
          "email": email,
          "message": signupController.successMessage.value,
          "type": "signup",
        },
      );
    } else {
      SnackbarService.error(
        signupController.errorMessage.value ??
            'Signup failed. Please try again.',
        title: 'Signup failed',
      );
    }
  }

  void _googleLoginHandler() async {
    FocusScope.of(context).unfocus();
    HapticFeedback.lightImpact();

    final isSuccess = await loginController.loginWithGoogle();
    if (isSuccess) {
      Get.offAllNamed(AppRoutes.bottomNav);
    } else if (loginController.errorMessage.value != null) {
      SnackbarService.error(
        loginController.errorMessage.value!,
        title: 'Google Sign-In failed',
      );
    }
  }

  void _handleTermsAndConditions() {
    Get.toNamed(AppRoutes.terms);
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
                  child: _buildSignupForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
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
                      text: " Sign Up",
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
                "Create your loci account by providing necessary info",
                style: AppTextStyle.textSm(
                  color: colors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Full Name
              CustomTextField(
                controller: nameTEController,
                focusNode: nameFocus,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => _fieldFocusChange(nameFocus, zipFocus),
                borderColor: colors.outlineVariant.withValues(alpha: 0.6),
                title: "Full name",
                hintText: "Alex Carry",
                textColor: colors.onSurface,
                titleStyle: AppTextStyle.textSm(
                  color: colors.onSurface,
                  weight: FontWeight.w600,
                ),
                inputFormatters: nameInputFormatters,
                validator: validateFullName,
              ),
              const SizedBox(height: 16),

              // DOB
              CustomTextField(
                controller: dateTEController,
                readOnly: true,
                onTap: _showCalender,
                borderColor: colors.outlineVariant.withValues(alpha: 0.6),
                title: "Date of Birth",
                hintText: "Select Date of Birth",
                suffixIcon: Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: colors.onSurfaceVariant,
                ),
                textColor: colors.onSurface,
                titleStyle: AppTextStyle.textSm(
                  color: colors.onSurface,
                  weight: FontWeight.w600,
                ),
                validator: validateDateOfBirth,
              ),
              const SizedBox(height: 16),

              // Zip Code
              CustomTextField(
                controller: zipTEController,
                focusNode: zipFocus,
                keyboardType: TextInputType.number,
                autofillHints: const [AutofillHints.postalCode],
                textInputAction: TextInputAction.next,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (_) => _fieldFocusChange(zipFocus, emailFocus),
                borderColor: colors.outlineVariant.withValues(alpha: 0.6),
                title: "Zip code",
                hintText: "Enter Zipcode",
                textColor: colors.onSurface,
                titleStyle: AppTextStyle.textSm(
                  color: colors.onSurface,
                  weight: FontWeight.w600,
                ),
                validator: validateZipCode,
              ),
              const SizedBox(height: 16),

              // Email
              CustomTextField(
                controller: emailTEController,
                focusNode: emailFocus,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    _fieldFocusChange(emailFocus, passwordFocus),
                borderColor: colors.outlineVariant.withValues(alpha: 0.6),
                title: "Email",
                hintText: "example@gmail.com",
                textColor: colors.onSurface,
                titleStyle: AppTextStyle.textSm(
                  color: colors.onSurface,
                  weight: FontWeight.w600,
                ),
                validator: validateEmail,
              ),
              const SizedBox(height: 16),

              // Password
              CustomTextField(
                controller: passwordTEController,
                focusNode: passwordFocus,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) =>
                    _fieldFocusChange(passwordFocus, confirmPasswordFocus),
                borderColor: colors.outlineVariant.withValues(alpha: 0.6),
                hintText: "Enter password",
                title: "Password",
                textColor: colors.onSurface,
                isPassword: true,
                isObscureText: true,
                titleStyle: AppTextStyle.textSm(
                  color: colors.onSurface,
                  weight: FontWeight.w600,
                ),
                validator: validatePassword,
              ),
              const SizedBox(height: 16),

              // Confirm Password
              CustomTextField(
                controller: confirmPasswordTEController,
                focusNode: confirmPasswordFocus,
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _signupHandler(),
                borderColor: colors.outlineVariant.withValues(alpha: 0.6),
                hintText: "Confirm password",
                title: "Confirm Password",
                textColor: colors.onSurface,
                isPassword: true,
                isObscureText: true,
                titleStyle: AppTextStyle.textSm(
                  color: colors.onSurface,
                  weight: FontWeight.w600,
                ),
                validator: (v) =>
                    validateConfirmPassword(v, passwordTEController.text),
              ),
              const SizedBox(height: 18),

              // Terms and Conditions checkbox
              Obx(
                () => InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    isAgreed.toggle();
                  },
                  child: Row(
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: Checkbox(
                          value: isAgreed.value,
                          onChanged: (v) {
                            HapticFeedback.selectionClick();
                            isAgreed.value = v ?? false;
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CustomRichText(
                          parts: [
                            TextPart(
                              text: "I agree to ",
                              style: AppTextStyle.textXs(
                                color: colors.onSurface,
                              ),
                            ),
                            TextPart(
                              onTap: _handleTermsAndConditions,
                              text: "Terms of Service",
                              style: AppTextStyle.textXs(
                                color: colors.primary,
                                weight: FontWeight.w600,
                              ),
                            ),
                            TextPart(
                              text: " & Privacy Policy",
                              style: AppTextStyle.textXs(
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Submit Button
              Obx(
                () => CustomButton(
                  isLoading: signupController.isLoading.value,
                  backgroundColor: colors.primary,
                  textColor: colors.onPrimary,
                  text: "Sign Up",
                  onPressed: _signupHandler,
                ),
              ),

              const SizedBox(height: 24),
              const AuthDivider(text: "Or sign up with"),
              const SizedBox(height: 18),

              Obx(
                () => AuthSocialButton.google(
                  isLoading: loginController.isGoogleLoading.value,
                  onPressed: _googleLoginHandler,
                ),
              ),

              const SizedBox(height: 28),
              AuthBottomLink(
                promptText: "Already have an account? ",
                actionText: "Sign In",
                onTap: () => Navigator.pop(context),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
