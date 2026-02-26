import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  String? scannedCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:context.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Check In'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
                      onDetect: (capture) {
                        final barcode = capture.barcodes.first;
                        setState(() {
                          scannedCode = barcode.rawValue;
                        });
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
                        top: 0, left: 0,
                        child: _corner(topLeft: true),
                      ),
                      // Top-right
                      Positioned(
                        top: 0, right: 0,
                        child: _corner(topRight: true),
                      ),
                      // Bottom-left
                      Positioned(
                        bottom: 0, left: 0,
                        child: _corner(bottomLeft: true),
                      ),
                      // Bottom-right
                      Positioned(
                        bottom: 0, right: 0,
                        child: _corner(bottomRight: true),
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
            const Text(
              'Align barcode within the frame',
              style: TextStyle(color: Colors.white60),
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
  }) {
    const double size = 30;
    const double thickness = 4;
    const color = Colors.green;

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
            child: Container(
              width: size,
              height: thickness,
              color: color,
            ),
          ),
          // Vertical line
          Positioned(
            top: topLeft || topRight ? 0 : null,
            bottom: bottomLeft || bottomRight ? 0 : null,
            left: topLeft || bottomLeft ? 0 : null,
            right: topRight || bottomRight ? 0 : null,
            child: Container(
              width: thickness,
              height: size,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}