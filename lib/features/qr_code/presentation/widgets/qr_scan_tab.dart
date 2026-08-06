import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/checkin/presentation/widgets/camera_permission_view.dart';
import 'package:loci/features/checkin/presentation/widgets/scanner_overlay.dart';
import 'package:loci/features/qr_code/presentation/controllers/my_qr_code_controller.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

enum _CameraPermission { checking, granted, denied, permanentlyDenied }

/// Starts the camera after mount and stops on dispose — avoids racing `start()`.
class _QrCameraPreview extends StatefulWidget {
  const _QrCameraPreview({
    required this.controller,
    required this.onDetect,
  });

  final MobileScannerController controller;
  final void Function(String code) onDetect;

  @override
  State<_QrCameraPreview> createState() => _QrCameraPreviewState();
}

class _QrCameraPreviewState extends State<_QrCameraPreview> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCamera());
  }

  Future<void> _startCamera() async {
    if (!mounted || widget.controller.value.isRunning) return;

    try {
      await widget.controller.start();
    } on MobileScannerException catch (e) {
      if (e.errorCode != MobileScannerErrorCode.controllerInitializing) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (!mounted || widget.controller.value.isRunning) return;
      await widget.controller.start();
    }
  }

  Future<void> _stopCamera() async {
    try {
      await widget.controller.stop();
    } on MobileScannerException {
      // Already stopped.
    }
  }

  @override
  void dispose() {
    _stopCamera();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MobileScanner(
      controller: widget.controller,
      onDetect: (capture) {
        final code = capture.barcodes.firstOrNull?.rawValue ?? '';
        widget.onDetect(code);
      },
    );
  }
}

class QrScanTab extends StatefulWidget {
  const QrScanTab({
    super.key,
    required this.controller,
    required this.scannerController,
    required this.isActive,
  });

  final MyQrCodeController controller;
  final MobileScannerController scannerController;
  final bool isActive;

  @override
  State<QrScanTab> createState() => _QrScanTabState();
}

class _QrScanTabState extends State<QrScanTab> with WidgetsBindingObserver {
  final Rx<_CameraPermission> _cameraPermission = _CameraPermission.checking.obs;
  final RxBool _torchOn = false.obs;
  final RxBool _isProcessingScan = false.obs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!widget.isActive) return;
    if (state == AppLifecycleState.resumed) {
      _refreshCameraPermission();
    }
  }

  Future<void> _requestCameraPermission() async {
    _cameraPermission.value = _CameraPermission.checking;
    var status = await Permission.camera.status;
    if (!status.isGranted &&
        !status.isPermanentlyDenied &&
        !status.isRestricted) {
      status = await Permission.camera.request();
    }
    _applyPermission(status);
  }

  Future<void> _refreshCameraPermission() async {
    _applyPermission(await Permission.camera.status);
  }

  void _applyPermission(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      _cameraPermission.value = _CameraPermission.granted;
      return;
    }
    if (status.isPermanentlyDenied || status.isRestricted) {
      _cameraPermission.value = _CameraPermission.permanentlyDenied;
      return;
    }
    _cameraPermission.value = _CameraPermission.denied;
  }

  Future<void> _restartCamera() async {
    if (!mounted || !widget.isActive) return;
    try {
      if (!widget.scannerController.value.isRunning) {
        await widget.scannerController.start();
      }
    } on MobileScannerException catch (e) {
      if (e.errorCode != MobileScannerErrorCode.controllerInitializing) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 350));
      if (mounted && widget.isActive && !widget.scannerController.value.isRunning) {
        await widget.scannerController.start();
      }
    }
  }

  Future<void> _onQrDetected(String code) async {
    if (code.isEmpty ||
        _isProcessingScan.value ||
        widget.controller.isConnecting ||
        !widget.isActive) {
      return;
    }

    _isProcessingScan.value = true;
    try {
      await widget.scannerController.stop();
      final result = await widget.controller.connectViaQr(code);
      if (!mounted || !widget.isActive) return;

      if (result != null && result.isAlreadyConnected) {
        await Future<void>.delayed(const Duration(milliseconds: 900));
        await _restartCamera();
      } else if (result == null) {
        await _restartCamera();
      }
    } on MobileScannerException {
      // Ignore stop/start races while processing a scan.
    } finally {
      _isProcessingScan.value = false;
    }
  }

  Future<void> _toggleTorch() async {
    await widget.scannerController.toggleTorch();
    _torchOn.value = !_torchOn.value;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (_cameraPermission.value) {
        case _CameraPermission.checking:
          return const Center(child: CircularProgressIndicator());
        case _CameraPermission.denied:
        case _CameraPermission.permanentlyDenied:
          return CameraPermissionView(
            permanentlyDenied:
                _cameraPermission.value == _CameraPermission.permanentlyDenied,
            onAllow: _requestCameraPermission,
            onOpenSettings: openAppSettings,
            title: 'Camera access needed',
            description: _cameraPermission.value ==
                    _CameraPermission.permanentlyDenied
                ? 'Enable camera access in Settings to scan connection QR codes.'
                : 'We need your camera to scan another member\'s QR code.',
          );
        case _CameraPermission.granted:
          return _buildScanner(context);
      }
    });
  }

  Widget _buildScanner(BuildContext context) {
    final colorScheme = context.colorScheme;
    final side = (MediaQuery.sizeOf(context).width - 72).clamp(220.0, 300.0);
    final showCamera = widget.isActive;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Scan to connect',
            style: AppTextStyle.textLg(
              color: colorScheme.onSurface,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Point your camera at another member\'s QR code',
            textAlign: TextAlign.center,
            style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: side,
            height: side,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (showCamera)
                    _QrCameraPreview(
                      controller: widget.scannerController,
                      onDetect: _onQrDetected,
                    )
                  else
                    ColoredBox(color: colorScheme.surfaceContainerHighest),
                  if (showCamera)
                    Container(color: Colors.black.withValues(alpha: 0.15)),
                  if (showCamera) const ScannerOverlay(),
                  Obx(
                    () {
                      final busy =
                          widget.controller.isConnecting ||
                          _isProcessingScan.value;
                      if (!busy) return const SizedBox.shrink();
                      return Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (showCamera)
            Obx(
              () => TextButton.icon(
                onPressed: _toggleTorch,
                icon: Icon(
                  _torchOn.value ? Icons.flashlight_on : Icons.flashlight_off,
                  size: 20,
                ),
                label: Text(
                  _torchOn.value ? 'Turn off flashlight' : 'Turn on flashlight',
                  style: AppTextStyle.textSm(color: colorScheme.primary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
