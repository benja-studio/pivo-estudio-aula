import 'dart:convert';
import 'dart:math';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:aula/app/theme/theme_provider.dart';

class SecurityService {
  SecurityService({
    FlutterSecureStorage? secureStorage,
    LocalAuthentication? localAuth,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _localAuth = localAuth ?? LocalAuthentication();

  final FlutterSecureStorage _secureStorage;
  final LocalAuthentication _localAuth;
  final Sha256 _sha256 = Sha256();

  static const _pinHashKey = 'aula_pin_hash';
  static const _pinSaltKey = 'aula_pin_salt';

  /// Checks if biometrics are supported on this hardware
  Future<bool> canCheckBiometrics() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return isSupported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// Authenticates using biometrics (Fingerprint / Face ID)
  Future<bool> authenticateBiometrics({String reason = 'Desbloquear Aula'}) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException {
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Sets up a new PIN with cryptographic random salt and SHA-256 hash
  Future<void> setPin(String pin) async {
    final random = Random.secure();
    final saltBytes = List<int>.generate(16, (_) => random.nextInt(256));
    final saltHex = saltBytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    final inputBytes = utf8.encode(pin + saltHex);
    final hash = await _sha256.hash(inputBytes);
    final hashHex = hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    await _secureStorage.write(key: _pinSaltKey, value: saltHex);
    await _secureStorage.write(key: _pinHashKey, value: hashHex);
  }

  /// Checks if a PIN has been set
  Future<bool> hasPin() async {
    final hash = await _secureStorage.read(key: _pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  /// Validates the entered PIN against the stored hash and salt
  Future<bool> verifyPin(String pin) async {
    final saltHex = await _secureStorage.read(key: _pinSaltKey);
    final storedHash = await _secureStorage.read(key: _pinHashKey);

    if (saltHex == null || storedHash == null) {
      return false;
    }

    final inputBytes = utf8.encode(pin + saltHex);
    final hash = await _sha256.hash(inputBytes);
    final hashHex = hash.bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

    return hashHex == storedHash;
  }

  /// Removes PIN and clears stored security keys
  Future<void> removePin() async {
    await _secureStorage.delete(key: _pinSaltKey);
    await _secureStorage.delete(key: _pinHashKey);
  }
}

final securityServiceProvider = Provider<SecurityService>((ref) {
  return SecurityService();
});

/// State controller for whether the app is currently locked
class AppLockNotifier extends Notifier<bool> {
  DateTime? _lastPausedTime;

  @override
  bool build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final pinEnabled = prefs.getBool('security_pin_enabled') ?? false;
    return pinEnabled;
  }

  void unlock() {
    state = false;
  }

  void lock() {
    final prefs = ref.read(sharedPreferencesProvider);
    final pinEnabled = prefs.getBool('security_pin_enabled') ?? false;
    if (pinEnabled) {
      state = true;
    }
  }

  void onAppPaused() {
    _lastPausedTime = DateTime.now();
  }

  void onAppResumed() {
    final prefs = ref.read(sharedPreferencesProvider);
    final pinEnabled = prefs.getBool('security_pin_enabled') ?? false;
    if (!pinEnabled) return;

    final timeoutSeconds = prefs.getInt('security_autolock_timeout') ?? 0;
    if (timeoutSeconds < 0) {
      // Never auto-lock on pause/resume
      return;
    }

    if (_lastPausedTime != null) {
      final elapsed = DateTime.now().difference(_lastPausedTime!).inSeconds;
      if (elapsed >= timeoutSeconds) {
        state = true;
      }
    }
  }
}

final appLockProvider = NotifierProvider<AppLockNotifier, bool>(() {
  return AppLockNotifier();
});
