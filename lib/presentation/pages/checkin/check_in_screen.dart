import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:loci/core/constants/app_text_style.dart';
import 'package:loci/core/theme/theme_extention.dart';
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
  Color borderColor = Colors.red;

  bool isFlashOn = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scannerController = MobileScannerController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.back();
          },

          icon: Icon(Icons.close),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              // toggle flash
              isFlashOn = !isFlashOn;

              await scannerController.toggleTorch();
              setState(() {});
            },
            icon: Icon(isFlashOn ?Icons.flash_on  : Icons.flash_off),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Stack(
              children: [
                // Scanner
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 300,
                    height: 300,
                    child: MobileScanner(
                      controller: scannerController,
                      onDetect: (capture) async {
                        if (capture.barcodes.isNotEmpty &&
                            scannedCode == null) {
                          final code = capture.barcodes.first.rawValue;

                          //--stop scanning
                          scannerController.stop();
                          setState(() {
                            scannedCode = code;
                            borderColor = Colors.green;
                          });
                          // ---handle success here
                          _handleCheckIn(code);

                          // --- vibration(2 way if one fails vibration)
                          HapticFeedback.heavyImpact(); // built-in vibration
                          Vibration.vibrate(
                            duration: 500,
                          ); // optional, async fire-and-forget
                        }
                      },
                    ),
                  ),
                ),

                // Corner borders
                SizedBox(
                  width: 300,
                  height: 300,
                  child: Stack(
                    children: [
                      // Top-left
                      Positioned(
                        top: 0,
                        left: 0,
                        child: _corner(topLeft: true, color: borderColor),
                      ),
                      // Top-right
                      Positioned(
                        top: 0,
                        right: 0,
                        child: _corner(topRight: true, color: borderColor),
                      ),
                      // Bottom-left
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: _corner(bottomLeft: true, color: borderColor),
                      ),
                      // Bottom-right
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: _corner(bottomRight: true, color: borderColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          if (scannedCode != null)
            Text(
              'Scanned: $scannedCode',
              style: const TextStyle(fontSize: 18, color: Colors.white),
            )
          else
            Text(
              'Scan a QR Code to check or connect with others',
              style: AppTextStyle.textSm(),
            ),
        ],
      ),
    );
  }

  Widget _corner({
    bool topLeft = false,
    bool topRight = false,
    bool bottomLeft = false,
    bool bottomRight = false,
    required Color color,
  }) {
    const double size = 30;
    const double thickness = 4;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Horizontal line
          Positioned(
            top: topLeft || topRight ? 0 : null,
            bottom: bottomLeft || bottomRight ? 0 : null,
            left: topLeft || bottomLeft ? 0 : null,
            right: topRight || bottomRight ? 0 : null,
            child: Container(width: size, height: thickness, color: color),
          ),
          // Vertical line
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

    // Example: show success dialog
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Check-In Successful"),
        content: Text("Code: $code"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back(); // close screen
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
