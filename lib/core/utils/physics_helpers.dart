import 'dart:math' as math;
import 'package:flutter/physics.dart';

/// Central spring helper translating Apple's damping ratio (ζ) and response (r) to Flutter.
///
/// ζ = 1.0 → critically damped (no bounce, default UI movement).
/// ζ ≈ 0.8 → underdamped (subtle natural bounce after momentum flick).
/// r = response in seconds (speed/duration of settling).
SpringDescription springFrom({
  double dampingRatio = 1.0,
  double response = 0.4,
}) {
  assert(response > 0, 'response must be greater than zero');
  final omega = 2 * math.pi / response;
  return SpringDescription(
    mass: 1.0,
    stiffness: omega * omega, // (2π / r)²
    damping: 4 * math.pi * dampingRatio / response, // 2ζω
  );
}

/// Momentum projection helper using Apple's exponential form (NOT v² / 2a).
///
/// Projects the rest coordinate given the initial velocity in px/sec.
double project(
  double velocityPxPerSec, {
  double decelerationRate = 0.998,
}) {
  return (velocityPxPerSec / 1000.0) * decelerationRate / (1.0 - decelerationRate);
}

/// Progressive resistance (rubber-banding) for out-of-bounds drags.
///
/// [overshoot] is the distance dragged past the boundary.
/// [dimension] is the viewport or container size in the drag direction.
/// [c] is the constant factor controlling elasticity (Apple uses ≈ 0.55).
double rubberband(
  double overshoot,
  double dimension, {
  double c = 0.55,
}) {
  if (dimension <= 0) return 0.0;
  return (overshoot * dimension * c) / (dimension + c * overshoot.abs());
}
