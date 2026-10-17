import 'package:flutter/material.dart';
import 'package:aula/core/design_system/components/pressable_scale.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';

class SubjectColorPicker extends StatelessWidget {
  const SubjectColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  final int selectedColor;
  final ValueChanged<int> onColorChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color de la materia',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        AppSpacing.gapVerticalSm,
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: AppColors.subjectPalette.map((color) {
            final isSelected = color.toARGB32() == selectedColor;

            return PressableScale(
              onTap: () {
                AppHaptics.selectionClick();
                onColorChanged(color.toARGB32());
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 38,
                height: 38,
                decoration: ShapeDecoration(
                  color: color,
                  shape: AppRadius.continuousShape(AppRadius.sm),
                  shadows: isSelected
                      ? [
                          BoxShadow(
                            color: color.withValues(alpha: 0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
