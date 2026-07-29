import 'package:flutter/material.dart';
import 'package:loci/core/theme/theme_extention.dart';

/// Leading field icon for explore activity create/edit forms.
Widget exploreActivityFieldIcon(BuildContext context, IconData icon) {
  return Icon(
    icon,
    size: 20,
    color: context.colorScheme.onSurfaceVariant,
  );
}
