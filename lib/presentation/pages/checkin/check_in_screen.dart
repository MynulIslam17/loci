import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/enums/checkin_status.dart';
import 'package:loci/core/utils/show_snackbar.dart';
import 'package:loci/presentation/controllers/auth/auth_controller.dart';
import 'package:loci/presentation/controllers/common/check_in_controller.dart';
import 'package:loci/presentation/controllers/event/event_details_controller.dart';
import 'package:loci/presentation/controllers/routes/route_details_controller.dart';
import 'package:loci/presentation/pages/checkin/scanner_animation.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/theme_extention.dart';
import '../../controllers/common/manual_checkin.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {

  // -------------------------
  // Controllers
  // -------------------------
  final checkInController = Get.find<CheckInController>();
  final manualCheckInController = Get.find<ManualCheckInController>();
  final authController = Get.find<AuthController>();

  final MobileScannerController scannerController = MobileScannerController();
  final PageController _pageController = PageController();
  final TextEditingController _manualCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // -------------------------
  // State
  // -------------------------
  int _currentIndex = 0;
  bool _isProcessing = false;
  late final String _type;

  // -------------------------
  // Lifecycle
  // -------------------------

   @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final args = Get.arguments as Map<String, dynamic>?;
    _type = args?['type'] ?? 'event';

  }


  @override
  void dispose() {
    scannerController.dispose();
    _pageController.dispose();
    _manualCodeController.dispose();
    super.dispose();
  }

  // -------------------------
  // Page Change
  // -------------------------
  void _onPageChanged(int index) {
    FocusScope.of(context).unfocus();
    setState(() => _currentIndex = index);
    index == 1 ? scannerController.stop() : scannerController.start();
  }

  // -------------------------
  // QR Check-In
  // -------------------------
  Future<void> _checkInHandler(String code) async {
    if (_isProcessing || code.isEmpty) return;

    setState(() => _isProcessing = true);
    scannerController.stop();

    final user = authController.userModel;

    try {
      final success = await checkInController.doCheckIn(
        checkInCode: code,
        name: user?.name ?? "",
        email: user?.email ?? "",
        avatar: user?.avatar ?? "",
      );

      if (success) {

        // update locally the check in status (event/route)
        if (_type=="event" && Get.isRegistered<EventDetailsController>()) {
          Get.find<EventDetailsController>()
              .updateCheckInStatus(CheckInStatus.checkedIn);
        }else if(_type=="route" && Get.isRegistered<RouteDetailsController>()){
         Get.find<RouteDetailsController>().updateCheckInStatus(CheckInStatus.checkedIn);
        }


        Get.back();


        SnackbarService.success(
          checkInController.successMessage ?? "Check-in successful",
        );
      } else {
        Get.back();
        SnackbarService.error(
          checkInController.errorMessage ?? "Check-in failed",
        );
        scannerController.start();
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  // -------------------------
  // Manual Check-In
  // -------------------------
  Future<void> _onManualCheckIn() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    final code = _manualCodeController.text.trim();
    final user = authController.userModel;

    final success = await manualCheckInController.doManualCheckIn(
      checkInCode: code,
       type: _type,
      name: user?.name ?? "",
      email: user?.email ?? "",
      avatar: user?.avatar ?? "",
    );

    if (success) {

      // update locally the check in status (event/route)

      if (_type=="event" && Get.isRegistered<EventDetailsController>()) {
        Get.find<EventDetailsController>()
            .updateCheckInStatus(CheckInStatus.checkedIn);
      }else if(_type=="route" && Get.isRegistered<RouteDetailsController>()){
        Get.find<RouteDetailsController>().updateCheckInStatus(CheckInStatus.checkedIn);
      }


      Get.back();

      SnackbarService.success(
        manualCheckInController.successMessage ?? "Check-in successful",
      );
    } else {
      SnackbarService.error(
        manualCheckInController.errorMessage ?? "Check-in failed",
      );
    }
  }
  // -------------------------
  // UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Check In"), centerTitle: true),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildScannerTab(),
                _buildManualTab(),
              ],
            ),
          ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  // -------------------------
  // Scanner UI
  // -------------------------
  Widget _buildScannerTab() {
    return GetBuilder<CheckInController>(
      builder: (controller) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Align QR Code within the frame",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 280,
              height: 280,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: scannerController,
                      onDetect: (capture) {
                        final code =
                            capture.barcodes.firstOrNull?.rawValue ?? '';
                        if (code.isNotEmpty && !_isProcessing) {
                          _checkInHandler(code);
                        }
                      },
                    ),
                    const ScannerAnimation(),

                    if (controller.isLoading)
                      Container(
                        color: Colors.black54,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // -------------------------
  // Manual UI
  // -------------------------
  Widget _buildManualTab() {
    final color = Theme.of(context).colorScheme;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            left: 30,
            right: 30,
            top: 30,
            bottom: MediaQuery.of(context).viewInsets.bottom + 30,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_note, size: 80, color: color.primary),
              const SizedBox(height: 20),
        
              CustomTextField(
                controller: _manualCodeController,
                hintText: "Enter Check-In code",
                title: "Check-In Code",
                borderRadius: 12,
                validator: (value) =>
                value == null || value.isEmpty
                    ? "Please enter code"
                    : null,
              ),
        
              const SizedBox(height: 20),
        
              GetBuilder<ManualCheckInController>(
                builder: (controller) {
                  return CustomButton(
                    text: "Check-In Manually",
                    isLoading: controller.isLoading,
                    onPressed:
                    controller.isLoading ? null : _onManualCheckIn,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------
  // Bottom Nav
  // -------------------------
  Widget _buildBottomNav() {
    final color = context.colorScheme;

    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: color.surfaceContainerHigh,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center, // ✅ FIX HERE
        children: [
          _navButton("Scan QR", Icons.qr_code_scanner, 0),
          _navButton("Manual", Icons.keyboard, 1),
        ],
      ),
    );
  }

  Widget _navButton(String label, IconData icon, int index) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
          Text(label),
        ],
      ),
    );
  }
}