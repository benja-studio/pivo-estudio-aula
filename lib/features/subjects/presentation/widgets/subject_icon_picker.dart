import 'package:flutter/material.dart';
import 'package:aula/core/design_system/components/pressable_scale.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';

class SubjectIconHelper {
  SubjectIconHelper._();

  static const Map<String, IconData> icons = {
    'book': Icons.book_rounded,
    'code': Icons.code_rounded,
    'calculate': Icons.calculate_rounded,
    'science': Icons.science_rounded,
    'healing': Icons.healing_rounded,
    'gavel': Icons.gavel_rounded,
    'brush': Icons.brush_rounded,
    'language': Icons.language_rounded,
    'music': Icons.music_note_rounded,
    'architecture': Icons.architecture_rounded,
    'analytics': Icons.analytics_rounded,
    'psychology': Icons.psychology_rounded,
  };

  static IconData getIcon(String? name) {
    if (name == null) return Icons.book_rounded;
    return icons[name] ?? Icons.book_rounded;
  }
}

class SubjectIconPicker extends StatelessWidget {
  const SubjectIconPicker({
    super.key,
    required this.selectedIconName,
    required this.onIconChanged,
    required this.tintColor,
  });

  final String selectedIconName;
  final ValueChanged<String> onIconChanged;
  final Color tintColor;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ícono temático',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        AppSpacing.gapVerticalSm,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: SubjectIconHelper.icons.entries.map((entry) {
            final isSelected = entry.key == selectedIconName;

            return PressableScale(
              onTap: () {
                AppHaptics.selectionClick();
                onIconChanged(entry.key);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                decoration: ShapeDecoration(
                  color: isSelected
                      ? tintColor.withValues(alpha: isDark ? 0.35 : 0.18)
                      : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface),
                  shape: AppRadius.continuousShape(
                    AppRadius.sm,
                    side: BorderSide(
                      color: isSelected ? tintColor : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      width: isSelected ? 1.6 : 0.8,
                    ),
                  ),
                ),
                child: Icon(
                  entry.value,
                  size: 20,
                  color: isSelected ? tintColor : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
