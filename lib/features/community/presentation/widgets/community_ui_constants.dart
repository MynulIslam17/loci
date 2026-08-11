import 'package:flutter/material.dart';

/// Shared layout tokens for the community hub screen.
abstract final class CommunityUi {
  static const horizontalPadding = 16.0;
  static const tabBodyTopPadding = 8.0;
  static const tabBarBottomSpacing = 8.0;
  static const stickyHeaderTop = 12.0;
  static const sectionSpacing = 12.0;
  static const stickyHeaderBottom = 16.0;

  static EdgeInsets get stickyHeaderPadding => const EdgeInsets.only(
        top: stickyHeaderTop,
        bottom: stickyHeaderBottom,
      );
  static const cardRadius = 16.0;
  static const headerActionRadius = 12.0;

  static EdgeInsets get screenPadding =>
      const EdgeInsets.symmetric(horizontal: horizontalPadding);

  static EdgeInsets get headerPadding => EdgeInsets.fromLTRB(
        horizontalPadding,
        tabBodyTopPadding,
        horizontalPadding,
        0,
      );
}
