import 'package:flutter/material.dart';
import 'package:aula/core/design_system/components/pressable_scale.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.insetAllMd,
    this.margin,
    this.backgroundColor,
    this.border,
    this.radius = AppRadius.lg,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final BoxBorder? border;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final resolvedBg = backgroundColor ??
        (isDark ? AppColors.darkSurface : AppColors.lightSurface);

    final resolvedBorder = border ??
        Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        );

    final card = Container(
      margin: margin,
      padding: padding,
      decoration: ShapeDecoration(
        color: resolvedBg,
        shape: AppRadius.continuousShape(
          radius,
          side: (resolvedBorder is Border)
              ? resolvedBorder.top
              : BorderSide.none,
        ),
        shadows: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );

    if (onTap != null) {
      return PressableScale(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}
