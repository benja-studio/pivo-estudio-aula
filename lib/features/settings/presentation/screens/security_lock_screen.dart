import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aula/app/theme/theme_provider.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/design_system/tokens/app_typography.dart';
import 'package:aula/core/services/security_service.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';
import 'package:aula/features/settings/presentation/widgets/pin_keypad.dart';

enum SecurityScreenMode {
  unlock,
  setup,
  verifyBeforeChange,
}

class SecurityLockScreen extends ConsumerStatefulWidget {
  const SecurityLockScreen({
    super.key,
    this.mode = SecurityScreenMode.unlock,
    this.onSuccess,
  });

  final SecurityScreenMode mode;
  final VoidCallback? onSuccess;

  @override
  ConsumerState<SecurityLockScreen> createState() => _SecurityLockScreenState();
}

class _SecurityLockScreenState extends ConsumerState<SecurityLockScreen>
    with SingleTickerProviderStateMixin {
  static const int _pinLength = 4;
  String _enteredPin = '';
  String? _firstEnteredPin;
  String? _errorMessage;
  bool _canUseBiometrics = false;
  late AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    if (widget.mode == SecurityScreenMode.unlock) {
      unawaited(_checkBiometricsAndPrompt());
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricsAndPrompt() async {
    final security = ref.read(securityServiceProvider);
    final prefs = ref.read(sharedPreferencesProvider);
    final isBiometricsEnabled = prefs.getBool('security_biometrics_enabled') ?? false;

    if (!isBiometricsEnabled) return;

    final available = await security.canCheckBiometrics();
    if (mounted) {
      setState(() => _canUseBiometrics = available);
    }

    if (available) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      await _triggerBiometrics();
    }
  }

  Future<void> _triggerBiometrics() async {
    final security = ref.read(securityServiceProvider);
    final success = await security.authenticateBiometrics(
      reason: 'Desbloquear Aula',
    );

    if (success && mounted) {
      await HapticFeedbackHelper.notificationSuccess();
      ref.read(appLockProvider.notifier).unlock();
      widget.onSuccess?.call();
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
      }
    }
  }

  void _onDigit(String digit) {
    if (_enteredPin.length >= _pinLength) return;

    setState(() {
      _enteredPin += digit;
      _errorMessage = null;
    });

    if (_enteredPin.length == _pinLength) {
      unawaited(_processCompletedPin());
    }
  }

  void _onDelete() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        _errorMessage = null;
      });
    }
  }

  Future<void> _processCompletedPin() async {
    final security = ref.read(securityServiceProvider);

    if (widget.mode == SecurityScreenMode.unlock) {
      final valid = await security.verifyPin(_enteredPin);
      if (valid) {
        await HapticFeedbackHelper.notificationSuccess();
        ref.read(appLockProvider.notifier).unlock();
        widget.onSuccess?.call();
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop(true);
        }
      } else {
        await _handleFailure('PIN incorrecto');
      }
    } else if (widget.mode == SecurityScreenMode.setup) {
      if (_firstEnteredPin == null) {
        setState(() {
          _firstEnteredPin = _enteredPin;
          _enteredPin = '';
        });
      } else {
        if (_enteredPin == _firstEnteredPin) {
          await security.setPin(_enteredPin);
          final prefs = ref.read(sharedPreferencesProvider);
          await prefs.setBool('security_pin_enabled', true);

          await HapticFeedbackHelper.notificationSuccess();
          if (mounted) {
            widget.onSuccess?.call();
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop(true);
            }
          }
        } else {
          await _handleFailure('Los PINs no coinciden. Intenta de nuevo');
          setState(() {
            _firstEnteredPin = null;
          });
        }
      }
    } else if (widget.mode == SecurityScreenMode.verifyBeforeChange) {
      final valid = await security.verifyPin(_enteredPin);
      if (valid) {
        await HapticFeedbackHelper.notificationSuccess();
        if (mounted) {
          widget.onSuccess?.call();
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop(true);
          }
        }
      } else {
        await _handleFailure('PIN actual incorrecto');
      }
    }
  }

  Future<void> _handleFailure(String message) async {
    await HapticFeedbackHelper.notificationError();
    unawaited(_shakeController.forward(from: 0.0));
    setState(() {
      _errorMessage = message;
      _enteredPin = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    String title;
    String subtitle;

    if (widget.mode == SecurityScreenMode.unlock) {
      title = 'Bienvenido de nuevo';
      subtitle = 'Ingresa tu PIN de 4 dígitos para acceder';
    } else if (widget.mode == SecurityScreenMode.setup) {
      if (_firstEnteredPin == null) {
        title = 'Crea tu PIN de seguridad';
        subtitle = 'Elige 4 dígitos que recuerdes fácilmente';
      } else {
        title = 'Confirma tu PIN';
        subtitle = 'Vuelve a ingresar los 4 dígitos';
      }
    } else {
      title = 'Verifica tu identidad';
      subtitle = 'Ingresa tu PIN actual para continuar';
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: widget.mode != SecurityScreenMode.unlock
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(false),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.lock_rounded,
                color: AppColors.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              title,
              style: AppTypography.headlineMedium.copyWith(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final offset = _shakeController.isAnimating
                    ? (_shakeController.value * 12) * ((_shakeController.value * 4).floor() % 2 == 0 ? 1 : -1)
                    : 0.0;
                return Transform.translate(
                  offset: Offset(offset, 0),
                  child: SizedBox(
                    height: 24,
                    child: _errorMessage != null
                        ? Text(
                            _errorMessage!,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            PinKeypad(
              currentPin: _enteredPin,
              pinLength: _pinLength,
              onDigitPressed: _onDigit,
              onDeletePressed: _onDelete,
              showBiometrics: widget.mode == SecurityScreenMode.unlock && _canUseBiometrics,
              onBiometricPressed: _triggerBiometrics,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
