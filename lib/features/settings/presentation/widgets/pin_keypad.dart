import 'package:flutter/material.dart';
import 'package:aula/core/design_system/components/pressable_scale.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';
import 'package:aula/core/design_system/tokens/app_spacing.dart';
import 'package:aula/core/design_system/tokens/app_typography.dart';
import 'package:aula/core/utils/haptic_feedback_helper.dart';

class PinKeypad extends StatelessWidget {
  const PinKeypad({
    super.key,
    required this.currentPin,
    required this.pinLength,
    required this.onDigitPressed,
    required this.onDeletePressed,
    this.onBiometricPressed,
    this.showBiometrics = false,
  });

  final String currentPin;
  final int pinLength;
  final ValueChanged<String> onDigitPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback? onBiometricPressed;
  final bool showBiometrics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(pinLength, (index) {
            final isFilled = index < currentPin.length;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              width: isFilled ? 18 : 14,
              height: isFilled ? 18 : 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isFilled
                    ? AppColors.primary
                    : (isDark ? Colors.white24 : Colors.black12),
                border: isFilled
                    ? null
                    : Border.all(
                        color: isDark ? Colors.white38 : Colors.black26,
                        width: 1.5,
                      ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Keypad Grid
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            children: [
              _buildRow(['1', '2', '3'], context),
              const SizedBox(height: AppSpacing.md),
              _buildRow(['4', '5', '6'], context),
              const SizedBox(height: AppSpacing.md),
              _buildRow(['7', '8', '9'], context),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (showBiometrics && onBiometricPressed != null)
                    _KeypadButton(
                      child: const Icon(
                        Icons.fingerprint_rounded,
                        size: 32,
                        color: AppColors.primary,
                      ),
                      onPressed: () {
                        HapticFeedbackHelper.selectionClick();
                        onBiometricPressed!();
                      },
                    )
                  else
                    const SizedBox(width: 76, height: 76),

                  _KeypadButton(
                    child: Text(
                      '0',
                      style: AppTypography.displayMedium.copyWith(
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedbackHelper.lightImpact();
                      if (currentPin.length < pinLength) {
                        onDigitPressed('0');
                      }
                    },
                  ),

                  _KeypadButton(
                    child: Icon(
                      Icons.backspace_outlined,
                      size: 26,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    onPressed: () {
                      HapticFeedbackHelper.selectionClick();
                      onDeletePressed();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits, BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((digit) {
        return _KeypadButton(
          child: Text(
            digit,
            style: AppTypography.displayMedium.copyWith(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          onPressed: () {
            HapticFeedbackHelper.lightImpact();
            if (currentPin.length < pinLength) {
              onDigitPressed(digit);
            }
          },
        );
      }).toList(),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  const _KeypadButton({
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PressableScale(
      onTap: onPressed,
      child: Container(
        width: 76,
        height: 76,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E222A) : const Color(0xFFF1F3F5),
          shape: BoxShape.circle,
          border: Border.all(
            color: isDark ? const Color(0xFF2C323F) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }
}
