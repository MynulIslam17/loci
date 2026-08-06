import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/enums/checkin_status.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/checkin/presentation/controllers/check_in_controller.dart';
import 'package:loci/features/checkin/presentation/controllers/manual_checkin_controller.dart';
import 'package:loci/features/checkin/presentation/widgets/camera_permission_view.dart';
import 'package:loci/features/checkin/presentation/widgets/scanner_overlay.dart';
import 'package:loci/features/event/presentation/controllers/event_details_controller.dart';
import 'package:loci/features/routes/presentation/controllers/route_details_controller.dart';
import 'package:loci/shared/widgets/custom_button.dart';
import 'package:loci/shared/widgets/custom_text_field.dart';

/// Shared check-in screen for any entity (event / route / …). The entity kind
/// is passed via `Get.arguments['type']`. Offers two ways to check in — QR scan
/// and manual code — backed by:
///   UI → CheckIn/ManualCheckIn controller → CommonService → CommonRepository →
///   NetworkCaller.
class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

/// Camera permission as far as this screen cares about it.
enum _CameraPermission { checking, granted, denied, permanentlyDenied }

/// Tabs of the check-in screen.
enum _CheckInTab { scan, manual }

class _CheckInScreenState extends State<CheckInScreen>
    with WidgetsBindingObserver {
  // ── Controllers ───────────────────────────────────────────────────────────
  final CheckInController _checkInController = Get.find<CheckInController>();
  final ManualCheckInController _manualController =
      Get.find<ManualCheckInController>();
  final AuthController _authController = Get.find<AuthController>();

  final MobileScannerController _scanner = MobileScannerController();
  final PageController _pageController = PageController();
  final TextEditingController _manualCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // ── Reactive state ────────────────────────────────────────────────────────
  final Rx<_CheckInTab> _tab = _CheckInTab.scan.obs;
  final Rx<_CameraPermission> _cameraPermission = _CameraPermission.checking.obs;
  final RxBool _isProcessing = false.obs;
  final RxBool _torchOn = false.obs;

  late final String _type;
  String? _openedFromEntityId;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final args = Get.arguments as Map<String, dynamic>?;
    _type = args?['type']?.toString() ?? 'event';
    _openedFromEntityId = args?['entityId']?.toString();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanner.dispose();
    _pageController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-check when returning from system settings (user may have toggled it).
    if (state == AppLifecycleState.resumed &&
        _cameraPermission.value != _CameraPermission.granted) {
      _refreshCameraPermission();
    }
  }

  // ── Permission ────────────────────────────────────────────────────────────
  Future<void> _requestCameraPermission() async {
    _cameraPermission.value = _CameraPermission.checking;
    _applyPermission(await Permission.camera.request());
  }

  Future<void> _refreshCameraPermission() async {
    _applyPermission(await Permission.camera.status);
  }

  void _applyPermission(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      _cameraPermission.value = _CameraPermission.granted;
      if (_tab.value == _CheckInTab.scan) _scanner.start();
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      _cameraPermission.value = _CameraPermission.permanentlyDenied;
    } else {
      _cameraPermission.value = _CameraPermission.denied;
    }
  }

  // ── Tabs ──────────────────────────────────────────────────────────────────
  void _selectTab(_CheckInTab tab) {
    _pageController.animateToPage(
      tab.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    FocusScope.of(context).unfocus();
    _tab.value = _CheckInTab.values[index];
    if (_cameraPermission.value != _CameraPermission.granted) return;
    _tab.value == _CheckInTab.scan ? _scanner.start() : _scanner.stop();
  }

  Future<void> _toggleTorch() async {
    await _scanner.toggleTorch();
    _torchOn.toggle();
  }

  // ── Check-in actions ──────────────────────────────────────────────────────
  Future<void> _onQrDetected(String code) async {
    if (_isProcessing.value || code.isEmpty) return;
    _isProcessing.value = true;
    await _scanner.stop();

    final user = _authController.userModel;
    try {
      // QR always encodes `qrCode` → POST /checkins/scan with qrPayload.
      // Manual codes (e.g. ROUTE-xxx / CHK-xxx) use entity check-in endpoints.
      final success = await _checkInController.doCheckIn(
        checkInCode: code,
        name: user?.name ?? '',
        email: user?.email ?? '',
        avatar: user?.avatar ?? '',
      );
      _finish(
        success: success,
        message: success
            ? _checkInController.successMessage
            : _checkInController.errorMessage,
        entityId: _checkInController.checkedInEntityId,
        activityType: _checkInController.checkedInActivityType,
        onFailureResumeScan: true,
      );
    } finally {
      _isProcessing.value = false;
    }
  }

  Future<void> _onManualCheckIn() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = _authController.userModel;
    final success = await _manualController.doManualCheckIn(
      checkInCode: _manualCodeController.text.trim(),
      type: _type,
      name: user?.name ?? '',
      email: user?.email ?? '',
      avatar: user?.avatar ?? '',
    );
    _finish(
      success: success,
      message: success
          ? _manualController.successMessage
          : _manualController.errorMessage,
      entityId: _manualController.checkedInEntityId,
      activityType: _manualController.checkedInActivityType ?? _type,
    );
  }

  /// Shared success/failure handling for both check-in paths.
  void _finish({
    required bool success,
    required String? message,
    String? entityId,
    String? activityType,
    bool onFailureResumeScan = false,
  }) {
    if (success) {
      final checkedInId = (entityId != null && entityId.isNotEmpty)
          ? entityId
          : _openedFromEntityId;

      _syncLocalCheckInStatus(
        entityId: checkedInId,
        activityType: activityType,
      );
      Get.back(
        result: <String, dynamic>{
          'checkedIn': true,
          'entityId': checkedInId,
          'activityType': activityType ?? _type,
        },
      );
      SnackbarService.success(message ?? 'Check-in successful');
    } else {
      SnackbarService.error(message ?? 'Check-in failed');
      if (onFailureResumeScan &&
          _cameraPermission.value == _CameraPermission.granted) {
        _scanner.start();
      }
    }
  }

  /// Updates check-in UI only for the activity returned by the API.
  /// Checking in route/event B while opened from A must not disable A's button.
  void _syncLocalCheckInStatus({
    String? entityId,
    String? activityType,
  }) {
    if (entityId == null || entityId.isEmpty) return;

    final type = (activityType ?? _type).toLowerCase();

    if (type.contains('event')) {
      if (!Get.isRegistered<EventDetailsController>()) return;
      Get.find<EventDetailsController>().updateCheckInStatus(
        CheckInStatus.checkedIn,
        onlyIfId: entityId,
      );
      return;
    }

    if (type.contains('route')) {
      if (!Get.isRegistered<RouteDetailsController>()) return;
      Get.find<RouteDetailsController>().updateCheckInStatus(
        CheckInStatus.checkedIn,
        onlyIfId: entityId,
      );
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(title: const Text('Check In'), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [_buildScanTab(), _buildManualTab()],
            ),
          ),
          _buildTabBar(),
        ],
      ),
    );
  }

  // ── Scan tab ──────────────────────────────────────────────────────────────
  Widget _buildScanTab() {
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
            onEnterManually: () => _selectTab(_CheckInTab.manual),
          );
        case _CameraPermission.granted:
          return _buildScanner();
      }
    });
  }

  Widget _buildScanner() {
    final colorScheme = context.colorScheme;
    final side = (MediaQuery.of(context).size.width - 72).clamp(220.0, 300.0);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Scan the QR code',
            style: AppTextStyle.textLg(
              color: colorScheme.onSurface,
              weight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Point your camera at the check-in QR code',
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
                  MobileScanner(
                    controller: _scanner,
                    onDetect: (capture) {
                      final code =
                          capture.barcodes.firstOrNull?.rawValue ?? '';
                      _onQrDetected(code);
                    },
                  ),
                  // Dim outside the frame for contrast.
                  Container(color: Colors.black.withValues(alpha: 0.15)),
                  const ScannerOverlay(),
                  Obx(
                    () => _isProcessing.value
                        ? Container(
                            color: Colors.black54,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildTorchButton(),
        ],
      ),
    );
  }

  Widget _buildTorchButton() {
    final colorScheme = context.colorScheme;
    return Obx(() {
      final on = _torchOn.value;
      return OutlinedButton.icon(
        onPressed: _toggleTorch,
        icon: Icon(on ? Icons.flash_on : Icons.flash_off, size: 20),
        label: Text(on ? 'Flash on' : 'Flash off'),
        style: OutlinedButton.styleFrom(
          foregroundColor: on ? colorScheme.primary : colorScheme.onSurface,
          side: BorderSide(
            color: on ? colorScheme.primary : colorScheme.outline,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      );
    });
  }

  // ── Manual tab ────────────────────────────────────────────────────────────
  Widget _buildManualTab() {
    final colorScheme = context.colorScheme;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 32,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 88,
              width: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.keyboard_alt_outlined,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Enter check-in code',
              style: AppTextStyle.textLg(
                color: colorScheme.onSurface,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Type the code shown at the venue if you can\'t scan the QR.',
              textAlign: TextAlign.center,
              style: AppTextStyle.textSm(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 28),
            CustomTextField(
              controller: _manualCodeController,
              title: 'Check-In Code',
              hintText: 'e.g. EVENT-A54D9BA6',
              borderRadius: 12,
              textCapitalization: TextCapitalization.characters,
              prefixIcon: Icon(
                Icons.confirmation_number_outlined,
                size: 20,
                color: colorScheme.onSurfaceVariant,
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                  ? 'Please enter the check-in code'
                  : null,
            ),
            const SizedBox(height: 24),
            Obx(
              () => SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Check in',
                  isLoading: _manualController.isLoading,
                  onPressed:
                      _manualController.isLoading ? null : _onManualCheckIn,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Bottom tab bar ────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    final colorScheme = context.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            _tabItem(_CheckInTab.scan, 'Scan QR', Icons.qr_code_scanner),
            _tabItem(_CheckInTab.manual, 'Manual', Icons.keyboard),
          ],
        ),
      ),
    );
  }

  Widget _tabItem(_CheckInTab tab, String label, IconData icon) {
    final colorScheme = context.colorScheme;
    final selected = _tab.value == tab;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectTab(tab),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyle.textSm(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  weight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
