import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/core/utils/validators.dart';
import 'package:loci/gen/assets.gen.dart';
import 'package:loci/features/auth/presentation/controllers/signup_controller.dart';
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

  // Form Key
  final _formKey = GlobalKey<FormState>();

  // textField Controllers
  final TextEditingController nameTEController = TextEditingController();
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController zipTEController = TextEditingController();
  final TextEditingController dateTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmPasswordTEController =
      TextEditingController();

  // Focus nodes for production-level "next" field traversal.
  // Keeping the keyboard's IME session alive across fields avoids the
  // hide/show flicker (and the perceived open delay) when moving between them.
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

  /// Moves the IME focus from [current] to [next] without letting the
  /// keyboard collapse, so it slides straight to the next field instead of
  /// hiding and re-showing (which is what caused the open delay/flicker).
  void _fieldFocusChange(FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  void _showCalender() async {
    // Drop any open keyboard before showing the date picker.
    FocusScope.of(context).unfocus();

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      dateTEController.text = DateParserHelper.toApiDate(pickedDate);
    }
  }

  void _signupHandler() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      // Validation failed
      return;
    }

    if (!isAgreed.value) {
      SnackbarService.error("Please agree to the terms and conditions");
      return;
    }

    // All validations passed, proceed with signup
    String name = nameTEController.text;
    String email = emailTEController.text;
    String password = passwordTEController.text;
    String zipCode = zipTEController.text;
    String dateOfBirth = dateTEController.text;

    bool success = await signupController.signup(
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
            "Signup failed. Please try again.",
      );
    }
  }

  void _handleTermsAndConditions() {
    print("Terms and Conditions");
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
                  child: _buildSignupForm(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
            child: SizedBox(
              height: 300,
              child: Stack(
                alignment: Alignment.center,
                children: [
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
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(-45.0, 15.0)
                      ..rotateZ(-0.15),
                    child: _buildImageCard(Assets.images.onimg5),
                  ),
                  Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..translate(50.0, -10.0)
                      ..rotateZ(0.12),
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

  Widget _buildSignupForm() {
    return AutofillGroup(
      child: Form(
        key: _formKey,
        child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
        child: Column(
          children: [
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
                    text: " Sign UP",
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
              "Create your loci account by providing necessary info",
              style: AppTextStyle.textXs(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: nameTEController,
              focusNode: nameFocus,
              keyboardType: TextInputType.name,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _fieldFocusChange(nameFocus, zipFocus),
              borderColor: context.colorScheme.outline,
              title: "Full name",
              hintText: "Alex Carry",
              textColor: context.colorScheme.onSurface,
              titleStyle: AppTextStyle.textXs(
                color: context.colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
              inputFormatters: nameInputFormatters,
              validator: validateFullName,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: dateTEController,
              readOnly: true,
              onTap: _showCalender,
              borderColor: context.colorScheme.outline,
              title: "DOB",
              hintText: "Select Date of Birth",
              suffixIcon: Icon(
                Icons.calendar_today_outlined,
                size: 20,
                color: context.colorScheme.onSurfaceVariant,
              ),
              textColor: context.colorScheme.onSurface,
              titleStyle: AppTextStyle.textXs(
                color: context.colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
              validator: validateDateOfBirth,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: zipTEController,
              focusNode: zipFocus,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.postalCode],
              textInputAction: TextInputAction.next,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onFieldSubmitted: (_) => _fieldFocusChange(zipFocus, emailFocus),
              borderColor: context.colorScheme.outline,
              title: "Zip code",
              hintText: "Enter Zipcode",
              textColor: context.colorScheme.onSurface,
              titleStyle: AppTextStyle.textXs(
                color: context.colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
              validator: validateZipCode,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: emailTEController,
              focusNode: emailFocus,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  _fieldFocusChange(emailFocus, passwordFocus),
              borderColor: context.colorScheme.outline,
              title: "Email",
              hintText: "example@gmail.com",
              textColor: context.colorScheme.onSurface,
              titleStyle: AppTextStyle.textXs(
                color: context.colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
              validator: validateEmail,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              controller: passwordTEController,
              focusNode: passwordFocus,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) =>
                  _fieldFocusChange(passwordFocus, confirmPasswordFocus),
              borderColor: context.colorScheme.outline,
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
            const SizedBox(height: 12),
            CustomTextField(
              controller: confirmPasswordTEController,
              focusNode: confirmPasswordFocus,
              autofillHints: const [AutofillHints.newPassword],
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _signupHandler(),
              borderColor: context.colorScheme.outline,
              hintText: "Confirm password",
              title: "Confirm Password",
              textColor: context.colorScheme.onSurface,
              isPassword: true,
              isObscureText: true,
              titleStyle: AppTextStyle.textXs(
                color: context.colorScheme.onSurface,
                weight: FontWeight.w600,
              ),
              validator: (v) =>
                  validateConfirmPassword(v, passwordTEController.text),
            ),
            const SizedBox(height: 20),
            Obx(
              () => Row(
                children: [
                  SizedBox(
                    height: 20,
                    width: 20,
                    child: Checkbox(
                      value: isAgreed.value,
                      onChanged: (v) => isAgreed.value = v ?? false,
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
                          text: "Are you agree To ",
                          style: AppTextStyle.textXs(
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                        TextPart(
                          onTap: _handleTermsAndConditions,
                          text: "Our Terms ",
                          style: AppTextStyle.textXs(
                            color: context.colorScheme.primary,
                            weight: FontWeight.w600,
                          ),
                        ),
                        TextPart(
                          text: "of service?",
                          style: AppTextStyle.textXs(
                            color: context.colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Obx(
              () => CustomButton(
                isLoading: signupController.isLoading.value,
                backgroundColor: context.colorScheme.primary,
                textColor: context.colorScheme.onPrimary,
                text: "Sign Up",
                onPressed: _signupHandler,
              ),
            ),

            const SizedBox(height: 20),
            Center(
              child: CustomRichText(
                parts: [
                  TextPart(
                    text: "Already have an account? ",
                    style: AppTextStyle.textSm(
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                  TextPart(
                    text: "Sign In",
                    style: AppTextStyle.textSm(
                      color: context.colorScheme.primary,
                      weight: FontWeight.w700,
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
        ),
      ),
    );
  }

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
        child: asset.image(fit: BoxFit.cover),
      ),
    );
  }
}
