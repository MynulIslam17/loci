import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/presentation/controllers/resend_otp_controller.dart';
import 'package:loci/features/auth/presentation/controllers/verify_email_controller.dart';
import 'package:loci/features/auth/presentation/widgets/auth_logo_header.dart';
import 'package:loci/routes/app_routes.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final verifyEmailController = Get.find<VerifyEmailController>();
  final resendController = Get.find<ResendOtpController>();

  late final String email;
  late final String message;
  late final String type;

  final otpTEController = TextEditingController();
  final focusNode = FocusNode();
  final isOtpComplete = false.obs;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;

    email = args?["email"] ?? "";
    message = args?["message"] ?? "";
    type = args?["type"] ?? "";

    otpTEController.addListener(_onOtpChanged);
  }

  void _onOtpChanged() {
    isOtpComplete.value = otpTEController.text.trim().length == 6;
  }

  @override
  void dispose() {
    otpTEController.removeListener(_onOtpChanged);
    otpTEController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  void _verifyEmailHandler() async {
    FocusScope.of(context).unfocus();

    final otp = otpTEController.text.trim();
    if (otp.length != 6) {
      SnackbarService.warning("OTP must be 6 digits");
      return;
    }

    TextInput.finishAutofillContext();
    HapticFeedback.mediumImpact();

    final isVerified = type == "signup"
        ? await verifyEmailController.verifySignupOtp(email: email, otp: otp)
        : await verifyEmailController.verifyForgotOtp(email: email, otp: otp);

    if (isVerified) {
      if (type == "signup") {
        Get.offNamed(AppRoutes.bottomNav);
      } else {
        Get.toNamed(
          AppRoutes.passReset,
          arguments: {"email": email},
        );
      }
    } else {
      SnackbarService.error(
        verifyEmailController.errorMessage.value!,
        title: 'Verification failed',
      );
    }
  }

  void _resendCodeHandler() async {
    if (!resendController.canResend.value) return;

    HapticFeedback.lightImpact();
    final isResent = await resendController.resendOtp(email: email);

    if (!isResent) {
      if (!resendController.canResend.value) {
        SnackbarService.info(
          "You can request a new code in ${resendController.secondsRemaining.value}s.",
          title: "Please wait",
        );
      } else {
        SnackbarService.error(
          resendController.errorMessage.value ?? 'Failed to resend OTP',
          title: 'Could not resend code',
        );
      }
    } else {
      otpTEController.clear();
      SnackbarService.success(
        resendController.successMessage.value ?? "OTP resent successfully",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: AppTextStyle.displayXs(
        color: colors.onSurface,
        weight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colors.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: colors.surface,
        border: Border.all(color: colors.primary, width: 2),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        color: colors.surface,
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.5),
        ),
      ),
    );

    return Scaffold(
      backgroundColor: colors.surface,
      appBar: const CustomAppbar(title: ''),
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
                  child: AutofillGroup(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(),
                        AuthLogoHeader(
                          title: "Verification Code",
                          subtitle: "",
                          customSubtitle: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: AppTextStyle.textSm(
                                  color: colors.onSurfaceVariant,
                                ),
                                children: [
                                  const TextSpan(
                                    text: "We sent a 6-digit code to ",
                                  ),
                                  TextSpan(
                                    text: email.isNotEmpty ? email : "your email",
                                    style: AppTextStyle.textSm(
                                      color: colors.onSurface,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: ". Enter it below to continue.",
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // OTP Input
                        Pinput(
                          length: 6,
                          controller: otpTEController,
                          focusNode: focusNode,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          defaultPinTheme: defaultPinTheme,
                          focusedPinTheme: focusedPinTheme,
                          submittedPinTheme: submittedPinTheme,
                          separatorBuilder: (index) => const SizedBox(width: 8),
                          hapticFeedbackType: HapticFeedbackType.lightImpact,
                          onCompleted: (pin) {
                            _verifyEmailHandler();
                          },
                        ),
                        const SizedBox(height: 28),

                        // Resend Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Didn’t receive the code?",
                              style: AppTextStyle.textSm(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            Obx(() {
                              if (resendController.isLoading.value) {
                                return SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colors.primary,
                                  ),
                                );
                              }

                              if (!resendController.canResend.value) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest
                                        .withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    "Resend in ${resendController.secondsRemaining.value}s",
                                    style: AppTextStyle.textXs(
                                      color: colors.onSurfaceVariant,
                                      weight: FontWeight.w600,
                                    ),
                                  ),
                                );
                              }

                              return InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: _resendCodeHandler,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  child: Text(
                                    "Resend Code",
                                    style: AppTextStyle.textSm(
                                      color: colors.primary,
                                      weight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),

                        const Spacer(),
                        const SizedBox(height: 32),

                        // Verify Button
                        Obx(
                          () => CustomButton(
                            isLoading: verifyEmailController.isLoading.value,
                            backgroundColor: colors.primary,
                            textColor: colors.onPrimary,
                            text: "Verify & Continue",
                            onPressed: isOtpComplete.value
                                ? _verifyEmailHandler
                                : null,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
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
