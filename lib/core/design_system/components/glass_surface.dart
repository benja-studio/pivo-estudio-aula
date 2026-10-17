import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';

/// Translucent frosted glass container with accessibility high-contrast fallbacks
/// and isolated RepaintBoundary for 60/120 fps smoothness.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius,
    this.blurSigma = 18.0,
    this.padding,
    this.margin,
    this.border,
    this.customBackgroundColor,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final BorderRadius? borderRadius;
  final double blurSigma;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxBorder? border;
  final Color? customBackgroundColor;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHighContrast = MediaQuery.maybeOf(context)?.highContrast ?? false;

    // High contrast mode drops blur and uses solid surfaces with stark borders
    if (isHighContrast) {
      final solidBg = customBackgroundColor ??
          (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface);
      final solidBorder = border ??
          Border.all(
            color: isDark ? Colors.white : Colors.black,
            width: 1.5,
          );

      return Container(
        margin: margin,
        padding: padding,
        decoration: BoxDecoration(
          color: solidBg,
          borderRadius: borderRadius ?? AppRadius.borderMd,
          border: solidBorder,
        ),
        child: child,
      );
    }

    final effectiveBg = customBackgroundColor ??
        (isDark
            ? AppColors.darkSurface.withValues(alpha: 0.78)
            : AppColors.lightSurface.withValues(alpha: 0.82));

    final effectiveBorder = border ??
        Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 0.8,
        );

    final resolvedRadius = borderRadius ?? AppRadius.borderMd;

    return RepaintBoundary(
      child: Container(
        margin: margin,
        child: ClipRRect(
          borderRadius: resolvedRadius,
          clipBehavior: clipBehavior,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: effectiveBg,
                borderRadius: resolvedRadius,
                border: effectiveBorder,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
