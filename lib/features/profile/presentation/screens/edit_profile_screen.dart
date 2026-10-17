import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aula/core/design_system/components/app_button.dart';
import 'package:aula/core/design_system/components/app_card.dart';
import 'package:aula/core/design_system/components/app_chip.dart';
import 'package:aula/core/design_system/components/app_text_field.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:aula/features/profile/domain/entities/student_profile.dart';
import 'package:aula/features/profile/presentation/widgets/avatar_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, this.initialProfile});

  final StudentProfile? initialProfile;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _careerController;
  late final TextEditingController _institutionController;
  late final TextEditingController _levelController;
  late final TextEditingController _periodController;
  late final TextEditingController _studentIdController;
  late final TextEditingController _emailController;

  String? _avatarPath;
  late double _passingGrade;
  late double _maxGrade;
  late String _gradeScaleType;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.initialProfile;
    _nameController = TextEditingController(text: p?.fullName ?? '');
    _careerController = TextEditingController(text: p?.career ?? '');
    _institutionController = TextEditingController(text: p?.institution ?? '');
    _levelController = TextEditingController(text: p?.academicLevel ?? '');
    _periodController = TextEditingController(text: p?.currentPeriod ?? '');
    _studentIdController = TextEditingController(text: p?.studentId ?? '');
    _emailController = TextEditingController(text: p?.email ?? '');

    _avatarPath = p?.avatarPath;
    _passingGrade = p?.passingGrade ?? 4.0;
    _maxGrade = p?.maxGrade ?? 10.0;
    _gradeScaleType = p?.gradeScaleType ?? 'numeric10';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _careerController.dispose();
    _institutionController.dispose();
    _levelController.dispose();
    _periodController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  String get _initials {
    final name = _nameController.text.trim();
    if (name.isEmpty) return 'A';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  Future<void> _saveChanges() async {
    if (_nameController.text.trim().isEmpty ||
        _careerController.text.trim().isEmpty ||
        _institutionController.text.trim().isEmpty) {
      unawaited(AppHaptics.error());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa los campos obligatorios')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final current = widget.initialProfile;
    final updated = (current ??
            StudentProfile(
              id: 'prof-1',
              fullName: '',
              career: '',
              institution: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ))
        .copyWith(
      fullName: _nameController.text.trim(),
      career: _careerController.text.trim(),
      institution: _institutionController.text.trim(),
      academicLevel: _levelController.text.trim().isEmpty ? null : _levelController.text.trim(),
      studentId: _studentIdController.text.trim().isEmpty ? null : _studentIdController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      currentPeriod: _periodController.text.trim().isEmpty ? null : _periodController.text.trim(),
      avatarPath: _avatarPath,
      passingGrade: _passingGrade,
      maxGrade: _maxGrade,
      gradeScaleType: _gradeScaleType,
      updatedAt: DateTime.now(),
    );

    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.saveProfile(updated);

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: AppButton(
              text: 'Guardar',
              size: AppButtonSize.sm,
              isLoading: _isSaving,
              onPressed: _saveChanges,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Center(
              child: AvatarPicker(
                initialRelativePath: _avatarPath,
                initials: _initials,
                size: 110,
                onAvatarChanged: (newPath) => setState(() => _avatarPath = newPath),
              ),
            ),
            AppSpacing.gapVerticalLg,
            AppTextField(
              controller: _nameController,
              label: 'Nombre y apellido *',
              textInputAction: TextInputAction.next,
            ),
            AppSpacing.gapVerticalMd,
            AppTextField(
              controller: _careerController,
              label: 'Carrera *',
              textInputAction: TextInputAction.next,
            ),
            AppSpacing.gapVerticalMd,
            AppTextField(
              controller: _institutionController,
              label: 'Instituto o Universidad *',
              textInputAction: TextInputAction.next,
            ),
            AppSpacing.gapVerticalMd,
            AppTextField(
              controller: _periodController,
              label: 'Período académico actual',
              textInputAction: TextInputAction.next,
            ),
            AppSpacing.gapVerticalMd,
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: _levelController,
                    label: 'Nivel o año',
                    textInputAction: TextInputAction.next,
                  ),
                ),
                AppSpacing.gapHorizontalMd,
                Expanded(
                  child: AppTextField(
                    controller: _studentIdController,
                    label: 'Legajo / Matrícula',
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            AppSpacing.gapVerticalMd,
            AppTextField(
              controller: _emailController,
              label: 'Email de contacto',
              keyboardType: TextInputType.emailAddress,
            ),
            AppSpacing.gapVerticalLg,
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Escala de notas', style: TextStyle(fontWeight: FontWeight.w600)),
                  AppSpacing.gapVerticalSm,
                  Row(
                    children: [
                      AppChip(
                        label: '1 a 10',
                        isSelected: _gradeScaleType == 'numeric10',
                        onTap: () => setState(() {
                          _gradeScaleType = 'numeric10';
                          _passingGrade = 4.0;
                          _maxGrade = 10.0;
                        }),
                      ),
                      AppSpacing.gapHorizontalSm,
                      AppChip(
                        label: '0 a 100',
                        isSelected: _gradeScaleType == 'numeric100',
                        onTap: () => setState(() {
                          _gradeScaleType = 'numeric100';
                          _passingGrade = 60.0;
                          _maxGrade = 100.0;
                        }),
                      ),
                    ],
                  ),
                  AppSpacing.gapVerticalMd,
                  Text('Nota mínima de aprobación: ${_passingGrade.toStringAsFixed(0)}'),
                  Slider(
                    value: _passingGrade,
                    min: _gradeScaleType == 'numeric10' ? 1.0 : 10.0,
                    max: _gradeScaleType == 'numeric10' ? 9.0 : 90.0,
                    divisions: _gradeScaleType == 'numeric10' ? 8 : 16,
                    onChanged: (val) => setState(() => _passingGrade = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
