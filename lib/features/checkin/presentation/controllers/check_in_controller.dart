import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:loci/core/enums/checkin_status.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/features/auth/data/models/user_model.dart';
import 'package:loci/features/auth/presentation/controllers/auth_controller.dart';
import 'package:loci/features/common/domain/services/common_service.dart';
import 'package:loci/features/event/presentation/controllers/event_details_controller.dart';
import 'package:loci/features/routes/presentation/controllers/route_details_controller.dart';

enum CameraPermissionState { checking, granted, denied, permanentlyDenied }
enum CheckInTab { scan, manual }

/// Presentation Controller for the Check-In feature.
/// Handles UI state, camera permissions, scanner lifecycle, and API calls.
class CheckInController extends GetxController with WidgetsBindingObserver {
  CheckInController(this._service);

  final CommonService _service;

  // ── Controllers & Form ───────────────────────────────────────────────────
  final MobileScannerController scannerController = MobileScannerController();
  final PageController pageController = PageController();
  final TextEditingController manualCodeController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // ── Reactive State ────────────────────────────────────────────────────────
  final activeTab = CheckInTab.scan.obs;
  final cameraPermission = CameraPermissionState.checking.obs;
  final isProcessing = false.obs;
  final isManualLoading = false.obs;
  final torchOn = false.obs;

  final Rxn<String> _errorMessage = Rxn<String>();
  final Rxn<String> _successMessage = Rxn<String>();
  final Rxn<String> _checkedInEntityId = Rxn<String>();
  final Rxn<String> _checkedInActivityType = Rxn<String>();

  String? get errorMessage => _errorMessage.value;
  String? get successMessage => _successMessage.value;
  String? get checkedInEntityId => _checkedInEntityId.value;
  String? get checkedInActivityType => _checkedInActivityType.value;

  late String _type;
  String? _openedFromEntityId;

  String get type => _type;

