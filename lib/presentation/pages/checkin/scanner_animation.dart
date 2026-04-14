import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ScannerAnimation extends StatefulWidget {
  const ScannerAnimation();

  @override
  State<ScannerAnimation> createState() => _ScannerAnimationState();
}

class _ScannerAnimationState extends State<ScannerAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;



  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0, end: 260).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorCache= Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Positioned(
          top: _animation.value,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            color: colorCache.primary,
          ),
        );
      },
    );
  }
}