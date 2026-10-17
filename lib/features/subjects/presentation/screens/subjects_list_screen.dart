import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aula/core/design_system/components/app_button.dart';
import 'package:aula/core/design_system/components/app_chip.dart';
import 'package:aula/core/design_system/components/empty_state.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/subjects/data/repositories/subjects_repository_impl.dart';
import 'package:aula/features/subjects/domain/entities/subject.dart';
import 'package:aula/features/subjects/presentation/sheets/create_edit_subject_sheet.dart';
import 'package:aula/features/subjects/presentation/widgets/subject_card.dart';

class SubjectsListScreen extends ConsumerStatefulWidget {
  const SubjectsListScreen({super.key});

  @override
  ConsumerState<SubjectsListScreen> createState() => _SubjectsListScreenState();
}

class _SubjectsListScreenState extends ConsumerState<SubjectsListScreen> {
  SubjectStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(activeSubjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Materias'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppButton(
              text: 'Nueva',
              icon: const Icon(Icons.add_rounded, size: 18),
              size: AppButtonSize.sm,
              onPressed: () {
                AppHaptics.selectionClick();
                CreateEditSubjectSheet.show(context);
              },
            ),
          ),
        ],
      ),
      body: subjectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error al cargar materias: $err')),
        data: (subjects) {
          final filtered = _filterStatus == null
              ? subjects
              : subjects.where((s) => s.status == _filterStatus).toList();

          return Column(
            children: [
              // Filter chips row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    AppChip(
                      label: 'Todas (${subjects.length})',
                      isSelected: _filterStatus == null,
                      onTap: () {
                        AppHaptics.selectionClick();
                        setState(() => _filterStatus = null);
                      },
                    ),
                    AppSpacing.gapHorizontalSm,
                    AppChip(
                      label: 'Cursando',
                      isSelected: _filterStatus == SubjectStatus.taking,
                      onTap: () {
                        AppHaptics.selectionClick();
                        setState(() => _filterStatus = SubjectStatus.taking);
                      },
                    ),
                    AppSpacing.gapHorizontalSm,
                    AppChip(
                      label: 'Regulares',
                      isSelected: _filterStatus == SubjectStatus.regular,
                      onTap: () {
                        AppHaptics.selectionClick();
                        setState(() => _filterStatus = SubjectStatus.regular);
                      },
                    ),
                    AppSpacing.gapHorizontalSm,
                    AppChip(
                      label: 'Aprobadas',
                      isSelected: _filterStatus == SubjectStatus.passed,
                      onTap: () {
                        AppHaptics.selectionClick();
                        setState(() => _filterStatus = SubjectStatus.passed);
                      },
                    ),
                  ],
                ),
              ),
              AppSpacing.gapVerticalSm,

              // List of Subjects or Empty State
              Expanded(
                child: filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.book_outlined,
                        title: subjects.isEmpty ? 'No tienes materias agregadas' : 'No hay materias con este filtro',
                        subtitle: subjects.isEmpty
                            ? 'Agrega tus materias para comenzar a organizar tus parciales y notas.'
                            : 'Prueba cambiando o quitando el filtro de estado.',
                        actionLabel: subjects.isEmpty ? 'Nueva materia' : null,
                        onAction: subjects.isEmpty
                            ? () {
                                AppHaptics.selectionClick();
                                CreateEditSubjectSheet.show(context);
                              }
                            : null,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                          AppSpacing.xxl + 40, // Space for floating bottom bar
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final subject = filtered[index];
                          return SubjectCard(
                            subject: subject,
                            onTap: () {
                              AppHaptics.selectionClick();
                              context.push('/subjects/${subject.id}');
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
