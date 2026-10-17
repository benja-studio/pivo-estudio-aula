import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:aula/core/design_system/components/app_button.dart';
import 'package:aula/core/design_system/components/app_chip.dart';
import 'package:aula/core/design_system/components/app_text_field.dart';
import 'package:aula/core/design_system/components/spring_sheet.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:aula/features/exams/domain/entities/exam.dart';
import 'package:aula/features/subjects/data/repositories/subjects_repository_impl.dart';

class CreateEditExamSheet extends ConsumerStatefulWidget {
  const CreateEditExamSheet({
    super.key,
    this.initialExam,
    this.preselectedSubjectId,
  });

  final Exam? initialExam;
  final String? preselectedSubjectId;

  static Future<void> show(
    BuildContext context, {
    Exam? initialExam,
    String? preselectedSubjectId,
  }) {
    return SpringSheet.show(
      context: context,
      snapFractions: const [0.88, 0.95],
      initialFractionIndex: 0,
      title: initialExam == null ? 'Nueva Evaluación' : 'Editar Evaluación',
      child: CreateEditExamSheet(
        initialExam: initialExam,
        preselectedSubjectId: preselectedSubjectId,
      ),
    );
  }

  @override
  ConsumerState<CreateEditExamSheet> createState() => _CreateEditExamSheetState();
}

