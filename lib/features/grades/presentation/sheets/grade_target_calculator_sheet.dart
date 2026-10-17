import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aula/core/design_system/components/app_card.dart';
import 'package:aula/core/design_system/components/app_chip.dart';
import 'package:aula/core/design_system/components/app_text_field.dart';
import 'package:aula/core/design_system/components/spring_sheet.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/grades/data/repositories/grades_repository_impl.dart';
import 'package:aula/features/grades/domain/services/grade_calculator.dart';
import 'package:aula/features/subjects/data/repositories/subjects_repository_impl.dart';

class GradeTargetCalculatorSheet extends ConsumerStatefulWidget {
  const GradeTargetCalculatorSheet({
    super.key,
    this.initialSubjectId,
  });

  final String? initialSubjectId;

  static Future<void> show(BuildContext context, {String? initialSubjectId}) {
    return SpringSheet.show(
      context: context,
      snapFractions: const [0.85, 0.95],
      title: 'Calculadora ¿Qué nota necesito?',
      child: GradeTargetCalculatorSheet(initialSubjectId: initialSubjectId),
    );
  }

  @override
  ConsumerState<GradeTargetCalculatorSheet> createState() => _GradeTargetCalculatorSheetState();
}

class _GradeTargetCalculatorSheetState extends ConsumerState<GradeTargetCalculatorSheet> {
  String? _selectedSubjectId;
  final _targetAverageController = TextEditingController(text: '7.0');
  final _nextWeightController = TextEditingController(text: '1.0');

  @override
  void initState() {
    super.initState();
    _selectedSubjectId = widget.initialSubjectId;
  }

  @override
  void dispose() {
    _targetAverageController.dispose();
    _nextWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subjectsAsync = ref.watch(activeSubjectsProvider);
    final gradesAsync = ref.watch(allGradesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Materia a evaluar', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          AppSpacing.gapVerticalSm,
          subjectsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error al cargar materias'),
            data: (subjects) {
              if (subjects.isEmpty) return const Text('No hay materias registradas.');
              _selectedSubjectId ??= subjects.first.id;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subjects.map((s) {
                  final isSelected = _selectedSubjectId == s.id;
                  final color = Color(s.colorValue);
                  return AppChip(
                    label: s.name,
                    isSelected: isSelected,
                    customColor: color,
                    onTap: () {
                      AppHaptics.selectionClick();
                      setState(() => _selectedSubjectId = s.id);
                    },
                  );
                }).toList(),
              );
            },
          ),
          AppSpacing.gapVerticalLg,

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _targetAverageController,
                  label: 'Promedio objetivo deseado',
                  hint: 'Ej. 7.0 o 4.0 para aprobar',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.next,
                ),
              ),
              AppSpacing.gapHorizontalMd,
              Expanded(
                child: AppTextField(
                  controller: _nextWeightController,
                  label: 'Peso del próximo examen',
                  hint: '1.0 (normal) o 2.0 (doble)',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalXl,

          // Live Calculation Result Card
          gradesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error al calcular notas'),
            data: (allGrades) {
              final subjectGrades = allGrades.where((g) => g.subjectId == _selectedSubjectId).toList();
              final currentCalc = GradeCalculator.calculate(subjectGrades);

              final targetAvg = double.tryParse(_targetAverageController.text.trim()) ?? 7.0;
              final nextWeight = double.tryParse(_nextWeightController.text.trim()) ?? 1.0;

              final weightedSum = subjectGrades.fold<double>(0.0, (sum, g) => sum + (g.value * g.weight));

              final required = GradeCalculator.calculateRequiredGrade(
                currentWeightedSum: weightedSum,
                currentTotalWeight: currentCalc.totalWeight,
                nextEvaluationWeight: nextWeight,
                targetAverage: targetAvg,
              );

              final isPossible = required <= 10.0;
              final isAlreadyAchieved = required <= 0.0;

              Color statusColor;
              String statusTitle;
              String statusSubtitle;

              if (isAlreadyAchieved) {
                statusColor = AppColors.success;
                statusTitle = '¡Ya tienes el promedio asegurado!';
                statusSubtitle = 'Incluso con la nota mínima aprobatoria superarás tu objetivo de $targetAvg.';
              } else if (isPossible) {
                statusColor = required > 8.0 ? AppColors.warning : AppColors.info;
                statusTitle = 'Necesitas sacar un ${required.toStringAsFixed(2)}';
                statusSubtitle = 'En la próxima evaluación con peso de $nextWeight para promediar $targetAvg.';
              } else {
                statusColor = AppColors.error;
                statusTitle = 'Inalcanzable matemáticamente (${required.toStringAsFixed(1)})';
                statusSubtitle = 'Para alcanzar $targetAvg necesitarías una nota mayor a 10. Considera un recuperatorio.';
              }

              return AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                backgroundColor: statusColor.withValues(alpha: isDark ? 0.20 : 0.10),
                border: Border.all(color: statusColor.withValues(alpha: 0.35), width: 1.2),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: ShapeDecoration(
                        color: statusColor.withValues(alpha: 0.20),
                        shape: AppRadius.continuousShape(AppRadius.md),
                      ),
                      child: Icon(
                        isAlreadyAchieved
                            ? Icons.verified_rounded
                            : (isPossible ? Icons.calculate_rounded : Icons.info_outline_rounded),
                        color: statusColor,
                        size: 28,
                      ),
                    ),
                    AppSpacing.gapVerticalMd,
                    Text(
                      statusTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: statusColor,
                      ),
                    ),
                    AppSpacing.gapVerticalSm,
                    Text(
                      statusSubtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('Promedio actual', style: theme.textTheme.bodySmall),
                            const SizedBox(height: 2),
                            Text(
                              currentCalc.weightedAverage.toStringAsFixed(2),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Notas cargadas', style: theme.textTheme.bodySmall),
                            const SizedBox(height: 2),
                            Text(
                              '${currentCalc.count}',
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Peso acumulado', style: theme.textTheme.bodySmall),
                            const SizedBox(height: 2),
                            Text(
                              currentCalc.totalWeight.toStringAsFixed(1),
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
