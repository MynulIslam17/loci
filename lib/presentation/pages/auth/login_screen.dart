import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_rich_text.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../../../gen/assets.gen.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/tittle_subtitle.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {


  bool isRememberMe = false;


  @override
  Widget build(BuildContext context) {

    double panelHeight = MediaQuery.of(context).size.height * 0.70;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SlidingUpPanel(
        maxHeight: panelHeight,
        minHeight: panelHeight,
        parallaxEnabled: true,
        color: context.colorScheme.surface,
        parallaxOffset: .5,

        body: _buildBackgroundImageSection(context),
        panelBuilder: (sc) => _buildLoginForm(sc),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40.0),
          topRight: Radius.circular(40.0),
        ),
        boxShadow: const [
          BoxShadow(blurRadius: 10, color: Colors.black12),
        ],
      ),
    );
  }

  Widget _buildBackgroundImageSection(BuildContext context) {
    return Stack(
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
                // 1. Background decorative shape
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..translate(-10.0, -10.0)
                    ..rotateZ(-0.20),
                  child: Container(
                    width: 300,
                    height: 260,
                    decoration: BoxDecoration(
                      color:context.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                ),
                // 2. Left Image
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..translate(-45.0, 15.0)
                    ..rotateZ(-0.55),
                  child: _buildImageCard(Assets.images.onimg5),
                ),
                // 3. Right (Top) Image
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
    );
  }

  Widget _buildLoginForm(ScrollController sc) {
    return ListView(
      controller: sc,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      children: [
        // 1. HEADER SECTION
        const SizedBox(height: 24),
        Center(
          child: CustomRichText(parts: [
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
          ]),
        ),
        const SizedBox(height: 12),
        Text(
          "Please enter your credential access to your account",
          style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),

        // 2. INPUT FIELDS
        const SizedBox(height: 32),
        CustomTextField(
          borderColor: context.colorScheme.outline, // Added border color
          hintTextColor: context.colorScheme.onSurfaceVariant,
          hintText: "Loisbecket@gmail.com",
          title: "Email",
          textColor: context.colorScheme.onSurface,
          titleStyle: AppTextStyle.textXs(
            color: context.colorScheme.onSurface,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        CustomTextField(
          borderColor: context.colorScheme.outline, // Added border color
          hintTextColor: context.colorScheme.onSurfaceVariant,
          hintText: "********",
          title: "Password",
          textColor: context.colorScheme.onSurface,
          isPassword: true,
          isObscureText: true,
          titleStyle: AppTextStyle.textXs(
            color: context.colorScheme.onSurface, // Updated to match Email title
            weight: FontWeight.w600,
          ),
        ),

        // 3. REMEMBER ME & FORGOT PASSWORD
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "Remember me",
                  style: AppTextStyle.textXs(color: context.colorScheme.onSurface),
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

        // 4. ACTION BUTTONS
        const SizedBox(height: 32),
        CustomButton(
          backgroundColor: context.colorScheme.primary,
          textColor: context.colorScheme.onPrimary,
          text: "Log In",
          onPressed: () {},
        ),

        // 5. DIVIDER
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Divider(color: context.colorScheme.outlineVariant)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Or login with",
                style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant),
              ),
            ),
            Expanded(child: Divider(color: context.colorScheme.outlineVariant)),
          ],
        ),

        // 6. SOCIAL LOGIN
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: Text(
            "Continue with Google",
            style: AppTextStyle.textSm(
              color: context.colorScheme.onSurface,
              weight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            side: BorderSide(color: context.colorScheme.outlineVariant),
          ),
        ),

        // 7. REGISTRATION LINK
        const SizedBox(height: 32),
        Center(
          child: CustomRichText(parts: [
            TextPart(
              text: "Don't have an account? ",
              style: AppTextStyle.textSm(color: context.colorScheme.onSurface),
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
          ]),
        ),
        const SizedBox(height: 40),
      ],
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
        child: asset.image(fit: BoxFit.fill),
      ),
    );
  }
}