import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aula/core/design_system/components/app_card.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/features/exams/domain/entities/exam.dart';
import 'package:aula/features/subjects/presentation/screens/subject_detail_screen.dart';
import 'package:aula/features/subjects/presentation/widgets/subject_icon_picker.dart';

class ExamCard extends ConsumerWidget {
  const ExamCard({
    super.key,
    required this.exam,
    this.onTap,
    this.hasConflict = false,
  });

  final Exam exam;
  final VoidCallback? onTap;
  final bool hasConflict;

  String _formatCountdown(int days) {
    if (days < 0) return 'Vencida';
    if (days == 0) return '¡Es hoy!';
    if (days == 1) return 'Mañana';
    return 'Faltan $days días';
  }

  Color _countdownColor(int days, bool isDark) {
    if (days < 0) return AppColors.error;
    if (days <= 1) return const Color(0xFFF97316); // High alert orange
    if (days <= 3) return AppColors.warning;
    return isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subjectAsync = ref.watch(subjectDetailStreamProvider(exam.subjectId));

    final timeFormatter = DateFormat('HH:mm');
    final dateFormatter = DateFormat('EEE d MMM', 'es');

    return subjectAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (subject) {
        final subjectColor = subject != null ? Color(subject.colorValue) : theme.colorScheme.primary;
        final days = exam.daysUntil;
        final countdownText = _formatCountdown(days);
        final countdownColor = _countdownColor(days, isDark);

        return AppCard(
          onTap: onTap,
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasConflict) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: ShapeDecoration(
                    color: AppColors.warning.withValues(alpha: isDark ? 0.22 : 0.12),
                    shape: AppRadius.continuousShape(AppRadius.xs),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text(
                        'Conflicto de horario con otra evaluación',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFFDE68A) : AppColors.warningDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: ShapeDecoration(
                      color: subjectColor.withValues(alpha: isDark ? 0.25 : 0.14),
                      shape: AppRadius.continuousShape(AppRadius.md),
                    ),
                    child: Icon(
                      subject != null ? SubjectIconHelper.getIcon(subject.iconName) : Icons.event_note_rounded,
                      color: subjectColor,
                      size: 22,
                    ),
                  ),
                  AppSpacing.gapHorizontalMd,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exam.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subject != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subject.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Countdown chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: ShapeDecoration(
                      color: countdownColor.withValues(alpha: isDark ? 0.20 : 0.10),
                      shape: AppRadius.continuousShape(AppRadius.xs),
                    ),
                    child: Text(
                      countdownText,
                      style: TextStyle(
                        color: countdownColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${dateFormatter.format(exam.dateTime)} • ${timeFormatter.format(exam.dateTime)} (${exam.durationMinutes} min)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  if (exam.classroom != null && exam.classroom!.isNotEmpty) ...[
                    const Spacer(),
                    Icon(
                      Icons.meeting_room_outlined,
                      size: 14,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      exam.classroom!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
