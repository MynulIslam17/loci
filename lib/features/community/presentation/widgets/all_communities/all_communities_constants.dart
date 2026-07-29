import 'package:flutter/material.dart';

abstract final class AllCommunitiesUi {
  static const horizontalPadding = 16.0;
  static const searchTop = 8.0;
  static const sectionTitleGap = 24.0;
  static const sectionListGap = 12.0;
  static const paginationVertical = 16.0;

  static EdgeInsets get screenPadding =>
      const EdgeInsets.symmetric(horizontal: horizontalPadding);
}
