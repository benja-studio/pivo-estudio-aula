import 'package:flutter/material.dart';

/// Available user-selectable accent colors.
enum AppAccentColor {
  indigo(
    name: 'Índigo',
    light: Color(0xFF4F46E5),
    dark: Color(0xFF6366F1),
  ),
  emerald(
    name: 'Esmeralda',
    light: Color(0xFF059669),
    dark: Color(0xFF10B981),
  ),
  violet(
    name: 'Violeta',
    light: Color(0xFF7C3AED),
    dark: Color(0xFF8B5CF6),
  ),
  coral(
    name: 'Coral',
    light: Color(0xFFE11D48),
    dark: Color(0xFFF43F5E),
  ),
  amber(
    name: 'Ámbar',
    light: Color(0xFFD97706),
    dark: Color(0xFFF59E0B),
  ),
  cyan(
    name: 'Cian',
    light: Color(0xFF0891B2),
    dark: Color(0xFF06B6D4),
  ),
  rose(
    name: 'Rosa',
    light: Color(0xFFBE185D),
    dark: Color(0xFFEC4899),
  ),
  teal(
    name: 'Menta',
    light: Color(0xFF0D9488),
    dark: Color(0xFF14B8A6),
  );

  const AppAccentColor({
    required this.name,
    required this.light,
    required this.dark,
  });

  final String name;
  final Color light;
  final Color dark;

  Color colorFor(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}

/// Neutral semantic tokens and surface scales.
class AppColors {
  AppColors._();

  // Primary brand accent
  static const Color primary = Color(0xFF4F46E5);

  // Neutral Light Surfaces
  static const Color lightBackground = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF);
  static const Color lightSurfaceHigher = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderSubtle = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextTertiary = Color(0xFF94A3B8);

  // Neutral Dark Surfaces (Tonal elevation, pitch-free dark mode)
  static const Color darkBackground = Color(0xFF0B0F17);
  static const Color darkSurface = Color(0xFF131924);
  static const Color darkSurfaceElevated = Color(0xFF1B2332);
  static const Color darkSurfaceHigher = Color(0xFF242E40);
  static const Color darkBorder = Color(0xFF283244);
  static const Color darkBorderSubtle = Color(0xFF1E2738);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Semantics (Functional Status)
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF92400E);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF991B1B);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E40AF);

  // Subject default palette (harmonious & vibrant)
  static const List<Color> subjectPalette = [
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFFF97316), // Orange
    Color(0xFF10B981), // Emerald
    Color(0xFF06B6D4), // Cyan
    Color(0xFF6366F1), // Indigo
    Color(0xFFEAB308), // Yellow
    Color(0xFF14B8A6), // Teal
    Color(0xFFF43F5E), // Rose
  ];
}
