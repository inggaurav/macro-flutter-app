import 'package:flutter/material.dart';

class AppMotion {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 380);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve springCurve = Curves.fastOutSlowIn;
  static const Curve enterCurve = Curves.decelerate;
  static const Curve exitCurve = Curves.easeInCubic;

  static Duration getDuration(BuildContext context, Duration standardDuration) {
    if (MediaQuery.of(context).disableAnimations) {
      return Duration.zero;
    }
    return standardDuration;
  }
}
