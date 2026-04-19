import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/presentation/controllers/auth/resend_otp_controller.dart';
import 'package:pinput/pinput.dart';
import '../../../core/constants/app_text_style.dart';
import '../../../core/theme/theme_extention.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../gen/assets.gen.dart';
import '../../../routes/app_routes.dart';
import '../../controllers/auth/verify_email_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_rich_text.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  // Controllers for verification and resending OTP
  final verifyEmailController = Get.find<VerifyEmailController>();
  final resendController = Get.find<ResendOtpController>();

  // Data passed from previous screen
  late final String email;
  late final String message;
  late final String type; // signup or forgot password

  // Text controller and focus for OTP input
  final otpTEController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    // Receive arguments from previous screen
    final args = Get.arguments as Map<String, dynamic>?;

    email = args?["email"] ?? "";
    message = args?["message"] ?? "";
    type = args?["type"] ?? "";
  }

  @override
  void dispose() {
    // Dispose controllers and focus node to avoid memory leaks
    otpTEController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  /// -------------------------
  /// Verify the OTP entered by the user
  /// -------------------------
  void _verifyEmailHandler() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    final otp = otpTEController.text.trim();

    // Check if OTP length is valid
    if (otp.length != 6) {
      SnackbarService.warning("OTP must be 6 digits");
      return;
    }

    // Determine flow: signup or forgot password
    final isVerified = type == "signup"
        ? await verifyEmailController.verifySignupOtp(email: email, otp: otp)
        : await verifyEmailController.verifyForgotOtp(email: email, otp: otp);

    if (isVerified) {
      // Navigate to the correct screen based on type
      if (type == "signup") {
        Get.offNamed(AppRoutes.bottomNav); // Main app
      } else {
        Get.toNamed(
          AppRoutes.passReset,
          arguments: {"email": email}, // Pass email for password reset
        );
      }
    } else {
      // Show error if verification failed
      SnackbarService.error(
        verifyEmailController.errorMessage !
      );
    }
  }

  /// -------------------------
  /// Resend OTP
  /// -------------------------
  void _resendCodeHandler() async {
    if (!resendController.canResend) return; // Check cooldown

    final isResent = await resendController.resendOtp(email: email);

    if (!isResent) {
      // Show error if resend failed
      SnackbarService.error(
        resendController.errorMessage ?? "Failed to resend OTP",
      );
    } else {
      otpTEController.clear(); // Clear old OTP input
      SnackbarService.success(
        resendController.successMessage ?? "OTP resent successfully",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default OTP input style
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

    // OTP input style when focused
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 20,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      /// -------------------------
                      /// 1. App Logo
                      /// -------------------------
                      Image.asset(Assets.images.logoPng.path, height: 100),
                      const SizedBox(height: 40),

                      /// -------------------------
                      /// 2. Title
                      /// -------------------------
                      Text(
                        "Enter verification code",
                        style: AppTextStyle.displayXs(
                          color: context.colorScheme.onSurface,
                          weight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),

                      /// -------------------------
                      /// 3. Message
                      /// Show different messages based on type
                      /// -------------------------
                      Text(
                        type == "signup"
                            ? message
                            : "We’ve sent raffles verification code to $email. Please enter the code to continue",
                        style: AppTextStyle.textXs(
                          color: context.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),

                      /// -------------------------
                      /// 4. OTP Input Field
                      /// -------------------------
                      Pinput(
                        length: 6,
                        controller: otpTEController,
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

                      /// -------------------------
                      /// 5. Resend OTP Section
                      /// -------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Didn’t receive the code?",
                            style: AppTextStyle.textSm(
                              color: context.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          GetBuilder<ResendOtpController>(
                            builder: (controller) {
                              // Show loader if sending
                              if (controller.isLoading) {
                                return const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              }

                              // Show countdown if cannot resend yet
                              if (!controller.canResend) {
                                return Text(
                                  "Resend in ${controller.secondsRemaining}s",
                                  style: AppTextStyle.textSm(
                                    color: context.colorScheme.onSurfaceVariant,
                                  ),
                                );
                              }

                              // Resend button
                              return TextButton(
                                onPressed: _resendCodeHandler,
                                child: Text(
                                  "Resend Code",
                                  style: AppTextStyle.textSm(
                                    color: Colors.redAccent,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const Spacer(),
                      const SizedBox(height: 40),

                      /// -------------------------
                      /// 6. Verify Button
                      /// -------------------------
                      GetBuilder<VerifyEmailController>(
                        builder: (controller) {
                          return CustomButton(
                            isLoading: controller.isLoading,
                            backgroundColor: context.colorScheme.primary,
                            textColor: context.colorScheme.onPrimary,
                            text: "Verify",
                            onPressed: _verifyEmailHandler,
                          );
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
