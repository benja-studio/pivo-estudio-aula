import 'package:flutter/material.dart';
import 'package:aula/core/design_system/components/pressable_scale.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';

enum AppButtonVariant { primary, secondary, tonal, danger, text }

enum AppButtonSize { sm, md, lg }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEnabled = onPressed != null && !isLoading;

    // Dimensions according to size token
    final double height;
    final EdgeInsets padding;
    final TextStyle textStyle;

    switch (size) {
      case AppButtonSize.sm:
        height = 40.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.md);
        textStyle = theme.textTheme.labelMedium ?? const TextStyle();
        break;
      case AppButtonSize.md:
        height = 50.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg);
        textStyle = theme.textTheme.labelLarge ?? const TextStyle();
        break;
      case AppButtonSize.lg:
        height = 58.0;
        padding = const EdgeInsets.symmetric(horizontal: AppSpacing.xl);
        textStyle = (theme.textTheme.labelLarge ?? const TextStyle()).copyWith(fontSize: 16);
        break;
    }

    // Color resolution
    Color backgroundColor;
    Color foregroundColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = theme.colorScheme.primary;
        foregroundColor = theme.colorScheme.onPrimary;
        break;
      case AppButtonVariant.secondary:
        backgroundColor = isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurface;
        foregroundColor = isDark
            ? AppColors.darkTextPrimary
            : AppColors.lightTextPrimary;
        borderSide = BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.0,
        );
        break;
      case AppButtonVariant.tonal:
        backgroundColor = theme.colorScheme.primary.withValues(alpha: isDark ? 0.20 : 0.12);
        foregroundColor = theme.colorScheme.primary;
        break;
      case AppButtonVariant.danger:
        backgroundColor = AppColors.error;
        foregroundColor = Colors.white;
        break;
      case AppButtonVariant.text:
        backgroundColor = Colors.transparent;
        foregroundColor = theme.colorScheme.primary;
        break;
    }

    if (!isEnabled && variant != AppButtonVariant.text) {
      backgroundColor = isDark
          ? AppColors.darkSurfaceHigher.withValues(alpha: 0.5)
          : AppColors.lightBorderSubtle;
      foregroundColor = isDark
          ? AppColors.darkTextTertiary
          : AppColors.lightTextTertiary;
      borderSide = BorderSide.none;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          ),
          AppSpacing.gapHorizontalSm,
        ] else if (icon != null) ...[
          icon!,
          AppSpacing.gapHorizontalSm,
        ],
        Text(
          text,
          style: textStyle.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return PressableScale(
      enabled: isEnabled,
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        padding: padding,
        decoration: ShapeDecoration(
          color: backgroundColor,
          shape: AppRadius.continuousShape(
            size == AppButtonSize.lg ? AppRadius.lg : AppRadius.md,
            side: borderSide,
          ),
        ),
        child: content,
      ),
    );
  }
}
