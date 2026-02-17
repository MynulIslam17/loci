import 'package:flutter/material.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../gen/assets.gen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class ResetPassSceen extends StatefulWidget {
  const ResetPassSceen({super.key});

  @override
  State<ResetPassSceen> createState() => _ResetPassSceenState();
}

class _ResetPassSceenState extends State<ResetPassSceen> {
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
                      // 1. Logo
                      Image.asset(
                        Assets.images.logoPng.path,
                        height: 100,
                      ),
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
                        title: "New Password",
                        hintText: "***********",
                        isPassword: true,
                        borderColor: context.colorScheme.outline,
                        textColor: context.colorScheme.onSurface,
                        titleStyle: AppTextStyle.textXs(
                          color: context.colorScheme.onSurface,
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 5. Confirm Password Field
                      CustomTextField(
                        title: "Confirm Password",
                        hintText: "***********",
                        isPassword: true,
                        borderColor: context.colorScheme.outline,
                        textColor: context.colorScheme.onSurface,
                        titleStyle: AppTextStyle.textXs(
                          color: context.colorScheme.onSurface,
                          weight: FontWeight.w600,
                        ),
                      ),

                      const Spacer(),
                      const SizedBox(height: 40),

                      // 6. Action Button
                      CustomButton(
                        backgroundColor: context.colorScheme.primary,
                        textColor: context.colorScheme.onPrimary,
                        text: "Reset Password",
                        onPressed: () {

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