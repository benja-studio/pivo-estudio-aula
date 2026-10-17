import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:aula/core/design_system/components/app_button.dart';
import 'package:aula/core/design_system/components/app_chip.dart';
import 'package:aula/core/design_system/components/empty_state.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:aula/features/exams/domain/entities/exam.dart';
import 'package:aula/features/exams/presentation/sheets/create_edit_exam_sheet.dart';
import 'package:aula/features/exams/presentation/widgets/exam_card.dart';
import 'package:aula/features/subjects/data/repositories/subjects_repository_impl.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  int _viewMode = 0; // 0 = Vista Mensual, 1 = Vista Agenda Cronológica
  String? _filterSubjectId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final examsAsync = ref.watch(allExamsProvider);
    final subjectsAsync = ref.watch(activeSubjectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendario y Agenda'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppButton(
              text: 'Examen',
              icon: const Icon(Icons.add_rounded, size: 18),
              size: AppButtonSize.sm,
              onPressed: () {
                AppHaptics.selectionClick();
                CreateEditExamSheet.show(context);
              },
            ),
          ),
        ],
      ),
      body: examsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error al cargar calendario: $err')),
        data: (allExams) {
          final exams = _filterSubjectId == null
              ? allExams
              : allExams.where((e) => e.subjectId == _filterSubjectId).toList();

          return Column(
            children: [
              // View Switcher (Mensual / Agenda)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Expanded(
                      child: AppChip(
                        label: 'Mes',
                        isSelected: _viewMode == 0,
                        leading: const Icon(Icons.calendar_view_month_rounded, size: 16),
                        onTap: () {
                          AppHaptics.selectionClick();
                          setState(() => _viewMode = 0);
                        },
                      ),
                    ),
                    AppSpacing.gapHorizontalSm,
                    Expanded(
                      child: AppChip(
                        label: 'Agenda',
                        isSelected: _viewMode == 1,
                        leading: const Icon(Icons.view_agenda_rounded, size: 16),
                        onTap: () {
                          AppHaptics.selectionClick();
                          setState(() => _viewMode = 1);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Subject filter chips if subjects exist
              subjectsAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (subjects) {
                  if (subjects.isEmpty) return const SizedBox.shrink();
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
                    child: Row(
                      children: [
                        AppChip(
                          label: 'Todas',
                          isSelected: _filterSubjectId == null,
                          onTap: () => setState(() => _filterSubjectId = null),
                        ),
                        ...subjects.map((s) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: AppChip(
                              label: s.name,
                              isSelected: _filterSubjectId == s.id,
                              customColor: Color(s.colorValue),
                              onTap: () => setState(() => _filterSubjectId = s.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
              AppSpacing.gapVerticalSm,

              // Content based on view mode
              Expanded(
                child: _viewMode == 0
                    ? _buildMonthView(context, isDark, primary, exams)
                    : _buildAgendaView(context, isDark, exams),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMonthView(BuildContext context, bool isDark, Color primary, List<Exam> exams) {
    final now = _selectedDate;
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    final monthHeader = DateFormat('MMMM yyyy', 'es').format(now);

    final selectedDayExams = exams.where((e) {
      return e.dateTime.year == _selectedDate.year &&
          e.dateTime.month == _selectedDate.month &&
          e.dateTime.day == _selectedDate.day;
    }).toList();

    return Column(
      children: [
        // Month navigation row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () {
                  AppHaptics.selectionClick();
                  setState(() => _selectedDate = DateTime(now.year, now.month - 1, 1));
                },
              ),
              Text(
                monthHeader.substring(0, 1).toUpperCase() + monthHeader.substring(1),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded),
                onPressed: () {
                  AppHaptics.selectionClick();
                  setState(() => _selectedDate = DateTime(now.year, now.month + 1, 1));
                },
              ),
            ],
          ),
        ),

        // Day of week abbreviations
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((d) {
              return SizedBox(
                width: 38,
                child: Center(
                  child: Text(
                    d,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 6),

        // Calendar Grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 35, // 5 weeks display
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final dayOffset = index - (startingWeekday - 1);
              if (dayOffset < 0 || dayOffset >= daysInMonth) {
                return const SizedBox.shrink();
              }

              final day = dayOffset + 1;
              final cellDate = DateTime(now.year, now.month, day);
              final isSelected = cellDate.year == _selectedDate.year &&
                  cellDate.month == _selectedDate.month &&
                  cellDate.day == _selectedDate.day;

              // Check if any exam is scheduled on this cell
              final dayExams = exams.where((e) {
                return e.dateTime.year == cellDate.year &&
                    e.dateTime.month == cellDate.month &&
                    e.dateTime.day == cellDate.day;
              }).toList();

              return GestureDetector(
                onTap: () {
                  AppHaptics.selectionClick();
                  setState(() => _selectedDate = cellDate);
                },
                child: Container(
                  decoration: ShapeDecoration(
                    color: isSelected
                        ? primary
                        : (isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface),
                    shape: AppRadius.continuousShape(
                      AppRadius.sm,
                      side: BorderSide(
                        color: isSelected
                            ? primary
                            : (dayExams.isNotEmpty
                                ? AppColors.info
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
                        width: dayExams.isNotEmpty ? 1.2 : 0.8,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                      if (dayExams.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : AppColors.info,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const Divider(height: 24),

        // Events on selected day
        Expanded(
          child: selectedDayExams.isEmpty
              ? Center(
                  child: Text(
                    'No hay evaluaciones el ${DateFormat("d 'de' MMMM", "es").format(_selectedDate)}',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl + 40),
                  itemCount: selectedDayExams.length,
                  itemBuilder: (context, index) {
                    final exam = selectedDayExams[index];
                    return ExamCard(
                      exam: exam,
                      onTap: () => context.push('/exams/${exam.id}'),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildAgendaView(BuildContext context, bool isDark, List<Exam> exams) {
    if (exams.isEmpty) {
      return const EmptyState(
        icon: Icons.event_available_outlined,
        title: 'No hay eventos en la agenda',
        subtitle: 'Crea evaluaciones con fecha para ver tu cronograma.',
      );
    }

    // Sort chronologically
    final sorted = List<Exam>.from(exams)..sort((a, b) => a.dateTime.compareTo(b.dateTime));

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xxl + 40),
      itemCount: sorted.length,
      itemBuilder: (context, index) {
        final exam = sorted[index];
        return ExamCard(
          exam: exam,
          onTap: () => context.push('/exams/${exam.id}'),
        );
      },
    );
  }
}
