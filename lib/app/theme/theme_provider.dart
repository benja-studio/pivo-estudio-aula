import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aula/core/design_system/tokens/app_colors.dart';

class ThemeState {
  const ThemeState({
    required this.themeMode,
    required this.accentColor,
    required this.reduceMotion,
  });

  final ThemeMode themeMode;
  final AppAccentColor accentColor;
  final bool reduceMotion;

  ThemeState copyWith({
    ThemeMode? themeMode,
    AppAccentColor? accentColor,
    bool? reduceMotion,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier(this._prefs)
      : super(
          ThemeState(
            themeMode: _parseThemeMode(_prefs.getString(_themeModeKey)),
            accentColor: _parseAccent(_prefs.getString(_accentKey)),
            reduceMotion: _prefs.getBool(_reduceMotionKey) ?? false,
          ),
        );

  final SharedPreferences _prefs;

  static const String _themeModeKey = 'app_theme_mode';
  static const String _accentKey = 'app_accent_color';
  static const String _reduceMotionKey = 'app_reduce_motion';

  static ThemeMode _parseThemeMode(String? value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static AppAccentColor _parseAccent(String? value) {
    for (final accent in AppAccentColor.values) {
      if (accent.name == value) return accent;
    }
    return AppAccentColor.indigo;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final str = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_themeModeKey, str);
  }

  Future<void> setAccentColor(AppAccentColor accent) async {
    state = state.copyWith(accentColor: accent);
    await _prefs.setString(_accentKey, accent.name);
  }

  Future<void> setReduceMotion(bool reduce) async {
    state = state.copyWith(reduceMotion: reduce);
    await _prefs.setBool(_reduceMotionKey, reduce);
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in bootstrap');
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ThemeNotifier(prefs);
});
