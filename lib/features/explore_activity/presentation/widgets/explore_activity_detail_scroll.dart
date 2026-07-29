import 'package:flutter/material.dart';

/// Standard padded list for view-detail screens.
class ExploreActivityDetailScroll extends StatelessWidget {
  const ExploreActivityDetailScroll({super.key, required this.children});

  final List<Widget> children;

  static const EdgeInsets padding = EdgeInsets.fromLTRB(16, 12, 16, 28);

  @override
  Widget build(BuildContext context) {
    return ListView(padding: padding, children: children);
  }
}