  String get manualCodeHint {
    final typeUpper = _type.trim().toUpperCase();
    if (typeUpper == 'ROUTE') return 'e.g. ROUTE-A54D9BA6';
    if (typeUpper == 'EVENT') return 'e.g. EVENT-A54D9BA6';
    return 'e.g. ${typeUpper.isNotEmpty ? typeUpper : 'CHK'}-A54D9BA6';
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    final args = Get.arguments as Map<String, dynamic>?;
    _type = args?['type']?.toString() ?? 'event';
    _openedFromEntityId = args?['entityId']?.toString();

    requestCameraPermission();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    scannerController.dispose();
    pageController.dispose();
    manualCodeController.dispose();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        cameraPermission.value != CameraPermissionState.granted) {
      refreshCameraPermission();
    }
  }

  // ── Permission Management ─────────────────────────────────────────────────
  Future<void> requestCameraPermission() async {
    cameraPermission.value = CameraPermissionState.checking;
    _applyPermission(await Permission.camera.request());
  }

  Future<void> refreshCameraPermission() async {
    _applyPermission(await Permission.camera.status);
  }

  void _applyPermission(PermissionStatus status) {
    if (status.isGranted || status.isLimited) {
      cameraPermission.value = CameraPermissionState.granted;
      if (activeTab.value == CheckInTab.scan) {
        scannerController.start();
      }
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      cameraPermission.value = CameraPermissionState.permanentlyDenied;
    } else {
      cameraPermission.value = CameraPermissionState.denied;
    }
  }

  // ── Tab & UI Controls ─────────────────────────────────────────────────────
  void selectTab(CheckInTab tab) {
    pageController.animateToPage(
      tab.index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    activeTab.value = CheckInTab.values[index];
    if (cameraPermission.value != CameraPermissionState.granted) return;
    activeTab.value == CheckInTab.scan
        ? scannerController.start()
        : scannerController.stop();
  }

  Future<void> toggleTorch() async {
    await scannerController.toggleTorch();
    torchOn.toggle();
  }

  // ── QR Scan Check-In ──────────────────────────────────────────────────────
  Future<void> onQrDetected(String code) async {
    if (isProcessing.value || code.trim().isEmpty) return;
    isProcessing.value = true;
    await scannerController.stop();

    final user = _getAuthUser();
    try {
      final success = await _doCheckIn(
        checkInCode: code.trim(),
        name: user?.name,
        email: user?.email,
        avatar: user?.avatar,
      );

      _handleFinish(
        success: success,
        message: success ? successMessage : errorMessage,
        entityId: checkedInEntityId,
        activityType: checkedInActivityType,
        onFailureResumeScan: true,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<bool> _doCheckIn({
    required String checkInCode,
    String? name,
    String? email,
    String? avatar,
  }) async {
    try {
      _errorMessage.value = null;
      _successMessage.value = null;
      _checkedInEntityId.value = null;
      _checkedInActivityType.value = null;

      final body = <String, dynamic>{'qrPayload': checkInCode};
      if (name != null || email != null || avatar != null) {
        body['leadData'] = {
          'name': ?name,
          'email': ?email,
          'avatar': ?avatar,
        };
      }

      final res = await _service.checkIn(body);
      _applyResponse(res);
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  // ── Manual Code Check-In ──────────────────────────────────────────────────
  Future<void> onManualCheckIn() async {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return;

    final user = _getAuthUser();
    final code = manualCodeController.text.trim();

    isManualLoading.value = true;
    try {
      final success = await _doManualCheckIn(
        checkInCode: code,
        type: _type,
        name: user?.name,
        email: user?.email,
        avatar: user?.avatar,
      );

      _handleFinish(
        success: success,
        message: success ? successMessage : errorMessage,
        entityId: checkedInEntityId,
        activityType: checkedInActivityType ?? _type,
      );
    } finally {
      isManualLoading.value = false;
    }
  }

  Future<bool> _doManualCheckIn({
    required String checkInCode,
    required String type,
    String? name,
    String? email,
    String? avatar,
  }) async {
    try {
      _errorMessage.value = null;
      _successMessage.value = null;
      _checkedInEntityId.value = null;
      _checkedInActivityType.value = null;

      final body = <String, dynamic>{'checkInCode': checkInCode};
      if (name != null || email != null || avatar != null) {
        body['leadData'] = {
          'name': ?name,
          'email': ?email,
          'avatar': ?avatar,
        };
      }

      final res = await _service.manualCheckIn(type: type, body: body);
      _applyResponse(res, fallbackType: type);
      return true;
    } catch (e) {
      _errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  // ── Response & Navigation Helpers ─────────────────────────────────────────
  UserModel? _getAuthUser() {
    if (Get.isRegistered<AuthController>()) {
      return Get.find<AuthController>().userModel;
    }
    return null;
  }

  void _applyResponse(
    Map<String, dynamic> res, {
    String? fallbackType,
  }) {
    _successMessage.value =
        res['message']?.toString() ?? 'Check-in successful';

    final data = res['data'];
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final id = (map['entityId'] ?? map['_id'] ?? map['id'])?.toString();
      if (id != null && id.isNotEmpty) {
        _checkedInEntityId.value = id;
      }
      final resType = (map['entityType'] ?? map['activityType'])?.toString();
      _checkedInActivityType.value = (resType != null && resType.isNotEmpty)
          ? resType
          : fallbackType;
    } else if (fallbackType != null) {
      _checkedInActivityType.value = fallbackType;
    }
  }

  void _handleFinish({
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
          cameraPermission.value == CameraPermissionState.granted) {
        scannerController.start();
      }
    }
  }

  void _syncLocalCheckInStatus({
    String? entityId,
    String? activityType,
  }) {
    if (entityId == null || entityId.isEmpty) return;

    final activity = (activityType ?? _type).toLowerCase();

    if (activity.contains('event')) {
      if (Get.isRegistered<EventDetailsController>()) {
        Get.find<EventDetailsController>().updateCheckInStatus(
          CheckInStatus.checkedIn,
          onlyIfId: entityId,
        );
      }
      return;
    }

    if (activity.contains('route')) {
      if (Get.isRegistered<RouteDetailsController>()) {
        Get.find<RouteDetailsController>().updateCheckInStatus(
          CheckInStatus.checkedIn,
          onlyIfId: entityId,
        );
      }
    }
  }
}
