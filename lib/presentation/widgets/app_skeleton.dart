import 'package:flutter/material.dart';

class AppSkeleton {
  AppSkeleton._();

  /// ───────────────────────── LIST SKELETON ─────────────────────────
  static Widget list({
    required BuildContext context,
    int itemCount = 3,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => Card(
        elevation: 1,
        color: colorScheme.surfaceContainerHigh,
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const SkeletonBox(width: 48, height: 48, radius: 24),
          title: const SkeletonBox(width: 100, height: 14),
          subtitle: const Padding(
            padding: EdgeInsets.only(top: 8),
            child: SkeletonBox(width: 60, height: 10),
          ),
          trailing: const SkeletonBox(width: 80, height: 24),
        ),
      ),
    );
  }

  /// ───────────────────────── GRID SKELETON ─────────────────────────
  static Widget grid({
    required BuildContext context,
    int itemCount = 4,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: List.generate(
        itemCount,
            (_) => Card(
          elevation: 1,
          color: colorScheme.surfaceContainerHigh,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SkeletonBox(width: 24, height: 24, radius: 12),
                  SizedBox(width: 12),
                  SkeletonBox(width: 40, height: 22),
                ],
              ),
              SizedBox(height: 8),
              SkeletonBox(width: 90, height: 12),
            ],
          ),
        ),
      ),
    );
  }

  /// ───────────────────────── SIMPLE BOX ─────────────────────────
  static Widget box({
    double width = double.infinity,
    double height = 12,
    double radius = 6,
  }) {
    return SkeletonBox(
      width: width,
      height: height,
      radius: radius,
    );
  }
}




class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final double radius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.radius = 6,
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final base = isDark
        ? Colors.grey.shade800
        : Colors.grey.shade300;

    final highlight = isDark
        ? Colors.grey.shade700
        : Colors.grey.shade100;

    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
              colors: [
                base,
                highlight,
                base,
              ],
              stops: const [0.1, 0.5, 0.9],
            ),
          ),
        );
      },
    );
  }
}