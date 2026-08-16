import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// [CupertinoSwitch] on iOS, Material [Switch] on Android.
class AdaptiveSwitch extends StatelessWidget {
  const AdaptiveSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final track = activeColor ?? context.colorScheme.primary;
    if (context.isCupertino) {
      return CupertinoSwitch(
        value: value,
        activeTrackColor: track,
        onChanged: onChanged,
      );
    }
    return Switch(
      value: value,
      activeThumbColor: context.colorScheme.onPrimary,
      activeTrackColor: track,
      onChanged: onChanged,
    );
  }
}
