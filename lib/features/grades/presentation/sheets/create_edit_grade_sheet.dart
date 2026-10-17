import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:aula/core/design_system/components/app_button.dart';
import 'package:aula/core/design_system/components/app_chip.dart';
import 'package:aula/core/design_system/components/app_text_field.dart';
import 'package:aula/core/design_system/components/spring_sheet.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/exams/data/repositories/exams_repository_impl.dart';
import 'package:aula/features/grades/data/repositories/grades_repository_impl.dart';
import 'package:aula/features/grades/domain/entities/grade_entry.dart';
import 'package:aula/features/subjects/data/repositories/subjects_repository_impl.dart';

class CreateEditGradeSheet extends ConsumerStatefulWidget {
  const CreateEditGradeSheet({
    super.key,
    this.initialGrade,
    this.preselectedSubjectId,
    this.preselectedExamId,
    this.prefilledTitle,
  });

  final GradeEntry? initialGrade;
  final String? preselectedSubjectId;
  final String? preselectedExamId;
  final String? prefilledTitle;

  static Future<void> show(
    BuildContext context, {
    GradeEntry? initialGrade,
    String? preselectedSubjectId,
    String? preselectedExamId,
    String? prefilledTitle,
  }) {
    return SpringSheet.show(
      context: context,
      snapFractions: const [0.85, 0.95],
      title: initialGrade == null ? 'Cargar Nota' : 'Editar Nota',
      child: CreateEditGradeSheet(
        initialGrade: initialGrade,
        preselectedSubjectId: preselectedSubjectId,
        preselectedExamId: preselectedExamId,
        prefilledTitle: prefilledTitle,
      ),
    );
  }

  @override
  ConsumerState<CreateEditGradeSheet> createState() => _CreateEditGradeSheetState();
}

class _CreateEditGradeSheetState extends ConsumerState<CreateEditGradeSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _valueController;
  late final TextEditingController _weightController;

  String? _selectedSubjectId;
  String? _selectedExamId;
  late GradeKind _selectedKind;
  late DateTime _selectedDate;

  String? _titleError;
  String? _valueError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final g = widget.initialGrade;
    _titleController = TextEditingController(text: g?.title ?? widget.prefilledTitle ?? '');
    _valueController = TextEditingController(text: g != null ? g.value.toString() : '');
    _weightController = TextEditingController(text: (g?.weight ?? 1.0).toString());

    _selectedSubjectId = g?.subjectId ?? widget.preselectedSubjectId;
    _selectedExamId = g?.examId ?? widget.preselectedExamId;
    _selectedKind = g?.kind ?? GradeKind.exam;
    _selectedDate = g?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _valueController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _validate() {
    setState(() {
      _titleError = _titleController.text.trim().isEmpty ? 'Ingresa el nombre de la evaluación' : null;
      final val = double.tryParse(_valueController.text.trim());
      _valueError = (val == null || val < 0 || val > 100) ? 'Ingresa una calificación válida' : null;
    });
  }

  Future<void> _save() async {
    _validate();
    if (_titleError != null || _valueError != null) {
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
    final double value = double.parse(_valueController.text.trim());
    final double weight = double.tryParse(_weightController.text.trim()) ?? 1.0;

    final grade = (widget.initialGrade ??
            GradeEntry(
              id: const Uuid().v4(),
              subjectId: _selectedSubjectId!,
              title: '',
              value: 0.0,
              date: _selectedDate,
              createdAt: now,
              updatedAt: now,
            ))
        .copyWith(
      subjectId: _selectedSubjectId,
      examId: _selectedExamId,
      title: _titleController.text.trim(),
      value: value,
      weight: weight,
      kind: _selectedKind,
      date: _selectedDate,
      updatedAt: now,
    );

    final repo = ref.read(gradesRepositoryProvider);
    final result = widget.initialGrade == null
        ? await repo.createGrade(grade)
        : await repo.updateGrade(grade);

    if (result.isSuccess) {
      unawaited(AppHaptics.success());
      if (mounted) Navigator.pop(context);
    } else {
      setState(() => _isSaving = false);
      unawaited(AppHaptics.error());
    }
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(activeSubjectsProvider);
    final allExamsAsync = ref.watch(allExamsProvider);
    final dateFormatter = DateFormat('EEE d MMM yyyy', 'es');

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Materia selector
          const Text('Materia *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          AppSpacing.gapVerticalSm,
          subjectsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Text('Error al cargar materias'),
            data: (subjects) {
              if (subjects.isEmpty) return const Text('No hay materias registradas.');
              _selectedSubjectId ??= subjects.first.id;

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

          // Tipo de nota
          const Text('Tipo de evaluación', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          AppSpacing.gapVerticalSm,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GradeKind.values.map((k) {
              return AppChip(
                label: k.label,
                isSelected: _selectedKind == k,
                onTap: () => setState(() => _selectedKind = k),
              );
            }).toList(),
          ),
          AppSpacing.gapVerticalLg,

          // Vincular con examen opcional
          allExamsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (exams) {
              final subjectExams = exams.where((e) => e.subjectId == _selectedSubjectId).toList();
              if (subjectExams.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Vincular a un examen programado (opcional)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  AppSpacing.gapVerticalXs,
                  DropdownButton<String?>(
                    value: _selectedExamId,
                    isExpanded: true,
                    hint: const Text('Nota suelta / Sin vincular'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Nota suelta (sin vincular)')),
                      ...subjectExams.map((e) => DropdownMenuItem(value: e.id, child: Text(e.title))),
                    ],
                    onChanged: (val) {
                      setState(() {
                        _selectedExamId = val;
                        if (val != null) {
                          final match = subjectExams.firstWhere((e) => e.id == val);
                          _titleController.text = match.title;
                        }
                      });
                    },
                  ),
                  AppSpacing.gapVerticalMd,
                ],
              );
            },
          ),

          AppTextField(
            controller: _titleController,
            label: 'Título / Concepto de la nota *',
            hint: 'Ej. 1er Parcial, TP Integrador',
            errorText: _titleError,
            textInputAction: TextInputAction.next,
          ),
          AppSpacing.gapVerticalMd,

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _valueController,
                  label: 'Calificación obtenida *',
                  hint: 'Ej. 8.5',
                  errorText: _valueError,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                ),
              ),
              AppSpacing.gapHorizontalMd,
              Expanded(
                child: AppTextField(
                  controller: _weightController,
                  label: 'Ponderación / Peso',
                  hint: '1.0 (normal) o 2.0',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalMd,

          // Fecha
          const Text('Fecha de la nota', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          AppSpacing.gapVerticalSm,
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2035),
              );
              if (picked != null) setState(() => _selectedDate = picked);
            },
            borderRadius: AppRadius.borderMd,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                borderRadius: AppRadius.borderMd,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 18),
                  AppSpacing.gapHorizontalMd,
                  Text(dateFormatter.format(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          AppSpacing.gapVerticalXl,

          AppButton(
            text: widget.initialGrade == null ? 'Guardar Nota' : 'Actualizar Nota',
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
