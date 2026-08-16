import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/chat/presentation/widgets/chat_avatar.dart';
import 'package:loci/features/qr_code/presentation/controllers/my_qr_code_controller.dart';
import 'package:loci/features/qr_code/presentation/widgets/my_qr_code_shimmer.dart';
import 'package:loci/shared/widgets/adaptive_refresh.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/empty_state.dart';
import 'package:loci/shared/widgets/error_state.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQrDisplayTab extends StatelessWidget {
  const MyQrDisplayTab({super.key, required this.controller});

  final MyQrCodeController controller;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final auth = Get.find<AuthController>();

    return AdaptiveRefresh(
      onRefresh: controller.refreshMyQr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
              child: Obx(() {
                if (controller.showInitialShimmer) {
                  return const Center(child: MyQrCodeShimmer());
                }

                if (controller.errorMessage != null &&
                    controller.qrCodeValue == null) {
                  return Center(
                    child: ErrorStateWidget(
                      message: controller.errorMessage!,
                      onRetry: controller.refreshMyQr,
                    ),
                  );
                }

                final code = controller.qrCodeValue;
                if (code == null || code.isEmpty) {
                  return const Center(
                    child: EmptyState(
                      icon: Icons.qr_code_2_outlined,
                      title: 'No QR code yet',
                      subtitle: 'Pull to refresh or try again later.',
                    ),
                  );
                }

                return Column(
                  children: [
                    ChatAvatar(
                      name: auth.userModel?.name ?? '',
                      avatarUrl: auth.userModel?.avatar,
                      size: 72,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      auth.userModel?.name ?? 'Your profile',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.textLg(
                        color: colorScheme.onSurface,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Share this code so others can connect with you',
                      textAlign: TextAlign.center,
                      style: AppTextStyle.textSm(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.45,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.shadow.withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: code,
                        version: QrVersions.auto,
                        size: 228,
                        backgroundColor: Colors.white,
                        eyeStyle: QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: colorScheme.onSurface,
                        ),
                        dataModuleStyle: QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.square,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        text: 'Save to gallery',
                        isLoading: controller.isSavingGallery,
                        onPressed: controller.isSavingGallery
                            ? null
                            : () => controller.saveQrToGallery(
                                  context,
                                  code,
                                  auth.userModel?.name,
                                ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          );
        },
      ),
    );
  }
}
