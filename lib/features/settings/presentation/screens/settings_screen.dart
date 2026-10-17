import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:aula/app/router/routes.dart';
import 'package:aula/app/theme/theme_provider.dart';
import 'package:aula/core/design_system/components/app_button.dart';
import 'package:aula/core/design_system/components/app_card.dart';
import 'package:aula/core/design_system/components/app_text_field.dart';
import 'package:aula/core/design_system/components/pressable_scale.dart';
import 'package:aula/core/design_system/components/spring_sheet.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_radius.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/design_system/tokens/app_typography.dart';
import 'package:aula/core/services/backup_service.dart';
import 'package:aula/core/services/security_service.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:aula/features/settings/presentation/screens/security_lock_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final profileAsync = ref.watch(profileStreamProvider);
    final prefs = ref.watch(sharedPreferencesProvider);
    final isPinEnabled = prefs.getBool('security_pin_enabled') ?? false;
    final isBiometricsEnabled = prefs.getBool('security_biometrics_enabled') ?? false;
    final autoLockTimeout = prefs.getInt('security_autolock_timeout') ?? 0;
    final passingGrade = prefs.getDouble('academic_passing_grade') ?? 4.0;
    final currentThemeMode = ref.watch(themeProvider).themeMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        scrolledUnderElevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              children: [
                // 1. Profile Section Card
                _buildSectionTitle('PERFIL ESTUDIANTIL'),
                profileAsync.when(
                  data: (profile) {
                    if (profile == null) {
                      return const SizedBox.shrink();
                    }
                    return _buildProfileCard(profile, context);
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                const SizedBox(height: AppSpacing.xl),

                // 2. Appearance Section
                _buildSectionTitle('APARIENCIA'),
                AppCard(
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.palette_outlined,
                        title: 'Tema de la aplicación',
                        subtitle: _themeModeLabel(currentThemeMode),
                        trailing: DropdownButton<ThemeMode>(
                          value: currentThemeMode,
                          underline: const SizedBox.shrink(),
                          dropdownColor: theme.cardColor,
                          items: const [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('Sistema'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Claro'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Oscuro'),
                            ),
                          ],
                          onChanged: (mode) {
                            if (mode != null) {
                              ref.read(themeProvider.notifier).setThemeMode(mode);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // 3. Security Section
                _buildSectionTitle('SEGURIDAD Y PRIVACIDAD'),
                AppCard(
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.pin_outlined,
                        title: 'Bloqueo con PIN',
                        subtitle: isPinEnabled ? 'Activado (4 dígitos)' : 'Desactivado',
                        trailing: Switch.adaptive(
                          value: isPinEnabled,
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                          onChanged: (val) => _handlePinToggle(val),
                        ),
                      ),
                      if (isPinEnabled) ...[
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: Icons.fingerprint_rounded,
                          title: 'Biometría (Huella / Rostro)',
                          subtitle: 'Desbloqueo rápido instantáneo',
                          trailing: Switch.adaptive(
                            value: isBiometricsEnabled,
                            activeThumbColor: AppColors.primary,
                            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                            onChanged: (val) async {
                              final security = ref.read(securityServiceProvider);
                              final available = await security.canCheckBiometrics();
                              if (!available) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Tu dispositivo no soporta biometría configurada'),
                                    ),
                                  );
                                }
                                return;
                              }
                              await prefs.setBool('security_biometrics_enabled', val);
                              setState(() {});
                            },
                          ),
                        ),
                        const Divider(height: 1),
                        _buildSettingsTile(
                          icon: Icons.timer_outlined,
                          title: 'Bloqueo automático',
                          subtitle: _timeoutLabel(autoLockTimeout),
                          trailing: DropdownButton<int>(
                            value: autoLockTimeout,
                            underline: const SizedBox.shrink(),
                            dropdownColor: theme.cardColor,
                            items: const [
                              DropdownMenuItem(value: 0, child: Text('Al instante')),
                              DropdownMenuItem(value: 60, child: Text('1 minuto')),
                              DropdownMenuItem(value: 300, child: Text('5 minutos')),
                              DropdownMenuItem(value: -1, child: Text('Nunca')),
                            ],
                            onChanged: (seconds) {
                              if (seconds != null) {
                                prefs.setInt('security_autolock_timeout', seconds);
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // 4. Academic Settings
                _buildSectionTitle('CONFIGURACIÓN ACADÉMICA'),
                AppCard(
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.grade_outlined,
                        title: 'Nota mínima de aprobación',
                        subtitle: 'Nota de corte para materias y cálculos',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            passingGrade.toStringAsFixed(1),
                            style: AppTypography.titleMedium.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onTap: () => _editPassingGrade(passingGrade),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // 5. Backups & Sync
                _buildSectionTitle('COPIAS DE SEGURIDAD (OFFLINE)'),
                AppCard(
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.upload_file_outlined,
                        title: 'Exportar copia de seguridad',
                        subtitle: 'Archivo ZIP con SHA-256 (opcional cifrado AES)',
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () => _showExportSheet(),
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        icon: Icons.download_outlined,
                        title: 'Restaurar copia de seguridad',
                        subtitle: 'Recuperar materias, notas y fotos',
                        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                        onTap: () => _handleRestoreBackup(),
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        icon: Icons.autorenew_rounded,
                        title: 'Respaldos locales rotativos',
                        subtitle: 'Últimas 5 copias en almacenamiento privado',
                        trailing: const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // 6. Danger Zone
                _buildSectionTitle('ZONA DE PELIGRO', isDestructive: true),
                AppCard(
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 1,
                  ),
                  child: _buildSettingsTile(
                    icon: Icons.delete_forever_rounded,
                    iconColor: AppColors.error,
                    title: 'Restablecer todos los datos',
                    titleColor: AppColors.error,
                    subtitle: 'Elimina de forma irreversible todas las materias, exámenes y notas',
                    onTap: () => _confirmWipeData(),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // 7. Footer Info
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Aula • Versión 1.0.0',
                        style: AppTypography.labelMedium.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '100% Offline • Cero cuentas • Cero servidores',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.6) : AppColors.lightTextSecondary.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionTitle(String title, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.xs,
        bottom: AppSpacing.xs,
      ),
      child: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: isDestructive ? AppColors.error : AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic profile, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Row(
        children: [
          _buildAvatarWidget(profile.avatarUrl, profile.fullName),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${profile.career} • ${profile.university}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarWidget(String? avatarUrl, String fullName) {
    final initials = fullName.isNotEmpty
        ? fullName.trim().split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase()
        : 'A';

    return FutureBuilder<File?>(
      future: _resolveAvatarFile(avatarUrl),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Image.file(
              snapshot.data!,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          );
        }
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          alignment: Alignment.center,
          child: Text(
            initials,
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Future<File?> _resolveAvatarFile(String? relativePath) async {
    if (relativePath == null || relativePath.isEmpty) return null;
    final docsDir = await getApplicationDocumentsDirectory();
    final file = File(p.join(docsDir.path, relativePath));
    return await file.exists() ? file : null;
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs),
            decoration: BoxDecoration(
              color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: iconColor ?? AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );

    if (onTap != null) {
      return PressableScale(
        onTap: onTap,
        child: content,
      );
    }
    return content;
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Sigue la configuración del sistema';
      case ThemeMode.light:
        return 'Tema claro permanente';
      case ThemeMode.dark:
        return 'Tema oscuro permanente';
    }
  }

  String _timeoutLabel(int seconds) {
    if (seconds == 0) return 'Inmediatamente al salir';
    if (seconds == 60) return 'Tras 1 minuto de inactividad';
    if (seconds == 300) return 'Tras 5 minutos de inactividad';
    return 'Desactivado';
  }

  Future<void> _handlePinToggle(bool enable) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final security = ref.read(securityServiceProvider);

    if (enable) {
      final success = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => const SecurityLockScreen(
            mode: SecurityScreenMode.setup,
          ),
        ),
      );

      if (success == true) {
        setState(() {});
      }
    } else {
      final verified = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => const SecurityLockScreen(
            mode: SecurityScreenMode.verifyBeforeChange,
          ),
        ),
      );

      if (verified == true) {
        await security.removePin();
        await prefs.setBool('security_pin_enabled', false);
        await prefs.setBool('security_biometrics_enabled', false);
        setState(() {});
      }
    }
  }

  void _editPassingGrade(double currentGrade) {
    final controller = TextEditingController(text: currentGrade.toString());
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nota mínima de aprobación'),
          content: AppTextField(
            label: 'Calificación de corte',
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            AppButton(
              text: 'Guardar',
              onPressed: () {
                final parsed = double.tryParse(controller.text);
                if (parsed != null && parsed >= 0) {
                  ref.read(sharedPreferencesProvider).setDouble('academic_passing_grade', parsed);
                  setState(() {});
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showExportSheet() {
    final passwordController = TextEditingController();
    bool useEncryption = false;

    SpringSheet.show<void>(
      context: context,
      child: StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Exportar Respaldo',
                  style: AppTypography.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Se generará un archivo portable con toda tu información académica y fotos.',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proteger con contraseña',
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const Text(
                            'Cifra el archivo con AES-GCM de 256 bits',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: useEncryption,
                      activeThumbColor: AppColors.primary,
                      activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
                      onChanged: (val) {
                        setModalState(() => useEncryption = val);
                      },
                    ),
                  ],
                ),
                if (useEncryption) ...[
                  const SizedBox(height: AppSpacing.md),
                  AppTextField(
                    label: 'Contraseña de cifrado',
                    controller: passwordController,
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    text: 'Generar y Compartir',
                    icon: const Icon(Icons.share_rounded, size: 18),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.of(context).pop();
                      setState(() => _isLoading = true);
                      final backupService = ref.read(backupServiceProvider);
                      final res = await backupService.exportBackup(
                        password: useEncryption ? passwordController.text : null,
                      );
                      setState(() => _isLoading = false);

                      if (!mounted) return;
                      if (res.isFailure) {
                        messenger.showSnackBar(
                          SnackBar(content: Text(res.failure.message)),
                        );
                      } else {
                        await HapticFeedbackHelper.notificationSuccess();
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRestoreBackup() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
    );

    if (result == null || result.files.single.path == null) return;

    final filePath = result.files.single.path!;
    final backupService = ref.read(backupServiceProvider);

    final isEncrypted = await backupService.isEncryptedBackup(filePath);
    String? password;

    if (isEncrypted && mounted) {
      final passwordController = TextEditingController();
      final entered = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Respaldo Protegido'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ingresa la contraseña con la que se creó este respaldo:'),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Contraseña',
                  controller: passwordController,
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
              AppButton(
                text: 'Desbloquear',
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          );
        },
      );

      if (entered != true) return;
      password = passwordController.text;
    }

    setState(() => _isLoading = true);
    final restoreRes = await backupService.importBackupFromFile(
      filePath: filePath,
      password: password,
    );
    setState(() => _isLoading = false);

    if (!mounted) return;
    if (restoreRes.isSuccess) {
      await HapticFeedbackHelper.notificationSuccess();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Datos restaurados con éxito!')),
      );
      ref.invalidate(profileStreamProvider);
    } else {
      await HapticFeedbackHelper.notificationError();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(restoreRes.failure.message)),
      );
    }
  }

  void _confirmWipeData() {
    final confirmController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('¿Eliminar todos los datos?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Esta acción es IRREVERSIBLE. Se borrarán todas las materias, exámenes, notas y respaldos.',
                style: TextStyle(color: AppColors.error),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text('Escribe "BORRAR" para confirmar:'),
              const SizedBox(height: AppSpacing.sm),
              AppTextField(
                label: 'Confirmación',
                controller: confirmController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            AppButton(
              text: 'Eliminar Todo',
              variant: AppButtonVariant.danger,
              onPressed: () async {
                if (confirmController.text.trim().toUpperCase() == 'BORRAR') {
                  Navigator.of(context).pop();
                  setState(() => _isLoading = true);

                  final backupService = ref.read(backupServiceProvider);
                  await backupService.wipeAllData();
                  final prefs = ref.read(sharedPreferencesProvider);
                  await prefs.clear();

                  setState(() => _isLoading = false);

                  if (context.mounted) {
                    context.go(AppRoutes.onboarding);
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
