import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:loci/features/qr_code/presentation/controllers/my_qr_code_controller.dart';
import 'package:loci/features/qr_code/presentation/widgets/my_qr_display_tab.dart';
import 'package:loci/features/qr_code/presentation/widgets/qr_scan_tab.dart';
import 'package:loci/features/qr_code/presentation/widgets/qr_screen_tab_bar.dart';
import 'package:loci/shared/widgets/custom_appbar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Scan another member's QR or share your own connection code.
///
/// Flow: UI → [MyQrCodeController] → [QrCodeService] → [QrCodeRepository] → API.
class MyQrCodeScreen extends StatefulWidget {
  const MyQrCodeScreen({super.key});

  @override
  State<MyQrCodeScreen> createState() => _MyQrCodeScreenState();
}

class _MyQrCodeScreenState extends State<MyQrCodeScreen> {
  final _controller = Get.find<MyQrCodeController>();
  final _scannerController = MobileScannerController(autoStart: false);
  final _pageController = PageController();

  QrScreenTab _selectedTab = QrScreenTab.scan;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.ensureLoaded();
    });
  }

  @override
  void dispose() {
    _scannerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _selectTab(QrScreenTab tab) {
    if (_selectedTab == tab) return;
    setState(() => _selectedTab = tab);
    _pageController.animateToPage(
      tab.index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    final tab = QrScreenTab.values[index];
    if (_selectedTab == tab) return;
    setState(() => _selectedTab = tab);
    if (tab == QrScreenTab.myQr) {
      _controller.ensureLoaded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: const CustomAppbar(title: 'Connect'),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                QrScanTab(
                  controller: _controller,
                  scannerController: _scannerController,
                  isActive: _selectedTab == QrScreenTab.scan,
                ),
                MyQrDisplayTab(controller: _controller),
              ],
            ),
          ),
          QrScreenTabBar(
            selected: _selectedTab,
            onSelected: _selectTab,
          ),
        ],
      ),
    );
  }
}
