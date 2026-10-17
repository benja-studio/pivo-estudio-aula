import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aula/core/design_system/components/app_card.dart';
import 'package:aula/core/design_system/components/app_text_field.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:aula/features/grades/data/repositories/grades_repository_impl.dart';
import 'package:aula/features/subjects/data/repositories/subjects_repository_impl.dart';
import 'package:aula/features/subjects/presentation/widgets/subject_icon_picker.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final subjectsAsync = ref.watch(activeSubjectsProvider);
    final examsAsync = ref.watch(allExamsProvider);
    final gradesAsync = ref.watch(allGradesProvider);

    final cleanQuery = _query.trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Búsqueda Global'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            child: AppTextField(
              controller: _queryController,
              hint: 'Buscar materias, exámenes, notas o temas...',
              prefixIcon: const Icon(Icons.search_rounded),
              autofocus: true,
              onChanged: (val) => setState(() => _query = val),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _queryController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: cleanQuery.isEmpty
                ? Center(
                    child: Text(
                      'Escribe para buscar en toda tu vida académica',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl),
                    children: [
                      // Subjects Match
                      subjectsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (subjects) {
                          final matches = subjects.where((s) =>
                              s.name.toLowerCase().contains(cleanQuery) ||
                              (s.code?.toLowerCase().contains(cleanQuery) ?? false) ||
                              (s.professor?.toLowerCase().contains(cleanQuery) ?? false)).toList();

                          if (matches.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Materias (${matches.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              AppSpacing.gapVerticalSm,
                              ...matches.map((s) {
                                return AppCard(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  onTap: () {
                                    AppHaptics.selectionClick();
                                    context.push('/subjects/${s.id}');
                                  },
                                  child: Row(
                                    children: [
                                      Icon(SubjectIconHelper.getIcon(s.iconName), color: Color(s.colorValue)),
                                      AppSpacing.gapHorizontalMd,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                            Text(s.status.label, style: theme.textTheme.bodySmall),
                                          ],
                                        ),
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

                      // Exams Match
                      examsAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (exams) {
                          final matches = exams.where((e) =>
                              e.title.toLowerCase().contains(cleanQuery) ||
                              (e.notes?.toLowerCase().contains(cleanQuery) ?? false) ||
                              (e.classroom?.toLowerCase().contains(cleanQuery) ?? false)).toList();

                          if (matches.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Evaluaciones (${matches.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              AppSpacing.gapVerticalSm,
                              ...matches.map((e) {
                                return AppCard(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  onTap: () {
                                    AppHaptics.selectionClick();
                                    context.push('/exams/${e.id}');
                                  },
                                  child: Row(
                                    children: [
                                      const Icon(Icons.event_note_rounded, color: AppColors.info),
                                      AppSpacing.gapHorizontalMd,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(e.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                            Text('${e.type.label} • Faltan ${e.daysUntil} días', style: theme.textTheme.bodySmall),
                                          ],
                                        ),
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

                      // Grades Match
                      gradesAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        data: (grades) {
                          final matches = grades.where((g) => g.title.toLowerCase().contains(cleanQuery)).toList();
                          if (matches.isEmpty) return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Notas (${matches.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              AppSpacing.gapVerticalSm,
                              ...matches.map((g) {
                                return AppCard(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: ShapeDecoration(
                                          color: (g.value >= 4.0 ? AppColors.success : AppColors.error).withValues(alpha: 0.15),
                                          shape: AppRadius.continuousShape(AppRadius.xs),
                                        ),
                                        child: Text(
                                          g.value.toStringAsFixed(1),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            color: g.value >= 4.0 ? AppColors.success : AppColors.error,
                                          ),
                                        ),
                                      ),
                                      AppSpacing.gapHorizontalMd,
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(g.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                                            Text(g.kind.label, style: theme.textTheme.bodySmall),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
