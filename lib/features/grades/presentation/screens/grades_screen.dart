import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aula/core/design_system/components/app_button.dart';
import 'package:aula/core/design_system/components/app_card.dart';
import 'package:aula/core/design_system/components/app_chip.dart';
import 'package:aula/core/design_system/components/empty_state.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/grades/data/repositories/grades_repository_impl.dart';
import 'package:aula/features/grades/domain/services/grade_calculator.dart';
import 'package:aula/features/grades/presentation/sheets/create_edit_grade_sheet.dart';
import 'package:aula/features/grades/presentation/sheets/grade_target_calculator_sheet.dart';
import 'package:aula/features/grades/presentation/widgets/grades_by_subject_bar_chart.dart';
import 'package:aula/features/grades/presentation/widgets/grades_evolution_chart.dart';
import 'package:aula/features/subjects/data/repositories/subjects_repository_impl.dart';

class GradesScreen extends ConsumerStatefulWidget {
  const GradesScreen({super.key});

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  int _tabIndex = 0; // 0 = Lista de Notas, 1 = Gráficos

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final gradesAsync = ref.watch(allGradesProvider);
    final subjectsAsync = ref.watch(activeSubjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas y Promedios'),
        actions: [
          IconButton(
            tooltip: 'Calculadora ¿Qué nota necesito?',
            icon: const Icon(Icons.calculate_outlined),
            onPressed: () {
              AppHaptics.selectionClick();
              GradeTargetCalculatorSheet.show(context);
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppButton(
              text: 'Cargar',
              icon: const Icon(Icons.add_rounded, size: 18),
              size: AppButtonSize.sm,
              onPressed: () {
                AppHaptics.selectionClick();
                CreateEditGradeSheet.show(context);
              },
            ),
          ),
        ],
      ),
      body: gradesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al cargar notas: $err')),
        data: (grades) {
          final calc = GradeCalculator.calculate(grades);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.xs,
              AppSpacing.md,
              AppSpacing.xxl + 40,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Promedio General Highlight Card
                AppCard(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  backgroundColor: primary.withValues(alpha: isDark ? 0.22 : 0.10),
                  border: Border.all(color: primary.withValues(alpha: 0.35), width: 1.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Promedio General',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            calc.weightedAverage > 0 ? calc.weightedAverage.toStringAsFixed(2) : '--',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${calc.count} notas • Promedio simple: ${calc.simpleAverage > 0 ? calc.simpleAverage.toStringAsFixed(2) : "--"}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 52,
                        height: 52,
                        decoration: ShapeDecoration(
                          color: primary.withValues(alpha: isDark ? 0.30 : 0.18),
                          shape: AppRadius.continuousShape(AppRadius.md),
                        ),
                        child: Icon(
                          Icons.auto_graph_rounded,
                          color: primary,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapVerticalMd,

                // Toggle between List and Charts
                Row(
                  children: [
                    Expanded(
                      child: AppChip(
                        label: 'Lista de notas (${grades.length})',
                        isSelected: _tabIndex == 0,
                        leading: const Icon(Icons.list_alt_rounded, size: 16),
                        onTap: () {
                          AppHaptics.selectionClick();
                          setState(() => _tabIndex = 0);
                        },
                      ),
                    ),
                    AppSpacing.gapHorizontalSm,
                    Expanded(
                      child: AppChip(
                        label: 'Gráficos de rendimiento',
                        isSelected: _tabIndex == 1,
                        leading: const Icon(Icons.show_chart_rounded, size: 16),
                        onTap: () {
                          AppHaptics.selectionClick();
                          setState(() => _tabIndex = 1);
                        },
                      ),
                    ),
                  ],
                ),
                AppSpacing.gapVerticalLg,

                if (_tabIndex == 0) ...[
                  // Lista de Notas agrupada
                  if (grades.isEmpty)
                    EmptyState(
                      icon: Icons.grade_outlined,
                      title: 'No hay notas registradas',
                      subtitle: 'Carga tus notas de parciales, TP o conceptos para calcular tus promedios.',
                      actionLabel: 'Cargar primera nota',
                      onAction: () => CreateEditGradeSheet.show(context),
                    )
                  else
                    ...grades.map((grade) {
                      final dateFormatter = DateFormat('d MMM yyyy', 'es');
                      final isPassing = grade.value >= 4.0;
                      final gradeColor = isPassing ? AppColors.success : AppColors.error;

                      return AppCard(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: ShapeDecoration(
                                color: gradeColor.withValues(alpha: isDark ? 0.22 : 0.12),
                                shape: AppRadius.continuousShape(AppRadius.sm),
                              ),
                              child: Text(
                                grade.value.toStringAsFixed(1),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: gradeColor,
                                ),
                              ),
                            ),
                            AppSpacing.gapHorizontalMd,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    grade.title,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                                  ),
                                  Text(
                                    '${grade.kind.label} • Peso ${grade.weight} • ${dateFormatter.format(grade.date)}',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              onPressed: () => CreateEditGradeSheet.show(context, initialGrade: grade),
                            ),
                          ],
                        ),
                      );
                    }),
                ] else ...[
                  // Vista de Gráficos (fl_chart)
                  const Text('Curva de evolución de notas', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  AppSpacing.gapVerticalSm,
                  GradesEvolutionChart(grades: grades),
                  AppSpacing.gapVerticalLg,

                  const Text('Comparativa de promedios por materia', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  AppSpacing.gapVerticalSm,
                  subjectsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Error al cargar comparativa'),
                    data: (subjects) => GradesBySubjectBarChart(subjects: subjects, grades: grades),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
