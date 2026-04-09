import 'package:flutter/material.dart';
import 'package:loci/presentation/pages/checkin/scanner_animation.dart';
import 'package:loci/presentation/widgets/custom_button.dart';
import 'package:loci/presentation/widgets/custom_text_field.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  final MobileScannerController scannerController = MobileScannerController();
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    scannerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    // Stop camera if we move to manual screen to save battery/resources
    if (index == 1) {
      scannerController.stop();
    } else {
      scannerController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Check In"), centerTitle: true),
      body: Column(
        children: [
          // -----scanner part-----
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [_buildScannerTab(), _buildManualTab()],
            ),
          ),

          // Bottom Section: Tab Switcher
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildScannerTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Align QR Code within the frame",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  MobileScanner(
                    controller: scannerController,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      if (barcodes.isNotEmpty) {
                        final String code =
                            barcodes.first.rawValue ?? "Unknown";
                        _showSuccessDialog(code);
                      }
                    },
                  ),

                  /// Scanning Animation Overlay
                   ScannerAnimation()
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildManualTab() {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.edit_note, size: 80, color: colorScheme.primary),
          const SizedBox(height: 20),
          CustomTextField(
            borderColor: colorScheme.outline,
            hintTextColor: colorScheme.onSurfaceVariant,
            hintText: "Enter Check-In code",
            title: "Check-In Code",
            borderRadius: 12,
          ),
          const SizedBox(height: 20),

          CustomButton(
            text: "Check-In Manually",
            backgroundColor: colorScheme.primary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navButton("Scan QR", Icons.qr_code_scanner, 0),
          _navButton("Manual", Icons.keyboard, 1),
        ],
      ),
    );
  }

  Widget _navButton(String label, IconData icon, int index) {
    bool isSelected = _currentIndex == index;
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? colorScheme.primary : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.primary : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String code) {
    scannerController.stop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Code Detected"),
        content: Text("Scanned: $code"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              scannerController.start(); // Restart scanner after closing
            },
            child: const Text("Scan Again"),
          ),
        ],
      ),
    );
  }
}
