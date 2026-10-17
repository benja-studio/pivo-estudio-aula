import 'package:flutter/services.dart';

/// Centralized restrained haptic feedback triggers.
class AppHaptics {
  AppHaptics._();

  /// Triggered on light taps or state toggle (e.g., topic state change).
  static Future<void> selectionClick() => HapticFeedback.selectionClick();

  /// Subtle light impact
  static Future<void> lightImpact() => HapticFeedback.lightImpact();

  /// Triggered on sheet snap points, page change, or drag threshold crossing.
  static Future<void> snapPoint() => HapticFeedback.lightImpact();

  /// Triggered on successful completion, grade passed, exam created.
  static Future<void> success() => HapticFeedback.mediumImpact();

  /// Alias for success notification
  static Future<void> notificationSuccess() => success();

  /// Triggered on validation error, destructive action warning, or grade fail alert.
  static Future<void> error() => HapticFeedback.heavyImpact();

  /// Alias for error notification
  static Future<void> notificationError() => error();

  /// Triggered on high-consequence deletion confirmation.
  static Future<void> destructiveConfirm() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.mediumImpact();
  }
}

typedef HapticFeedbackHelper = AppHaptics;
