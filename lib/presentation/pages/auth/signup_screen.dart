import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/utils/date_parser.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../core/utils/validators.dart';
import '../../../gen/assets.gen.dart';
import '../../controllers/auth/signup_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_rich_text.dart';
import '../../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final signupController = Get.find<SignupController>();

  // Form Key
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController nameTEController = TextEditingController();
  final TextEditingController emailTEController = TextEditingController();
  final TextEditingController zipTEController = TextEditingController();
  final TextEditingController dateTEController = TextEditingController();
  final TextEditingController passwordTEController = TextEditingController();
  final TextEditingController confirmPasswordTEController = TextEditingController();

  bool isAgreed = false;

  void _showCalender() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        dateTEController.text = DateParserHelper.toApiDate(pickedDate);
      });
    }
  }

  void _signupHandler() async{
    if (!_formKey.currentState!.validate()) {
      // Validation failed
      return;
    }

    if (!isAgreed) {

      SnackbarService.error("Please agree to the terms and conditions");
      return;
    }

    // All validations passed, proceed with signup
    String name = nameTEController.text;
    String email = emailTEController.text;
    String password = passwordTEController.text;
    String zipCode = zipTEController.text;
    String dateOfBirth = dateTEController.text;




    bool success=await signupController.signup(name: name, email: email, password: password, zipCode: zipCode, dateOfBirth: dateOfBirth);

    if(success){
      Get.toNamed(AppRoutes.otp,arguments: {
        "email": email,
        "message": signupController.successMessage,
      });
    }


  }

  void _handleTermsAndConditions() {
    print("Terms and Conditions");
  }


  @override
  Widget build(BuildContext context) {
    double panelHeight = MediaQuery.of(context).size.height * 0.70;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SlidingUpPanel(
        maxHeight: MediaQuery.of(context).size.height,
        minHeight: panelHeight,
        parallaxEnabled: true,
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        parallaxOffset: .5,
        body: _buildBackgroundImageSection(context),
        panelBuilder: (sc) => _buildSignupForm(sc),
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
                        color: context.colorScheme.primaryContainer.withOpacity(0.6),
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

  Widget _buildSignupForm(ScrollController sc) {
    return Form(
      key: _formKey,
      child: ListView(
        controller: sc,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
            style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: nameTEController,
            borderColor: context.colorScheme.outline,
            title: "Full name",
            hintText: "Alex Carry",
            textColor: context.colorScheme.onSurface,
            titleStyle: AppTextStyle.textXs(
              color: context.colorScheme.onSurface,
              weight: FontWeight.w600,
            ),
            validator: validateFirstName,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            controller: dateTEController,
            readOnly: true,
            onTap: _showCalender,
            borderColor: context.colorScheme.outline,
            title: "DOB",
            hintText: "Select Date of Birth",
            suffixIcon: Icon(Icons.calendar_today_outlined, size: 20, color: context.colorScheme.onSurfaceVariant),
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
            borderColor: context.colorScheme.outline,
            title: "Email",
            hintText: "Loisbecket@gmail.com",
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
            validator: (v) => validateConfirmPassword(v, passwordTEController.text),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                height: 20,
                width: 20,
                child: Checkbox(
                  value: isAgreed,
                  onChanged: (v) => setState(() => isAgreed = v!),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomRichText(
                  parts: [
                    TextPart(
                      text: "Are you agree To ",
                      style: AppTextStyle.textXs(color: context.colorScheme.onSurface),
                    ),
                    TextPart(
                      onTap: _handleTermsAndConditions,
                      text: "Our Terms ",
                      style: AppTextStyle.textXs(color: context.colorScheme.primary, weight: FontWeight.w600),
                    ),
                    TextPart(
                      text: "of service?",
                      style: AppTextStyle.textXs(color: context.colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

           GetBuilder<SignupController>(builder: (controller){

             return  CustomButton(
               isLoading: controller.isLoading,
               backgroundColor: context.colorScheme.primary,
               textColor: context.colorScheme.onPrimary,
               text: "Sign Up",
               onPressed: _signupHandler,
             );


           }),

          const SizedBox(height: 20),
          Center(
            child: CustomRichText(
              parts: [
                TextPart(
                  text: "Already have an account? ",
                  style: AppTextStyle.textSm(color: context.colorScheme.onSurface),
                ),
                TextPart(
                  text: "Sign In",
                  style: AppTextStyle.textSm(color: context.colorScheme.primary, weight: FontWeight.w700),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildImageCard(AssetGenImage asset) {
    return Container(
      width: 180,
      height: 230,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: asset.image(fit: BoxFit.cover),
      ),
    );
  }
}