import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import 'package:aula/app/router/routes.dart';
import 'package:aula/app/theme/theme_provider.dart';
import 'package:aula/core/design_system/components/app_button.dart';
import 'package:aula/core/design_system/components/app_card.dart';
import 'package:aula/core/design_system/components/app_chip.dart';
import 'package:aula/core/design_system/components/app_text_field.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:aula/features/profile/domain/entities/student_profile.dart';
import 'package:aula/features/profile/presentation/widgets/avatar_picker.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form Fields
  final _nameController = TextEditingController();
  final _careerController = TextEditingController();
  final _institutionController = TextEditingController();
  final _levelController = TextEditingController();
  final _periodController = TextEditingController(text: '1er cuatrimestre 2026');
  final _studentIdController = TextEditingController();
  final _emailController = TextEditingController();

  // Validation States
  String? _nameError;
  String? _careerError;
  String? _institutionError;

  // Profile preferences
  String? _avatarPath;
  double _passingGrade = 4.0;
  double _maxGrade = 10.0;
  String _gradeScaleType = 'numeric10';
  bool _notificationsEnabled = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _careerController.dispose();
    _institutionController.dispose();
    _levelController.dispose();
    _periodController.dispose();
    _studentIdController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _validateName(String val) {
    setState(() {
      _nameError = val.trim().isEmpty ? 'Ingresa tu nombre y apellido' : null;
    });
  }

  void _validateCareer(String val) {
    setState(() {
      _careerError = val.trim().isEmpty ? 'Ingresa tu carrera' : null;
    });
  }

  void _validateInstitution(String val) {
    setState(() {
      _institutionError = val.trim().isEmpty ? 'Ingresa tu facultad o universidad' : null;
    });
  }

  bool _isStep2Valid() {
    final nameOk = _nameController.text.trim().isNotEmpty;
    final careerOk = _careerController.text.trim().isNotEmpty;
    final instOk = _institutionController.text.trim().isNotEmpty;
    return nameOk && careerOk && instOk;
  }

  void _nextPage() {
    AppHaptics.selectionClick();
    if (_currentPage == 1) {
      _validateName(_nameController.text);
      _validateCareer(_careerController.text);
      _validateInstitution(_institutionController.text);
      if (!_isStep2Valid()) {
        AppHaptics.error();
        return;
      }
    }

    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    setState(() => _isSaving = true);
    final now = DateTime.now();

    final profile = StudentProfile(
      id: const Uuid().v4(),
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
      notificationsEnabled: _notificationsEnabled,
      createdAt: now,
      updatedAt: now,
    );

    final repo = ref.read(profileRepositoryProvider);
    final result = await repo.saveProfile(profile);

    if (result.isSuccess) {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setBool('has_completed_onboarding', true);
      unawaited(AppHaptics.success());
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } else {
      setState(() => _isSaving = false);
      unawaited(AppHaptics.error());
    }
  }

  String get _initials {
    final name = _nameController.text.trim();
    if (name.isEmpty) return 'A';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Step Progress Indicator
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: List.generate(4, (index) {
                  final isActive = index <= _currentPage;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 4,
                      margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: isActive
                            ? primary
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        borderRadius: AppRadius.borderFull,
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page View Content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Enforce step completion
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildWelcomeStep(theme, isDark, primary),
                  _buildStudentInfoStep(theme, isDark),
                  _buildAvatarStep(theme, isDark),
                  _buildPreferencesStep(theme, isDark, primary),
                ],
              ),
            ),

            // Bottom Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  if (_currentPage > 0) ...[
                    AppButton(
                      text: 'Atrás',
                      variant: AppButtonVariant.secondary,
                      onPressed: () {
                        AppHaptics.selectionClick();
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    AppSpacing.gapHorizontalMd,
                  ],
                  Expanded(
                    child: AppButton(
                      text: _currentPage == 3
                          ? 'Comenzar en Aula'
                          : (_currentPage == 2 && _avatarPath == null
                              ? 'Continuar con avatar'
                              : 'Continuar'),
                      isLoading: _isSaving,
                      onPressed: _nextPage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: Bienvenida
  Widget _buildWelcomeStep(ThemeData theme, bool isDark, Color primary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 48),
          Container(
            width: 96,
            height: 96,
            decoration: ShapeDecoration(
              color: primary.withValues(alpha: isDark ? 0.22 : 0.12),
              shape: AppRadius.continuousShape(AppRadius.xl),
            ),
            child: Icon(
              Icons.school_rounded,
              size: 52,
              color: primary,
            ),
          )
              .animate()
              .scale(duration: 400.ms, curve: Curves.easeOutBack)
              .fadeIn(duration: 300.ms),
          AppSpacing.gapVerticalXl,
          Text(
            'Bienvenido a Aula',
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1, end: 0),
          AppSpacing.gapVerticalSm,
          Text(
            'Tu vida académica organizada, 100% privada y offline.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ).animate().fadeIn(delay: 250.ms),
          AppSpacing.gapVerticalXl,
          AppCard(
            child: Column(
              children: [
                _buildValuePropRow(
                  Icons.lock_outline_rounded,
                  '100% Local y Seguro',
                  'Tus datos y notas nunca salen de tu teléfono sin tu autorización.',
                  primary,
                ),
                const Divider(height: 24),
                _buildValuePropRow(
                  Icons.notifications_active_outlined,
                  'Recordatorios Inteligentes',
                  'Avisos de parciales, entregas de TP y detección de conflictos.',
                  primary,
                ),
                const Divider(height: 24),
                _buildValuePropRow(
                  Icons.trending_up_rounded,
                  'Promedios y Metas',
                  'Cálculo ponderado en tiempo real y calculadora "¿qué nota necesito?".',
                  primary,
                ),
              ],
            ),
          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05, end: 0),
        ],
      ),
    );
  }

  Widget _buildValuePropRow(IconData icon, String title, String desc, Color primary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: primary),
        AppSpacing.gapHorizontalMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 13, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // STEP 2: Datos del Estudiante
  Widget _buildStudentInfoStep(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cuéntanos sobre tus estudios', style: theme.textTheme.titleLarge),
          AppSpacing.gapVerticalXs,
          Text(
            'Estos datos se usan para personalizar tus materias y reportes.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          AppSpacing.gapVerticalLg,
          AppTextField(
            controller: _nameController,
            label: 'Nombre y apellido *',
            hint: 'Ej. Mateo Rossi',
            errorText: _nameError,
            onChanged: _validateName,
            textInputAction: TextInputAction.next,
          ),
          AppSpacing.gapVerticalMd,
          AppTextField(
            controller: _careerController,
            label: 'Carrera *',
            hint: 'Ej. Licenciatura en Sistemas',
            errorText: _careerError,
            onChanged: _validateCareer,
            textInputAction: TextInputAction.next,
          ),
          AppSpacing.gapVerticalMd,
          AppTextField(
            controller: _institutionController,
            label: 'Instituto o Universidad *',
            hint: 'Ej. UBA - Exactas',
            errorText: _institutionError,
            onChanged: _validateInstitution,
            textInputAction: TextInputAction.next,
          ),
          AppSpacing.gapVerticalMd,
          AppTextField(
            controller: _periodController,
            label: 'Período actual',
            hint: 'Ej. 1er cuatrimestre 2026',
            textInputAction: TextInputAction.next,
          ),
          AppSpacing.gapVerticalMd,
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _levelController,
                  label: 'Nivel o año',
                  hint: 'Ej. 3er año',
                  textInputAction: TextInputAction.next,
                ),
              ),
              AppSpacing.gapHorizontalMd,
              Expanded(
                child: AppTextField(
                  controller: _studentIdController,
                  label: 'Matrícula / Legajo',
                  hint: 'Opcional',
                  textInputAction: TextInputAction.next,
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalMd,
          AppTextField(
            controller: _emailController,
            label: 'Email de contacto (opcional)',
            hint: 'estudiante@facultad.edu',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // STEP 3: Foto de Perfil
  Widget _buildAvatarStep(ThemeData theme, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text('Foto de perfil', style: theme.textTheme.titleLarge),
          AppSpacing.gapVerticalSm,
          Text(
            'Personalizá tu cuenta con una foto o continuá con tus iniciales.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          AppSpacing.gapVerticalXl,
          Center(
            child: AvatarPicker(
              initialRelativePath: _avatarPath,
              initials: _initials,
              size: 130,
              onAvatarChanged: (newPath) {
                setState(() => _avatarPath = newPath);
              },
            ),
          ),
          AppSpacing.gapVerticalXl,
          Text(
            _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Estudiante',
            style: theme.textTheme.titleMedium,
          ),
          if (_careerController.text.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _careerController.text.trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // STEP 4: Preferencias Iniciales
  Widget _buildPreferencesStep(ThemeData theme, bool isDark, Color primary) {
    final themeState = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preferencias iniciales', style: theme.textTheme.titleLarge),
          AppSpacing.gapVerticalXs,
          Text(
            'Ajustá cómo querés que se vea y funcione Aula.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          AppSpacing.gapVerticalLg,

          // Apariencia
          const Text('Tema', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          AppSpacing.gapVerticalSm,
          Row(
            children: [
              Expanded(
                child: AppChip(
                  label: 'Sistema',
                  isSelected: themeState.themeMode == ThemeMode.system,
                  leading: const Icon(Icons.brightness_auto_rounded, size: 16),
                  onTap: () => themeNotifier.setThemeMode(ThemeMode.system),
                ),
              ),
              AppSpacing.gapHorizontalSm,
              Expanded(
                child: AppChip(
                  label: 'Claro',
                  isSelected: themeState.themeMode == ThemeMode.light,
                  leading: const Icon(Icons.wb_sunny_rounded, size: 16),
                  onTap: () => themeNotifier.setThemeMode(ThemeMode.light),
                ),
              ),
              AppSpacing.gapHorizontalSm,
              Expanded(
                child: AppChip(
                  label: 'Oscuro',
                  isSelected: themeState.themeMode == ThemeMode.dark,
                  leading: const Icon(Icons.nightlight_round, size: 16),
                  onTap: () => themeNotifier.setThemeMode(ThemeMode.dark),
                ),
              ),
            ],
          ),
          AppSpacing.gapVerticalLg,

          // Color de Acento
          const Text('Color de acento', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          AppSpacing.gapVerticalSm,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppAccentColor.values.map((accent) {
              final isSelected = themeState.accentColor == accent;
              return GestureDetector(
                onTap: () => themeNotifier.setAccentColor(accent),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: isDark ? accent.dark : accent.light,
                    shape: AppRadius.continuousShape(AppRadius.sm),
                    shadows: isSelected
                        ? [
                            BoxShadow(
                              color: (isDark ? accent.dark : accent.light).withValues(alpha: 0.5),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                      : null,
                ),
              );
            }).toList(),
          ),
          AppSpacing.gapVerticalLg,

          // Escala de notas y aprobación
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Escala de notas', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
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
                Text(
                  'Nota mínima de aprobación: ${_passingGrade.toStringAsFixed(0)}',
                  style: theme.textTheme.bodyMedium,
                ),
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
          AppSpacing.gapVerticalMd,

          // Switch de notificaciones
          AppCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recordatorios de exámenes', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Avisos el día previo y la mañana de cada evaluación.'),
              value: _notificationsEnabled,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
