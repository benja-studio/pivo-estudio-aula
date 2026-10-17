import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:aula/core/design_system/components/app_button.dart';
import 'package:aula/core/design_system/components/app_chip.dart';
import 'package:aula/core/design_system/components/app_text_field.dart';
import 'package:aula/core/design_system/components/spring_sheet.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/topics/data/repositories/topics_repository_impl.dart';
import 'package:aula/features/topics/domain/entities/topic.dart';
import 'package:aula/features/topics/presentation/widgets/topic_item_tile.dart';

class TopicReorderableList extends ConsumerWidget {
  const TopicReorderableList({
    super.key,
    required this.subjectId,
    this.examId,
    required this.topics,
    this.accentColor,
  });

  final String subjectId;
  final String? examId;
  final List<Topic> topics;
  final Color? accentColor;

  TopicStatus _nextStatus(TopicStatus current) {
    return switch (current) {
      TopicStatus.notStarted => TopicStatus.studying,
      TopicStatus.studying => TopicStatus.reviewed,
      TopicStatus.reviewed => TopicStatus.mastered,
      TopicStatus.mastered => TopicStatus.notStarted,
    };
  }

  void _showAddTopicDialog(BuildContext context, WidgetRef ref) {
    AppHaptics.selectionClick();
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    TopicPriority priority = TopicPriority.medium;

    SpringSheet.show(
      context: context,
      snapFractions: const [0.65],
      title: 'Nuevo Tema de Estudio',
      child: StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTextField(
                  controller: titleController,
                  label: 'Tema / Unidad *',
                  hint: 'Ej. Ecuaciones Diferenciales de 2do orden',
                  autofocus: true,
                  textInputAction: TextInputAction.next,
                ),
                AppSpacing.gapVerticalMd,
                AppTextField(
                  controller: notesController,
                  label: 'Notas / Referencia',
                  hint: 'Capítulo 4 del libro, ejercicios impares...',
                  maxLines: 2,
                ),
                AppSpacing.gapVerticalMd,
                const Text('Prioridad', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                AppSpacing.gapVerticalSm,
                Row(
                  children: TopicPriority.values.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: AppChip(
                        label: p.label,
                        isSelected: priority == p,
                        onTap: () => setState(() => priority = p),
                      ),
                    );
                  }).toList(),
                ),
                AppSpacing.gapVerticalLg,
                AppButton(
                  text: 'Guardar Tema',
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) return;
                    final now = DateTime.now();
                    final topic = Topic(
                      id: const Uuid().v4(),
                      subjectId: subjectId,
                      examId: examId,
                      title: titleController.text.trim(),
                      notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                      priority: priority,
                      sortOrder: topics.length,
                      createdAt: now,
                      updatedAt: now,
                    );
                    final repo = ref.read(topicsRepositoryProvider);
                    await repo.createTopic(topic);
                    unawaited(AppHaptics.success());
                    if (context.mounted) Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = accentColor ?? theme.colorScheme.primary;

    final masteredCount = topics.where((t) => t.status == TopicStatus.mastered).length;
    final progress = topics.isNotEmpty ? (masteredCount / topics.length) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Progress Card Header
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          margin: const EdgeInsets.only(bottom: AppSpacing.md),
          decoration: ShapeDecoration(
            color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
            shape: AppRadius.continuousShape(
              AppRadius.md,
              side: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 0.8,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progreso de estudio ($masteredCount/${topics.length})',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: AppRadius.borderFull,
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: isDark ? AppColors.darkSurfaceHigher : AppColors.lightBorder,
                  valueColor: AlwaysStoppedAnimation<Color>(primary),
                ),
              ),
            ],
          ),
        ),

        // Quick add button
        Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: AppButton(
            text: 'Agregar tema de estudio',
            icon: const Icon(Icons.add_rounded, size: 18),
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.sm,
            onPressed: () => _showAddTopicDialog(context, ref),
          ),
        ),

        // Reorderable list
        if (topics.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'No hay temas cargados. Agrega los temas para seguir tu avance.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              ),
            ),
          )
        else
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topics.length,
            onReorder: (oldIndex, newIndex) {
              AppHaptics.snapPoint();
              final list = List<Topic>.from(topics);
              if (newIndex > oldIndex) newIndex -= 1;
              final item = list.removeAt(oldIndex);
              list.insert(newIndex, item);
              ref.read(topicsRepositoryProvider).reorderTopics(list);
            },
            itemBuilder: (context, index) {
              final topic = topics[index];
              return TopicItemTile(
                key: ValueKey(topic.id),
                topic: topic,
                dragHandle: ReorderableDragStartListener(
                  index: index,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      size: 20,
                    ),
                  ),
                ),
                onStatusCycle: () {
                  final next = _nextStatus(topic.status);
                  final updated = topic.copyWith(status: next, updatedAt: DateTime.now());
                  ref.read(topicsRepositoryProvider).updateTopic(updated);
                },
              );
            },
          ),
      ],
    );
  }
}
