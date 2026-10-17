import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:aula/core/design_system/components/app_button.dart';
import 'package:aula/core/design_system/components/app_chip.dart';
import 'package:aula/core/design_system/components/app_text_field.dart';
import 'package:aula/core/design_system/components/spring_sheet.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/subjects/data/repositories/subjects_repository_impl.dart';
import 'package:aula/features/subjects/domain/entities/subject.dart';
import 'package:aula/features/subjects/presentation/widgets/subject_color_picker.dart';
import 'package:aula/features/subjects/presentation/widgets/subject_icon_picker.dart';

class CreateEditSubjectSheet extends ConsumerStatefulWidget {
  const CreateEditSubjectSheet({
    super.key,
    this.initialSubject,
  });

  final Subject? initialSubject;

  static Future<void> show(BuildContext context, {Subject? initialSubject}) {
    return SpringSheet.show(
      context: context,
      snapFractions: const [0.88, 0.95],
      initialFractionIndex: 0,
      title: initialSubject == null ? 'Nueva Materia' : 'Editar Materia',
      child: CreateEditSubjectSheet(initialSubject: initialSubject),
    );
  }

  @override
  ConsumerState<CreateEditSubjectSheet> createState() => _CreateEditSubjectSheetState();
}

class _CreateEditSubjectSheetState extends ConsumerState<CreateEditSubjectSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _professorController;
  late final TextEditingController _classroomController;
  late final TextEditingController _periodController;
  late final TextEditingController _creditsController;
  late final TextEditingController _customPassingGradeController;
  late final TextEditingController _notesController;

  late int _selectedColor;
  late String _selectedIconName;
  late SubjectStatus _selectedStatus;
  String? _nameError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.initialSubject;
    _nameController = TextEditingController(text: s?.name ?? '');
    _codeController = TextEditingController(text: s?.code ?? '');
    _professorController = TextEditingController(text: s?.professor ?? '');
    _classroomController = TextEditingController(text: s?.classroom ?? '');
    _periodController = TextEditingController(text: s?.period ?? '');
    _creditsController = TextEditingController(text: s?.credits != null ? s!.credits.toString() : '');
    _customPassingGradeController = TextEditingController(
      text: s?.customPassingGrade != null ? s!.customPassingGrade.toString() : '',
    );
    _notesController = TextEditingController(text: s?.notes ?? '');

    _selectedColor = s?.colorValue ?? AppColors.subjectPalette.first.toARGB32();
    _selectedIconName = s?.iconName ?? 'book';
    _selectedStatus = s?.status ?? SubjectStatus.taking;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _professorController.dispose();
    _classroomController.dispose();
    _periodController.dispose();
    _creditsController.dispose();
    _customPassingGradeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _validateName(String val) {
    setState(() {
      _nameError = val.trim().isEmpty ? 'Ingresa el nombre de la materia' : null;
    });
  }

  Future<void> _save() async {
    _validateName(_nameController.text);
    if (_nameError != null || _nameController.text.trim().isEmpty) {
      unawaited(AppHaptics.error());
      return;
    }

    setState(() => _isSaving = true);
    final now = DateTime.now();

    final int? credits = int.tryParse(_creditsController.text.trim());
    final double? customPassingGrade = double.tryParse(_customPassingGradeController.text.trim());

    final subject = (widget.initialSubject ??
            Subject(
              id: const Uuid().v4(),
              name: '',
              colorValue: _selectedColor,
              createdAt: now,
              updatedAt: now,
            ))
        .copyWith(
      name: _nameController.text.trim(),
      code: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
      colorValue: _selectedColor,
      iconName: _selectedIconName,
      professor: _professorController.text.trim().isEmpty ? null : _professorController.text.trim(),
      classroom: _classroomController.text.trim().isEmpty ? null : _classroomController.text.trim(),
      period: _periodController.text.trim().isEmpty ? null : _periodController.text.trim(),
      credits: credits,
      status: _selectedStatus,
      customPassingGrade: customPassingGrade,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      updatedAt: now,
    );

    final repo = ref.read(subjectsRepositoryProvider);
    final result = widget.initialSubject == null
        ? await repo.createSubject(subject)
        : await repo.updateSubject(subject);

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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppTextField(
            controller: _nameController,
            label: 'Nombre de la materia *',
            hint: 'Ej. Análisis Matemático II',
            errorText: _nameError,
            onChanged: _validateName,
            textInputAction: TextInputAction.next,
          ),
          AppSpacing.gapVerticalMd,
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _codeController,
                  label: 'Código (opcional)',
                  hint: 'Ej. MAT-201',
                  textInputAction: TextInputAction.next,
                ),
              ),
              AppSpacing.gapHorizontalMd,
              Expanded(
                child: AppTextField(
                  controller: _creditsController,
                  label: 'Créditos',
                  hint: 'Ej. 6',
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalLg,

          // Color & Icon
          SubjectColorPicker(
            selectedColor: _selectedColor,
            onColorChanged: (newColor) => setState(() => _selectedColor = newColor),
          ),
          AppSpacing.gapVerticalLg,

          SubjectIconPicker(
            selectedIconName: _selectedIconName,
            tintColor: Color(_selectedColor),
            onIconChanged: (newIcon) => setState(() => _selectedIconName = newIcon),
          ),
          AppSpacing.gapVerticalLg,

          // Estado
          const Text('Estado de cursada', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          AppSpacing.gapVerticalSm,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SubjectStatus.values.map((status) {
              final isSelected = _selectedStatus == status;
              return AppChip(
                label: status.label,
                isSelected: isSelected,
                customColor: Color(_selectedColor),
                onTap: () {
                  AppHaptics.selectionClick();
                  setState(() => _selectedStatus = status);
                },
              );
            }).toList(),
          ),
          AppSpacing.gapVerticalLg,

          // Docente y Aula
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _professorController,
                  label: 'Docente / Cátedra',
                  hint: 'Ej. Dr. Turing',
                  textInputAction: TextInputAction.next,
                ),
              ),
              AppSpacing.gapHorizontalMd,
              Expanded(
                child: AppTextField(
                  controller: _classroomController,
                  label: 'Aula / Modalidad',
                  hint: 'Ej. Aula 104',
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalMd,

          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _periodController,
                  label: 'Período',
                  hint: 'Ej. 2026-1',
                  textInputAction: TextInputAction.next,
                ),
              ),
              AppSpacing.gapHorizontalMd,
              Expanded(
                child: AppTextField(
                  controller: _customPassingGradeController,
                  label: 'Nota mínima de aprobación',
                  hint: 'Por defecto (4)',
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalMd,

          AppTextField(
            controller: _notesController,
            label: 'Notas libres / Observaciones',
            hint: 'Links de Drive, bibliografía, reglas de cátedra...',
            maxLines: 3,
            minLines: 2,
          ),
          AppSpacing.gapVerticalXl,

          AppButton(
            text: widget.initialSubject == null ? 'Crear Materia' : 'Guardar Cambios',
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
