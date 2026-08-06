import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gal/gal.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../../core/utils/show_snackbar.dart';

class CustomQrCode extends StatelessWidget {
  final String data;
  final double size;

  const CustomQrCode({
    super.key,
    required this.data,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
    );
  }

  /// ===============================
  /// SHOW BOTTOM SHEET
  /// ===============================
  static void show(
      BuildContext context, {
        required String data,
        required String title,
        String? subtitle,
        String? appName,
      }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _QrBottomSheet(
        data: data,
        title: title,
        subtitle: subtitle,
        appName: appName,
      ),
    );
  }

  /// ===============================
  /// DOWNLOAD IMAGE (FINAL DESIGN)
  /// ===============================
  static Future<void> download(
    String data, {
    BuildContext? context,
    String? title,
    String? subtitle,
    String? appName,
  }) async {
    final captureContext = context ?? Get.context;
    if (captureContext == null) {
      throw Exception('Unable to save QR code right now');
    }

    const logoAsset = 'assets/images/logo.png';
    await precacheImage(const AssetImage(logoAsset), captureContext);
    if (!captureContext.mounted) {
      throw Exception('Unable to save QR code right now');
    }

    final screenshotController = ScreenshotController();
    final image = await screenshotController.captureFromWidget(
      _downloadCard(
        data: data,
        title: title,
        subtitle: subtitle,
        appName: appName,
        logoAsset: logoAsset,
      ),
      context: captureContext,
      targetSize: const Size(380, 520),
      pixelRatio: 3,
      delay: const Duration(milliseconds: 300),
    );

    if (image.isEmpty) {
      throw Exception('Could not generate QR image');
    }

    var hasAccess = await Gal.hasAccess();
    if (!hasAccess) {
      hasAccess = await Gal.requestAccess();
    }
    if (!hasAccess) {
      throw Exception('Gallery access denied');
    }

    await Gal.putImageBytes(image, name: 'loci_qr_code');
  }

  static Widget _downloadCard({
    required String data,
    required String logoAsset,
    String? title,
    String? subtitle,
    String? appName,
  }) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: QrImageView(
                  data: data,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              const Divider(color: Colors.black12),
              const SizedBox(height: 12),
              Text(
                title ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle ?? 'Scan this QR to check-in to this activity',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.black12),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    logoAsset,
                    height: 28,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    appName ?? 'Loci',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// BOTTOM SHEET
/// ===============================
class _QrBottomSheet extends StatefulWidget {
  final String data;
  final String title;
  final String? subtitle;
  final String? appName;

  const _QrBottomSheet({
    required this.data,
    required this.title,
    this.subtitle,
    this.appName,
  });

  @override
  State<_QrBottomSheet> createState() => _QrBottomSheetState();
}

class _QrBottomSheetState extends State<_QrBottomSheet> {
  final RxBool _isDownloading = false.obs;

  Future<void> _onDownload() async {
    _isDownloading.value = true;

    try {
      await CustomQrCode.download(
        widget.data,
        context: context,
        title: widget.title,
        subtitle: widget.subtitle,
        appName: widget.appName,
      );

      SnackbarService.success('QR Code saved to gallery');

      // Close the sheet automatically once the QR is saved.
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } catch (e) {
      SnackbarService.error(
        e.toString().replaceFirst('Exception: ', 'Failed to save QR Code: '),
      );
      _isDownloading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 20),

          /// title
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),

          if (widget.subtitle != null) ...[
            const SizedBox(height: 6),
            Text(
              widget.subtitle!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],

          const SizedBox(height: 20),

          /// QR preview
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomQrCode(
              data: widget.data,
              size: 200,
            ),
          ),

          const SizedBox(height: 24),

          /// download button
          Obx(
            () => CustomButton(
              text: "Download",
              isLoading: _isDownloading.value,
              onPressed: _isDownloading.value ? null : _onDownload,
            ),
          ),
        ],
      ),
    );
  }
}