import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aula/core/design_system/components/app_card.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:aula/features/exams/domain/entities/exam.dart';
import 'package:aula/features/exams/presentation/sheets/create_edit_exam_sheet.dart';
import 'package:aula/features/subjects/presentation/screens/subject_detail_screen.dart';
import 'package:aula/features/topics/data/repositories/topics_repository_impl.dart';
import 'package:aula/features/topics/presentation/widgets/topic_reorderable_list.dart';

final examDetailProvider = StreamProvider.family<Exam?, String>((ref, examId) {
  final examsRepo = ref.watch(examsRepositoryProvider);
  return examsRepo.watchAllActiveExams().map((exams) {
    for (final e in exams) {
      if (e.id == examId) return e;
    }
    return null;
  });
});

class ExamDetailScreen extends ConsumerWidget {
  const ExamDetailScreen({
    super.key,
    required this.examId,
  });

  final String examId;

  Future<void> _deleteExam(BuildContext context, WidgetRef ref, Exam exam) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar evaluación?'),
        content: Text('Se ocultará "${exam.title}". Podrás deshacer esta acción.'),
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

    final repo = ref.read(examsRepositoryProvider);
    await repo.deleteExam(exam.id);
    unawaited(AppHaptics.destructiveConfirm());

    if (!context.mounted) return;
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Evaluación "${exam.title}" eliminada'),
        action: SnackBarAction(
          label: 'Deshacer',
          onPressed: () async {
            await repo.restoreExam(exam.id);
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
    final examAsync = ref.watch(examDetailProvider(examId));

    return examAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(appBar: AppBar(), body: const Center(child: Text('Error al cargar la evaluación'))),
      data: (exam) {
        if (exam == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Evaluación no encontrada')));
        }

        final subjectAsync = ref.watch(subjectDetailStreamProvider(exam.subjectId));
        final topicsAsync = ref.watch(topicsByExamProvider(exam.id));
        final dateFormatter = DateFormat('EEEE d \'de\' MMMM, yyyy', 'es');
        final timeFormatter = DateFormat('HH:mm');

        return Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => CreateEditExamSheet.show(context, initialExam: exam),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded),
                onPressed: () => _deleteExam(context, ref, exam),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Header Card
                subjectAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (subject) {
                    final color = subject != null ? Color(subject.colorValue) : theme.colorScheme.primary;

                    return AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      backgroundColor: color.withValues(alpha: isDark ? 0.22 : 0.10),
                      border: Border.all(color: color.withValues(alpha: 0.35), width: 1.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: ShapeDecoration(
                                  color: color.withValues(alpha: 0.25),
                                  shape: AppRadius.continuousShape(AppRadius.xs),
                                ),
                                child: Text(
                                  exam.type.label,
                                  style: TextStyle(color: isDark ? Colors.white : color, fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: ShapeDecoration(
                                  color: isDark ? AppColors.darkSurfaceHigher : AppColors.lightSurface,
                                  shape: AppRadius.continuousShape(AppRadius.xs),
                                ),
                                child: Text(
                                  exam.daysUntil >= 0 ? 'Faltan ${exam.daysUntil} días' : 'Vencida',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    color: exam.daysUntil <= 1 ? AppColors.error : (isDark ? Colors.white : Colors.black87),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          AppSpacing.gapVerticalMd,
                          Text(exam.title, style: theme.textTheme.displayMedium?.copyWith(fontSize: 24, fontWeight: FontWeight.w700)),
                          if (subject != null) ...[
                            const SizedBox(height: 4),
                            Text(subject.name, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
                          ],
                        ],
                      ),
                    );
                  },
                ),
                AppSpacing.gapVerticalLg,

                // Exam Schedule & Room Details
                AppCard(
                  child: Column(
                    children: [
                      _buildDetailRow(Icons.calendar_today_rounded, 'Fecha', dateFormatter.format(exam.dateTime), theme),
                      const Divider(height: 18),
                      _buildDetailRow(Icons.access_time_rounded, 'Horario y duración', '${timeFormatter.format(exam.dateTime)} (${exam.durationMinutes} minutos)', theme),
                      if (exam.classroom != null && exam.classroom!.isNotEmpty) ...[
                        const Divider(height: 18),
                        _buildDetailRow(Icons.meeting_room_outlined, 'Lugar / Aula', exam.classroom!, theme),
                      ],
                      if (exam.retakeOfExamId != null) ...[
                        const Divider(height: 18),
                        _buildDetailRow(
                          Icons.swap_horiz_rounded,
                          'Recuperatorio',
                          exam.retakeRule == 'replace' ? 'Reemplaza la nota original' : 'Se promedia con el parcial original',
                          theme,
                        ),
                      ],
                    ],
                  ),
                ),
                AppSpacing.gapVerticalLg,

                // Study topics section with reordering
                Text('Temas de estudio para esta evaluación', style: theme.textTheme.titleMedium),
                AppSpacing.gapVerticalSm,
                topicsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Error al cargar temas'),
                  data: (topics) => TopicReorderableList(
                    subjectId: exam.subjectId,
                    examId: exam.id,
                    topics: topics,
                  ),
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
