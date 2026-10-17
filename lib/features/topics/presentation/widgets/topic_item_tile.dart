import 'package:flutter/material.dart';
import 'package:aula/core/design_system/components/pressable_scale.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/topics/domain/entities/topic.dart';

class TopicItemTile extends StatelessWidget {
  const TopicItemTile({
    super.key,
    required this.topic,
    this.onStatusCycle,
    this.onTap,
    this.dragHandle,
  });

  final Topic topic;
  final VoidCallback? onStatusCycle;
  final VoidCallback? onTap;
  final Widget? dragHandle;

  Color _statusColor(TopicStatus status) {
    return switch (status) {
      TopicStatus.notStarted => const Color(0xFF94A3B8),
      TopicStatus.studying => AppColors.info,
      TopicStatus.reviewed => AppColors.warning,
      TopicStatus.mastered => AppColors.success,
    };
  }

  IconData _statusIcon(TopicStatus status) {
    return switch (status) {
      TopicStatus.notStarted => Icons.radio_button_unchecked_rounded,
      TopicStatus.studying => Icons.timelapse_rounded,
      TopicStatus.reviewed => Icons.refresh_rounded,
      TopicStatus.mastered => Icons.check_circle_rounded,
    };
  }

  Color _priorityColor(TopicPriority priority) {
    return switch (priority) {
      TopicPriority.low => const Color(0xFF64748B),
      TopicPriority.medium => AppColors.warning,
      TopicPriority.high => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final statusColor = _statusColor(topic.status);
    final priorityColor = _priorityColor(topic.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: ShapeDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: AppRadius.continuousShape(
          AppRadius.md,
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        children: [
          // Interactive Status Button (tap cycles status)
          PressableScale(
            onTap: () {
              AppHaptics.selectionClick();
              onStatusCycle?.call();
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs + 2),
              decoration: ShapeDecoration(
                color: statusColor.withValues(alpha: isDark ? 0.22 : 0.12),
                shape: AppRadius.continuousShape(AppRadius.sm),
              ),
              child: Icon(
                _statusIcon(topic.status),
                color: statusColor,
                size: 20,
              ),
            ),
          ),
          AppSpacing.gapHorizontalMd,
          // Topic title & notes
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          topic.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            decoration: topic.status == TopicStatus.mastered
                                ? TextDecoration.lineThrough
                                : null,
                            color: topic.status == TopicStatus.mastered
                                ? (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary)
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),
                      ),
                      if (topic.priority == TopicPriority.high) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: ShapeDecoration(
                            color: priorityColor.withValues(alpha: 0.15),
                            shape: AppRadius.continuousShape(AppRadius.xs),
                          ),
                          child: Text(
                            'Alta',
                            style: TextStyle(color: priorityColor, fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (topic.notes != null && topic.notes!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      topic.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Drag handle for physics reorder
          if (dragHandle != null) dragHandle!,
        ],
      ),
    );
  }
}
