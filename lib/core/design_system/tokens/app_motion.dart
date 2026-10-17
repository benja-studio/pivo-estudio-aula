import 'package:flutter/physics.dart';
import 'package:aula/core/utils/physics_helpers.dart';

/// Motion & physics tokens conforming to the Apple design specification.
class AppMotion {
  AppMotion._();

  // Damping ratio (ζ) tokens
  static const double zetaCriticallyDamped = 1.0;
  static const double zetaUnderdamped = 0.8;

  // Response (r, in seconds) tokens
  static const double responsePress = 0.22;
  static const double responseDefault = 0.38;
  static const double responseSheet = 0.30;
  static const double responseFlick = 0.35;
  static const double responseShapeChange = 0.40;

  // Press feedback target scale
  static const double pressScale = 0.97;
  static const double pressHysteresisPx = 10.0;

  // Spring descriptions
  static SpringDescription get pressSpring => springFrom(
        dampingRatio: zetaCriticallyDamped,
        response: responsePress,
      );

  static SpringDescription get defaultSpring => springFrom(
        dampingRatio: zetaCriticallyDamped,
        response: responseDefault,
      );

  static SpringDescription get sheetSpring => springFrom(
        dampingRatio: zetaUnderdamped,
        response: responseSheet,
      );

  static SpringDescription get flickSpring => springFrom(
        dampingRatio: zetaUnderdamped,
        response: responseFlick,
      );

  static SpringDescription get shapeSpring => springFrom(
        dampingRatio: zetaUnderdamped,
        response: responseShapeChange,
      );

  // Reduced motion fallbacks
  static const Duration reducedMotionShort = Duration(milliseconds: 150);
  static const Duration reducedMotionMedium = Duration(milliseconds: 250);
}
