import 'package:flutter/material.dart';

enum DeviceFormFactor {
  compact, // Phone (< 600)
  medium, // Tablet portrait (600 - 900)
  expanded, // Desktop / Tablet landscape (900 - 1200)
  wide, // Ultra-wide (> 1200)
}

class AppBreakpoints {
  static const double compactMax = 600.0;
  static const double mediumMax = 900.0;
  static const double expandedMax = 1200.0;

  static DeviceFormFactor getFormFactor(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < compactMax) return DeviceFormFactor.compact;
    if (width < mediumMax) return DeviceFormFactor.medium;
    if (width < expandedMax) return DeviceFormFactor.expanded;
    return DeviceFormFactor.wide;
  }

  static bool isCompact(BuildContext context) =>
      getFormFactor(context) == DeviceFormFactor.compact;
  static bool isMedium(BuildContext context) =>
      getFormFactor(context) == DeviceFormFactor.medium;
  static bool isExpanded(BuildContext context) =>
      getFormFactor(context) == DeviceFormFactor.expanded;
  static bool isWide(BuildContext context) =>
      getFormFactor(context) == DeviceFormFactor.wide;
}
