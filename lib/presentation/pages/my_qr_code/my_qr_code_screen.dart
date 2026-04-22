import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MyQrcodeScreen extends StatefulWidget {
  const MyQrcodeScreen({super.key});

  @override
  State<MyQrcodeScreen> createState() => _MyQrcodeScreenState();
}

class _MyQrcodeScreenState extends State<MyQrcodeScreen> {
  final MobileScannerController scannerController = MobileScannerController();
  final PageController _pageController = PageController();

  int _currentIndex = 0;

  // Dummy QR Data
  final String qrData =
      "userId:12345|name:Mynul|type:user|timestamp:1712686400";

  @override
  void dispose() {
    scannerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    index == 1 ? scannerController.stop() : scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My QR Code"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildScannerTab(),
                _buildMyQrTab(color),
              ],
            ),
          ),
          _buildBottomNav(color),
        ],
      ),
    );
  }

  // -------------------------
  // Scanner Tab (same as before)
  // -------------------------
  Widget _buildScannerTab() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Scan QR Code",
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
            child: MobileScanner(
              controller: scannerController,
              onDetect: (capture) {
                final code =
                    capture.barcodes.firstOrNull?.rawValue ?? '';
                if (code.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Scanned: $code")),
                  );
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------
  // My QR Code Tab
  // -------------------------
  Widget _buildMyQrTab(ColorScheme color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "My QR Code",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: QrImageView(
              data: qrData,
              size: 220,
              backgroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            "Show this QR to check in",
            style: TextStyle(
              color: color.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // Bottom Nav
  // -------------------------
  Widget _buildBottomNav(ColorScheme color) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: color.surfaceContainerHigh,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            spreadRadius: 2,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _navButton("Scan", Icons.qr_code_scanner, 0),
          _navButton("My QR", Icons.qr_code, 1),
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
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}