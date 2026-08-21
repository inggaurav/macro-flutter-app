import 'dart:ui';
import 'package:flutter/material.dart';
import '../tokens/app_colors.dart';
import '../tokens/app_radius.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final double blur;
  final Color? backgroundColor;
  final Border? border;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassSurface({
    super.key,
    required this.child,
    this.blur = 16.0,
    this.backgroundColor,
    this.border,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.borderLg;
    final effectiveColor =
        backgroundColor ?? AppColors.surfaceElevated.withValues(alpha: 0.65);
    final effectiveBorder =
        border ??
        Border.all(color: AppColors.borderDark.withValues(alpha: 0.6));

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: effectiveColor,
              borderRadius: effectiveRadius,
              border: effectiveBorder,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
