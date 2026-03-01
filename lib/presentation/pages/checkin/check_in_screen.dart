import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:vibration/vibration.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  String? scannedCode;
  late final MobileScannerController scannerController;
  Color borderColor = const Color(0xFF66B9AD);
  //-- state for switching flash(on/off)
  bool isFlashOn = false;
  //--state for switching tabs
  bool isScanTab = true;

  @override
  void initState() {
    super.initState();
    scannerController = MobileScannerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
        ),
        actions: [

          if (isScanTab)
            IconButton(
              onPressed: () async {
                isFlashOn = !isFlashOn;
                await scannerController.toggleTorch();
                setState(() {});
              },
              icon: Icon(isFlashOn ? Icons.flash_off : Icons.flash_on),
            ),
        ],
      ),
      body: Column(
        children: [
          //--if scan tab selected show scanner view else show my qr code view
          Expanded(
            child: isScanTab ? _buildScannerView() : _buildMyQrView(),
          ),

          // The Tab Switcher at the bottom
          _buildTabSwitcher(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  //----- scanner logic and design
  Widget _buildScannerView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: MobileScanner(
                    controller: scannerController,
                    onDetect: (capture) async {
                      if (capture.barcodes.isNotEmpty && scannedCode == null) {
                        final code = capture.barcodes.first.rawValue;
                        scannerController.stop();
                        setState(() {
                          scannedCode = code;
                          borderColor = Colors.green;
                        });
                        _handleCheckIn(code);
                        HapticFeedback.heavyImpact();
                        Vibration.vibrate(duration: 500);
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  children: [
                    Positioned(top: 0, left: 0, child: _corner(topLeft: true, color: borderColor)),
                    Positioned(top: 0, right: 0, child: _corner(topRight: true, color: borderColor)),
                    Positioned(bottom: 0, left: 0, child: _corner(bottomLeft: true, color: borderColor)),
                    Positioned(bottom: 0, right: 0, child: _corner(bottomRight: true, color: borderColor)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        Text(
          scannedCode ?? 'Scan a QR Code to check or connect with others',
          style: AppTextStyle.textSm(),
        ),
      ],
    );
  }

  //-----The "My QR Code" design
  Widget _buildMyQrView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 2,
            color: context.colorScheme.surfaceContainer,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 12),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=albert'),
                  ),
                  const SizedBox(height: 12),
                  Text("Albert Flamingo", style: AppTextStyle.textMd(weight: FontWeight.w600,color: context.colorScheme.onSurface)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: context.colorScheme.onSurface),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("ID: 1313434", style: AppTextStyle.textXs()),
                  ),
                  const SizedBox(height: 20),
                  //----- qrcode
                  Image.network('https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=1313434', height: 160),

                  const SizedBox(height: 20),
                  Align(
                      alignment: Alignment.topLeft,
                      child: Text("Use this code to", style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.group_outlined, size: 18, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text("Connect with fellow business partner", style: AppTextStyle.textXs(color: context.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
          CustomButton(
            width: 210,
            height: 48,
            backgroundColor: context.colorScheme.primary,
            textColor: context.colorScheme.onPrimary,
            onPressed: (){},
            child: Row(
              children: [
                Icon(Icons.qr_code_scanner_outlined, color: context.colorScheme.onPrimary),
                const SizedBox(width: 8),
                Text("Manual Connection", style: AppTextStyle.textSm(color: context.colorScheme.onPrimary)),
              ],
            ),

          )
        ],
      ),
    );
  }

  // The custom toggle switch component
  Widget _buildTabSwitcher() {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tabButton("Scan", isScanTab, () => setState(() => isScanTab = true),),
          ),
          Expanded(
            child: _tabButton("My QR Code", !isScanTab, () => setState(() => isScanTab = false)),
          ),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.black : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // Your original corner widget
  Widget _corner({bool topLeft = false, bool topRight = false, bool bottomLeft = false, bool bottomRight = false, required Color color}) {
    const double size = 30;
    const double thickness = 4;
    return SizedBox(
      width: size, height: size,
      child: Stack(
        children: [
          Positioned(
            top: topLeft || topRight ? 0 : null,
            bottom: bottomLeft || bottomRight ? 0 : null,
            left: topLeft || bottomLeft ? 0 : null,
            right: topRight || bottomRight ? 0 : null,
            child: Container(width: size, height: thickness, color: color),
          ),
          Positioned(
            top: topLeft || topRight ? 0 : null,
            bottom: bottomLeft || bottomRight ? 0 : null,
            left: topLeft || bottomLeft ? 0 : null,
            right: topRight || bottomRight ? 0 : null,
            child: Container(width: thickness, height: size, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCheckIn(String? code) async {
    if (code == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Check-In Successful"),
        content: Text("Code: $code"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}