class _CreateEditExamSheetState extends ConsumerState<CreateEditExamSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _classroomController;
  late final TextEditingController _durationController;
  late final TextEditingController _notesController;

  String? _selectedSubjectId;
  late ExamType _selectedType;
  late DateTime _selectedDateTime;
  String? _retakeOfExamId;
  String _retakeRule = 'replace'; // 'replace' or 'average'
  bool _reminderEnabled = true;

  String? _titleError;
  bool _isSaving = false;
  List<Exam> _conflicts = [];

  @override
  void initState() {
    super.initState();
    final e = widget.initialExam;
    _titleController = TextEditingController(text: e?.title ?? '');
    _classroomController = TextEditingController(text: e?.classroom ?? '');
    _durationController = TextEditingController(text: (e?.durationMinutes ?? 120).toString());
    _notesController = TextEditingController(text: e?.notes ?? '');

    _selectedSubjectId = e?.subjectId ?? widget.preselectedSubjectId;
    _selectedType = e?.type ?? ExamType.midterm;
    _selectedDateTime = e?.dateTime ?? DateTime.now().add(const Duration(days: 7));
    _retakeOfExamId = e?.retakeOfExamId;
    _retakeRule = e?.retakeRule ?? 'replace';
    _reminderEnabled = e?.reminderEnabled ?? true;

    WidgetsBinding.instance.addPostFrameCallback((_) => _checkConflicts());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _classroomController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _checkConflicts() async {
    final duration = int.tryParse(_durationController.text.trim()) ?? 120;
    final candidate = Exam(
      id: widget.initialExam?.id ?? 'temp-candidate',
      subjectId: _selectedSubjectId ?? '',
      type: _selectedType,
      title: _titleController.text.trim(),
      dateTime: _selectedDateTime,
      durationMinutes: duration,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final repo = ref.read(examsRepositoryProvider);
    final result = await repo.findConflictingExams(candidate);
    if (mounted && result.isSuccess) {
      setState(() => _conflicts = result.dataOrNull ?? []);
    }
  }

  void _validateTitle(String val) {
    setState(() {
      _titleError = val.trim().isEmpty ? 'Ingresa el título de la evaluación' : null;
    });
  }

  Future<void> _pickDateTime() async {
    await AppHaptics.selectionClick();
    if (!mounted) return;
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null || !mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
    await _checkConflicts();
  }

  Future<void> _save() async {
    _validateTitle(_titleController.text);
    if (_titleError != null || _titleController.text.trim().isEmpty) {
      unawaited(AppHaptics.error());
      return;
    }

    if (_selectedSubjectId == null || _selectedSubjectId!.isEmpty) {
      unawaited(AppHaptics.error());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una materia')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now();
    final duration = int.tryParse(_durationController.text.trim()) ?? 120;

    final exam = (widget.initialExam ??
            Exam(
              id: const Uuid().v4(),
              subjectId: _selectedSubjectId!,
              type: _selectedType,
              title: '',
              dateTime: _selectedDateTime,
              createdAt: now,
              updatedAt: now,
            ))
        .copyWith(
      subjectId: _selectedSubjectId,
      type: _selectedType,
      title: _titleController.text.trim(),
      dateTime: _selectedDateTime,
      durationMinutes: duration,
      classroom: _classroomController.text.trim().isEmpty ? null : _classroomController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      retakeOfExamId: _selectedType == ExamType.retake ? _retakeOfExamId : null,
      retakeRule: _selectedType == ExamType.retake ? _retakeRule : 'replace',
      reminderEnabled: _reminderEnabled,
      updatedAt: now,
    );

    final repo = ref.read(examsRepositoryProvider);
    final result = widget.initialExam == null
        ? await repo.createExam(exam)
        : await repo.updateExam(exam);

    if (result.isSuccess) {
      unawaited(AppHaptics.success());
      if (mounted) {
        Navigator.pop(context);
      }
    } else {
      setState(() => _isSaving = false);
      unawaited(AppHaptics.error());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subjectsAsync = ref.watch(activeSubjectsProvider);
    final allExamsAsync = ref.watch(allExamsProvider);
    final dateFormatter = DateFormat('EEE d MMM yyyy, HH:mm', 'es');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Conflict notice if any
          if (_conflicts.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: ShapeDecoration(
                color: AppColors.warning.withValues(alpha: isDark ? 0.22 : 0.12),
                shape: AppRadius.continuousShape(AppRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  AppSpacing.gapHorizontalMd,
                  Expanded(
                    child: Text(
                      'Aviso: Ya tienes ${_conflicts.length} evaluación programada en este horario (${_conflicts.first.title}).',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFFDE68A) : AppColors.warningDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Materia selector
          const Text('Materia *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          AppSpacing.gapVerticalSm,
          subjectsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error al cargar materias'),
            data: (subjects) {
              if (subjects.isEmpty) {
                return const Text('Primero debes crear una materia en Aula.');
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subjects.map((s) {
                  final isSelected = _selectedSubjectId == s.id;
                  final color = Color(s.colorValue);
                  return AppChip(
                    label: s.name,
                    isSelected: isSelected,
                    customColor: color,
                    onTap: () {
                      AppHaptics.selectionClick();
                      setState(() => _selectedSubjectId = s.id);
                    },
                  );
                }).toList(),
              );
            },
          ),
          AppSpacing.gapVerticalLg,

          // Tipo de evaluación
          const Text('Tipo de evaluación', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          AppSpacing.gapVerticalSm,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ExamType.values.map((type) {
              final isSelected = _selectedType == type;
              return AppChip(
                label: type.label,
                isSelected: isSelected,
                onTap: () {
                  AppHaptics.selectionClick();
                  setState(() => _selectedType = type);
                },
              );
            }).toList(),
          ),
          AppSpacing.gapVerticalLg,

          // Si es recuperatorio: vincular con parcial y regla
          if (_selectedType == ExamType.retake) ...[
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: ShapeDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceHigher,
                shape: AppRadius.continuousShape(AppRadius.md),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vincular con el examen que recupera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  AppSpacing.gapVerticalSm,
                  allExamsAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (exams) {
                      final subjectExams = exams.where((e) => e.subjectId == _selectedSubjectId && e.id != widget.initialExam?.id).toList();
                      if (subjectExams.isEmpty) {
                        return const Text('No hay otros exámenes en esta materia para vincular.');
                      }
                      return DropdownButton<String>(
                        value: _retakeOfExamId,
                        isExpanded: true,
                        hint: const Text('Selecciona el parcial a recuperar'),
                        items: subjectExams.map((e) {
                          return DropdownMenuItem(value: e.id, child: Text(e.title));
                        }).toList(),
                        onChanged: (val) => setState(() => _retakeOfExamId = val),
                      );
                    },
                  ),
                  AppSpacing.gapVerticalMd,
                  const Text('Regla de calificación', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  AppSpacing.gapVerticalXs,
                  Row(
                    children: [
                      AppChip(
                        label: 'Reemplaza la nota original',
                        isSelected: _retakeRule == 'replace',
                        onTap: () => setState(() => _retakeRule = 'replace'),
                      ),
                      AppSpacing.gapHorizontalSm,
                      AppChip(
                        label: 'Se promedia',
                        isSelected: _retakeRule == 'average',
                        onTap: () => setState(() => _retakeRule = 'average'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            AppSpacing.gapVerticalLg,
          ],

          AppTextField(
            controller: _titleController,
            label: 'Título de la evaluación *',
            hint: 'Ej. Primer Parcial (Teoría y Práctica)',
            errorText: _titleError,
            onChanged: _validateTitle,
            textInputAction: TextInputAction.next,
          ),
          AppSpacing.gapVerticalMd,

          // Date & Time Picker Row
          const Text('Fecha y hora', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          AppSpacing.gapVerticalSm,
          InkWell(
            onTap: _pickDateTime,
            borderRadius: AppRadius.borderMd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: ShapeDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
                shape: AppRadius.continuousShape(
                  AppRadius.md,
                  side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder, width: 1.0),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 20),
                  AppSpacing.gapHorizontalMd,
                  Text(dateFormatter.format(_selectedDateTime), style: const TextStyle(fontWeight: FontWeight.w600)),
                  const Spacer(),
                  const Text('Cambiar', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.info)),
                ],
              ),
            ),
          ),
          AppSpacing.gapVerticalMd,

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _durationController,
                  label: 'Duración (minutos)',
                  hint: '120',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => _checkConflicts(),
                  textInputAction: TextInputAction.next,
                ),
              ),
              AppSpacing.gapHorizontalMd,
              Expanded(
                child: AppTextField(
                  controller: _classroomController,
                  label: 'Aula / Lugar',
                  hint: 'Ej. Aula Magna',
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalMd,

          AppTextField(
            controller: _notesController,
            label: 'Notas / Observaciones',
            hint: 'Llevar calculadora científica, tabla periódica...',
            maxLines: 2,
          ),
          AppSpacing.gapVerticalMd,

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Recordatorios locales', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: const Text('Notificar 1 día antes y la mañana del examen'),
            value: _reminderEnabled,
            onChanged: (val) => setState(() => _reminderEnabled = val),
          ),
          AppSpacing.gapVerticalXl,

          AppButton(
            text: widget.initialExam == null ? 'Crear Evaluación' : 'Guardar Cambios',
            isLoading: _isSaving,
            onPressed: _save,
            isFullWidth: true,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
