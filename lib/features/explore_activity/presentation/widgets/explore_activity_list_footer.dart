import 'package:flutter/material.dart';

class ExploreActivityListFooter extends StatelessWidget {
  const ExploreActivityListFooter({
    super.key,
    required this.isLoading,
    required this.hasMore,
    required this.endLabel,
  });

  final bool isLoading;
  final bool hasMore;
  final String endLabel;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (!hasMore) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(endLabel, style: const TextStyle(fontSize: 12)),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
