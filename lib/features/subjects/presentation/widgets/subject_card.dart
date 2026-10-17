import 'package:flutter/material.dart';
import 'package:aula/core/design_system/components/app_card.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/features/subjects/domain/entities/subject.dart';
import 'package:aula/features/subjects/presentation/widgets/subject_icon_picker.dart';

class SubjectCard extends StatelessWidget {
  const SubjectCard({
    super.key,
    required this.subject,
    this.onTap,
  });

  final Subject subject;
  final VoidCallback? onTap;

  Color _statusColor(SubjectStatus status) {
    return switch (status) {
      SubjectStatus.taking => AppColors.info,
      SubjectStatus.regular => AppColors.warning,
      SubjectStatus.passed => AppColors.success,
      SubjectStatus.failed => AppColors.error,
      SubjectStatus.retaking => const Color(0xFFF97316),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final subjectColor = Color(subject.colorValue);
    final statusColor = _statusColor(subject.status);

    return Hero(
      tag: 'subject_card_${subject.id}',
      child: Material(
        type: MaterialType.transparency,
        child: AppCard(
          onTap: onTap,
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thematic icon container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: ShapeDecoration(
                      color: subjectColor.withValues(alpha: isDark ? 0.25 : 0.14),
                      shape: AppRadius.continuousShape(AppRadius.md),
                    ),
                    child: Icon(
                      SubjectIconHelper.getIcon(subject.iconName),
                      color: subjectColor,
                      size: 24,
                    ),
                  ),
                  AppSpacing.gapHorizontalMd,
                  // Title & Code
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subject.code != null && subject.code!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subject.code!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Status badge chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: ShapeDecoration(
                      color: statusColor.withValues(alpha: isDark ? 0.22 : 0.12),
                      shape: AppRadius.continuousShape(AppRadius.xs),
                    ),
                    child: Text(
                      subject.status.label,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              if (subject.professor != null || subject.classroom != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (subject.professor != null && subject.professor!.isNotEmpty) ...[
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          subject.professor!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (subject.classroom != null && subject.classroom!.isNotEmpty) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.meeting_room_outlined,
                        size: 14,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subject.classroom!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
