import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aula/app/router/routes.dart';
import 'package:aula/core/design_system/components/app_button.dart';
import 'package:aula/core/design_system/components/app_card.dart';
import 'package:aula/core/design_system/components/pressable_scale.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:aula/features/exams/presentation/sheets/create_edit_exam_sheet.dart';
import 'package:aula/features/exams/presentation/widgets/exam_card.dart';
import 'package:aula/features/grades/data/repositories/grades_repository_impl.dart';
import 'package:aula/features/grades/domain/services/grade_calculator.dart';
import 'package:aula/features/grades/presentation/sheets/create_edit_grade_sheet.dart';
import 'package:aula/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:aula/features/profile/presentation/widgets/avatar_picker.dart';
import 'package:aula/features/subjects/data/repositories/subjects_repository_impl.dart';
import 'package:aula/features/subjects/domain/entities/subject.dart';
import 'package:aula/features/subjects/presentation/sheets/create_edit_subject_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  } 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final profileAsync = ref.watch(currentProfileProvider);
    final upcomingExamsAsync = ref.watch(upcomingExamsProvider);
    final overdueExamsAsync = ref.watch(overdueExamsProvider);
    final subjectsAsync = ref.watch(activeSubjectsProvider);
    final gradesAsync = ref.watch(allGradesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xxl + 48,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar: Personalized greeting + Avatar + Search icon
              profileAsync.when(
                loading: () => const SizedBox(height: 60),
                error: (_, __) => const SizedBox.shrink(),
                data: (profile) {
                  final name = profile?.fullName ?? 'Estudiante';
                  final career = profile?.career ?? 'Mi carrera';

                  return Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          AppHaptics.selectionClick();
                          context.push(AppRoutes.settings);
                        },
                        child: AvatarPicker(
                          initialRelativePath: profile?.avatarPath,
                          initials: profile?.initials ?? 'A',
                          size: 48,
                          editable: false,
                        ),
                      ),
                      AppSpacing.gapHorizontalMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_greeting()},',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              career,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Buscar',
                        icon: const Icon(Icons.search_rounded),
                        onPressed: () {
                          AppHaptics.selectionClick();
                          context.push(AppRoutes.search);
                        },
                      ),
                    ],
                  );
                },
              ),
              AppSpacing.gapVerticalLg,

              // Quick Action Bar
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      icon: Icons.event_note_rounded,
                      label: '+ Examen',
                      color: primary,
                      onTap: () => CreateEditExamSheet.show(context),
                    ),
                  ),
                  AppSpacing.gapHorizontalSm,
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      icon: Icons.grade_rounded,
                      label: '+ Nota',
                      color: AppColors.success,
                      onTap: () => CreateEditGradeSheet.show(context),
                    ),
                  ),
                  AppSpacing.gapHorizontalSm,
                  Expanded(
                    child: _buildQuickActionButton(
                      context,
                      icon: Icons.book_rounded,
                      label: '+ Materia',
                      color: const Color(0xFF8B5CF6),
                      onTap: () => CreateEditSubjectSheet.show(context),
                    ),
                  ),
                ],
              ),
              AppSpacing.gapVerticalLg,

              // Featured Next Upcoming Exam
              upcomingExamsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
                data: (exams) {
                  if (exams.isEmpty) {
                    return AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 36, color: primary),
                          AppSpacing.gapVerticalSm,
                          const Text(
                            '¡Estás al día!',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'No tienes próximas evaluaciones programadas.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final nextExam = exams.first;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Próxima evaluación destacada',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      AppSpacing.gapVerticalSm,
                      ExamCard(
                        exam: nextExam,
                        onTap: () => context.push('/exams/${nextExam.id}'),
                      ),
                    ],
                  );
                },
              ),
              AppSpacing.gapVerticalMd,

              // Overdue Exams requiring grades
              overdueExamsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (overdue) {
                  if (overdue.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Text(
                            'Pendientes de nota (${overdue.length})',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                      AppSpacing.gapVerticalSm,
                      ...overdue.take(2).map((e) {
                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text('¿Ya rendiste? Carga tu calificación', style: theme.textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              AppButton(
                                text: 'Cargar nota',
                                size: AppButtonSize.sm,
                                onPressed: () {
                                  CreateEditGradeSheet.show(
                                    context,
                                    preselectedSubjectId: e.subjectId,
                                    preselectedExamId: e.id,
                                    prefilledTitle: e.title,
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      AppSpacing.gapVerticalMd,
                    ],
                  );
                },
              ),

              // Academic Summary Cards: Overall Average + Active Subjects count
              Row(
                children: [
                  Expanded(
                    child: gradesAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (grades) {
                        final calc = GradeCalculator.calculate(grades);
                        return AppCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Promedio general', style: theme.textTheme.bodySmall),
                              const SizedBox(height: 4),
                              Text(
                                calc.weightedAverage > 0 ? calc.weightedAverage.toStringAsFixed(1) : '--',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: primary,
                                ),
                              ),
                              Text('${calc.count} notas cargadas', style: theme.textTheme.bodySmall),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  AppSpacing.gapHorizontalMd,
                  Expanded(
                    child: subjectsAsync.when(
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                      data: (subjects) {
                        return AppCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Materias activas', style: theme.textTheme.bodySmall),
                              const SizedBox(height: 4),
                              Text(
                                '${subjects.length}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${subjects.where((s) => s.status == SubjectStatus.taking).length} en curso',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              AppSpacing.gapVerticalLg,

              // Upcoming Exams List this week
              upcomingExamsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (exams) {
                  if (exams.length <= 1) return const SizedBox.shrink();
                  final remaining = exams.skip(1).take(3).toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Más evaluaciones próximas',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      AppSpacing.gapVerticalSm,
                      ...remaining.map((exam) {
                        return ExamCard(
                          exam: exam,
                          onTap: () => context.push('/exams/${exam.id}'),
                        );
                      }),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PressableScale(
      onTap: () {
        AppHaptics.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2, horizontal: AppSpacing.sm),
        decoration: ShapeDecoration(
          color: color.withValues(alpha: isDark ? 0.20 : 0.10),
          shape: AppRadius.continuousShape(
            AppRadius.md,
            side: BorderSide(color: color.withValues(alpha: 0.25), width: 0.8),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
