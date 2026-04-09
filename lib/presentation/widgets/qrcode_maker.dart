import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import '../../core/utils/show_snackbar.dart';

class CustomQrCode extends StatelessWidget {
  final String data;
  final double size;

  const CustomQrCode({super.key, required this.data, this.size = 200});

  @override
  Widget build(BuildContext context) {
    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      backgroundColor: Colors.white,
      errorStateBuilder: (context, error) => SizedBox(
        width: size,
        height: size,
        child: const Center(child: Text("Failed to generate QR")),
      ),
    );
  }

  /// Shows the QR code inside a modal bottom sheet with a download button
  static void show(
      BuildContext context, {
        required String data,
        required String title,
        String? subtitle,
      }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _QrBottomSheet(
        data: data,
        title: title,
        subtitle: subtitle,
      ),
    );
  }

  /// Captures the QR widget as a PNG image and saves it to the device gallery
  static Future<void> download(
      String data, {
        String? title,
        String? subtitle,
      }) async {
    final screenshotController = ScreenshotController();

    // Render the QR widget (with optional title/subtitle) into image bytes
    final image = await screenshotController.captureFromWidget(
      Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null) ...[
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
              ],
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
              QrImageView(
                data: data,
                version: QrVersions.auto,
                size: 300,
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );

    // Request gallery access if not already granted
    final hasAccess = await Gal.hasAccess();
    if (!hasAccess) await Gal.requestAccess();

    // Save image bytes to the device gallery
    await Gal.putImageBytes(image);
  }
}

// -------------------------
// Internal Bottom Sheet
// -------------------------
class _QrBottomSheet extends StatefulWidget {
  final String data;
  final String title;
  final String? subtitle;

  const _QrBottomSheet({
    required this.data,
    required this.title,
    this.subtitle,
  });

  @override
  State<_QrBottomSheet> createState() => _QrBottomSheetState();
}

class _QrBottomSheetState extends State<_QrBottomSheet> {
  bool _isDownloading = false;

  Future<void> _onDownload() async {
    setState(() => _isDownloading = true);

    try {
      await CustomQrCode.download(
        widget.data,
        title: widget.title,
        subtitle: widget.subtitle,
      );
      SnackbarService.success("QR Code saved to gallery");
    } catch (e) {
      SnackbarService.error("Failed to save QR Code");
    } finally {
      if (mounted) setState(() => _isDownloading = false);
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Bottom sheet drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            widget.title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),

          // Optional subtitle
          if (widget.subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              widget.subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),

          // QR Code preview
          CustomQrCode(data: widget.data, size: 220),
          const SizedBox(height: 32),

          // Download button with loading state
          CustomButton(
            text: "Download",
            isLoading: _isDownloading,
            onPressed: _isDownloading ? null : _onDownload,
          ),
        ],
      ),
    );
  }
}