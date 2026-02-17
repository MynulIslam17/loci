import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pinput/pinput.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../gen/assets.gen.dart';
import '../../../routes/app_routes.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_rich_text.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: AppTextStyle.displayXs(
        color: context.colorScheme.onSurface,
        weight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colorScheme.outlineVariant),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: context.colorScheme.primary, width: 2),
      ),
    );

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
                        "Enter verification code",
                        style: AppTextStyle.displayXs(
                          color: context.colorScheme.onSurface,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. Subtitle with dynamic email
                      CustomRichText(
                        textAlign: TextAlign.center,
                        parts: [
                          TextPart(
                            text: "We’ve sent a verification code to ",
                            style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant),
                          ),
                          TextPart(
                            text: "example@gmail.com ",
                            style: AppTextStyle.textXs(
                              color: context.colorScheme.primary,
                              weight: FontWeight.w600,
                            ),
                          ),
                          TextPart(
                            text: "that will expire in 10 minutes.",
                            style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

                      // 4. Pinput Widget
                      Pinput(
                        length: 6,
                        controller: controller,
                        focusNode: focusNode,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        separatorBuilder: (index) => const SizedBox(width: 8),
                        hapticFeedbackType: HapticFeedbackType.lightImpact,
                        onCompleted: (pin) {
                          debugPrint('Completed: $pin');
                        },
                      ),
                      const SizedBox(height: 32),

                      // 5. Resend Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Didn’t receive the code?",
                            style: AppTextStyle.textSm(color: context.colorScheme.onSurfaceVariant),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              "Resend Code",
                              style: AppTextStyle.textSm(
                                color: Colors.redAccent,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),
                      const SizedBox(height: 40),

                      // 6. Verify Button
                      CustomButton(
                        backgroundColor: context.colorScheme.primary,
                        textColor: context.colorScheme.onPrimary,
                        text: "Verify",
                        onPressed: () {

                          Get.toNamed(AppRoutes.passReset);

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