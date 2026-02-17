import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/routes/app_routes.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ForgetPassScreen extends StatefulWidget {
  const ForgetPassScreen({super.key});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
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
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                        title: "Email",
                        hintText: "Loisbecket@gmail.com",
                        borderColor: context.colorScheme.outline,
                        textColor: context.colorScheme.onSurface,
                        titleStyle: AppTextStyle.textXs(
                          color: context.colorScheme.onSurface,
                          weight: FontWeight.w600,
                        ),
                      ),


                      const Spacer(),

                      const SizedBox(height: 40),

                      // Action Button
                      CustomButton(
                        backgroundColor: context.colorScheme.primary,
                        textColor: context.colorScheme.onPrimary,
                        text: "Send Code",
                        onPressed: () {
                          Get.toNamed(AppRoutes.otp);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
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