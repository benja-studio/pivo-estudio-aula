import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aula/core/design_system/components/app_card.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/exams/domain/entities/exam.dart';
import 'package:aula/features/grades/domain/entities/grade_entry.dart';
import 'package:aula/features/subjects/data/repositories/subjects_repository_impl.dart';
import 'package:aula/features/subjects/domain/entities/subject.dart';
import 'package:aula/features/subjects/presentation/sheets/create_edit_subject_sheet.dart';
import 'package:aula/features/subjects/presentation/widgets/subject_icon_picker.dart';
import 'package:aula/features/topics/domain/entities/topic.dart';
import 'package:aula/core/database/app_database.dart';

final subjectDetailStreamProvider = StreamProvider.family<Subject?, String>((ref, id) {
  final dao = ref.watch(subjectsDaoProvider);
  return dao.watchActiveSubjects().map((list) {
    for (final s in list) {
      if (s.id == id) return s;
    }
    return null;
  });
});

final subjectExamsProvider = StreamProvider.family<List<Exam>, String>((ref, subjectId) {
  final examsDao = ref.watch(examsDaoProvider);
  return examsDao.watchExamsBySubject(subjectId);
});

final subjectTopicsProvider = StreamProvider.family<List<Topic>, String>((ref, subjectId) {
  final topicsDao = ref.watch(topicsDaoProvider);
  return topicsDao.watchTopicsBySubject(subjectId);
});

final subjectGradesProvider = StreamProvider.family<List<GradeEntry>, String>((ref, subjectId) {
  final gradesDao = ref.watch(gradesDaoProvider);
  return gradesDao.watchGradesBySubject(subjectId);
});

class SubjectDetailScreen extends ConsumerWidget {
  const SubjectDetailScreen({
    super.key,
    required this.subjectId,
  });

  final String subjectId;

  Future<void> _deleteSubject(BuildContext context, WidgetRef ref, Subject subject) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar materia?'),
        content: Text('Se ocultará "${subject.name}". Podrás deshacer esta acción inmediatamente.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final repo = ref.read(subjectsRepositoryProvider);
    await repo.deleteSubject(subject.id);
    unawaited(AppHaptics.destructiveConfirm());

    if (!context.mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Materia "${subject.name}" eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () async {
            await repo.restoreSubject(subject.id);
            unawaited(AppHaptics.success());
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subjectAsync = ref.watch(subjectDetailStreamProvider(subjectId));

    return subjectAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Error al cargar la materia')),
      ),
      data: (subject) {
        if (subject == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Materia no encontrada')),
          );
        }

        final subjectColor = Color(subject.colorValue);
        final examsAsync = ref.watch(subjectExamsProvider(subject.id));
        final topicsAsync = ref.watch(subjectTopicsProvider(subject.id));
        final gradesAsync = ref.watch(subjectGradesProvider(subject.id));

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  CreateEditSubjectSheet.show(context, initialSubject: subject);
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _deleteSubject(context, ref, subject),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Header Card
                Hero(
                  tag: 'subject_card_${subject.id}',
                  child: Material(
                    type: MaterialType.transparency,
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      backgroundColor: subjectColor.withValues(alpha: isDark ? 0.22 : 0.12),
                      border: Border.all(
                        color: subjectColor.withValues(alpha: 0.35),
                        width: 1.0,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: ShapeDecoration(
                              color: subjectColor,
                              shape: AppRadius.continuousShape(AppRadius.md),
                            ),
                            child: Icon(
                              SubjectIconHelper.getIcon(subject.iconName),
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          AppSpacing.gapHorizontalMd,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subject.name,
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (subject.code != null && subject.code!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    subject.code!,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: ShapeDecoration(
                                        color: subjectColor.withValues(alpha: 0.25),
                                        shape: AppRadius.continuousShape(AppRadius.xs),
                                      ),
                                      child: Text(
                                        subject.status.label,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : subjectColor,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    if (subject.period != null && subject.period!.isNotEmpty) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        subject.period!,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                AppSpacing.gapVerticalLg,

                // Metadata Details Card (Docente, Aula, Créditos)
                if (subject.professor != null || subject.classroom != null || subject.credits != null)
                  AppCard(
                    child: Column(
                      children: [
                        if (subject.professor != null && subject.professor!.isNotEmpty)
                          _buildDetailRow(
                            Icons.person_rounded,
                            'Docente',
                            subject.professor!,
                            theme,
                          ),
                        if (subject.classroom != null && subject.classroom!.isNotEmpty) ...[
                          const Divider(height: 16),
                          _buildDetailRow(
                            Icons.meeting_room_rounded,
                            'Aula / Modalidad',
                            subject.classroom!,
                            theme,
                          ),
                        ],
                        if (subject.credits != null) ...[
                          const Divider(height: 16),
                          _buildDetailRow(
                            Icons.stars_rounded,
                            'Créditos',
                            '${subject.credits} créditos',
                            theme,
                          ),
                        ],
                      ],
                    ),
                  ),
                AppSpacing.gapVerticalLg,

                // Evaluations preview
                Text('Evaluaciones', style: theme.textTheme.titleMedium),
                AppSpacing.gapVerticalSm,
                examsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error al cargar evaluaciones'),
                  data: (exams) {
                    if (exams.isEmpty) {
                      return AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No hay evaluaciones registradas para esta materia.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: exams.map((exam) {
                        return AppCard(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Icon(Icons.event_note_rounded, color: subjectColor),
                              AppSpacing.gapHorizontalMd,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exam.title,
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      '${exam.type.label} • ${exam.daysUntil >= 0 ? "Faltan ${exam.daysUntil} días" : "Vencida"}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                AppSpacing.gapVerticalLg,

                // Topics preview with progress
                Text('Progreso de temas', style: theme.textTheme.titleMedium),
                AppSpacing.gapVerticalSm,
                topicsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error al cargar temas'),
                  data: (topics) {
                    if (topics.isEmpty) {
                      return AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No hay temas de estudio agregados aún.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ),
                      );
                    }

                    final masteredCount = topics.where((t) => t.status == TopicStatus.mastered).length;
                    final progress = masteredCount / topics.length;

                    return AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '$masteredCount de ${topics.length} dominados',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              ),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: subjectColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: AppRadius.borderFull,
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: isDark ? AppColors.darkSurfaceHigher : AppColors.lightBorder,
                              valueColor: AlwaysStoppedAnimation<Color>(subjectColor),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                AppSpacing.gapVerticalLg,

                // Grades preview
                Text('Notas', style: theme.textTheme.titleMedium),
                AppSpacing.gapVerticalSm,
                gradesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error al cargar notas'),
                  data: (grades) {
                    if (grades.isEmpty) {
                      return AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          'No hay notas cargadas para esta materia.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          ),
                        ),
                      );
                    }

                    final totalWeight = grades.fold<double>(0.0, (sum, g) => sum + g.weight);
                    final weightedSum = grades.fold<double>(0.0, (sum, g) => sum + (g.value * g.weight));
                    final average = totalWeight > 0 ? (weightedSum / totalWeight) : 0.0;

                    return AppCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Promedio acumulado', style: TextStyle(fontWeight: FontWeight.w600)),
                              Text('${grades.length} evaluaciones registradas', style: theme.textTheme.bodySmall),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: ShapeDecoration(
                              color: subjectColor.withValues(alpha: isDark ? 0.25 : 0.12),
                              shape: AppRadius.continuousShape(AppRadius.md),
                            ),
                            child: Text(
                              average.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: subjectColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 48),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, ThemeData theme) {
    return Row(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        AppSpacing.gapHorizontalMd,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.bodySmall),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}
