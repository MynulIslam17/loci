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
  Worker? _tabWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.ensureLoaded();
    });
    _tabWorker = ever(_controller.selectedTabRx, (tab) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != tab.index) {
        _pageController.animateToPage(
          tab.index,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _tabWorker?.dispose();
    _scannerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onTabSelected(QrScreenTab tab) {
    _controller.changeTab(tab);
    _pageController.animateToPage(
      tab.index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    final tab = QrScreenTab.values[index];
    _controller.changeTab(tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: const CustomAppbar(title: 'Connect'),
      body: Obx(() {
        final currentTab = _controller.selectedTab;

        return Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: [
                  QrScanTab(
                    controller: _controller,
                    scannerController: _scannerController,
                    isActive: currentTab == QrScreenTab.scan,
                  ),
                  MyQrDisplayTab(controller: _controller),
                ],
              ),
            ),
            QrScreenTabBar(
              selected: currentTab,
              onSelected: _onTabSelected,
            ),
          ],
        );
      }),
    );
  }
}
