import 'package:flutter/material.dart';
import 'package:aula/core/design_system/components/pressable_scale.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.leading,
    this.trailing,
    this.customColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final Color? customColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = customColor ?? theme.colorScheme.primary;

    Color backgroundColor;
    Color textColor;
    BorderSide borderSide;

    if (isSelected) {
      backgroundColor = primary.withValues(alpha: isDark ? 0.25 : 0.15);
      textColor = primary;
      borderSide = BorderSide(color: primary, width: 1.2);
    } else {
      backgroundColor = isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface;
      textColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
      borderSide = BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 0.8,
      );
    }

    Widget content = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: AppRadius.continuousShape(
          AppRadius.sm,
          side: borderSide,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[
            leading!,
            AppSpacing.gapHorizontalXs,
          ],
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: textColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
          if (trailing != null) ...[
            AppSpacing.gapHorizontalXs,
            trailing!,
          ],
        ],
      ),
    );

    if (onTap != null) {
      return PressableScale(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
