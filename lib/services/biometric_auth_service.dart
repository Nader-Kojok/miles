import 'package:flutter/foundation.dart';

import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Biometric Authentication Service
/// Handles Face ID, Touch ID, and Fingerprint authentication
class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  static const String _biometricEnabledKey = 'biometric_enabled';

  /// Check if device supports biometric authentication
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } on PlatformException catch (e) {
      debugPrint('Error checking biometrics: $e');
      return false;
    }
  }

  /// Check if device is enrolled with biometrics
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } on PlatformException catch (e) {
      debugPrint('Error checking device support: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return <BiometricType>[];
    }
  }

  /// Get biometric type name for display
  String getBiometricTypeName(List<BiometricType> biometrics) {
    if (biometrics.contains(BiometricType.face)) {
      return 'Face ID';
    } else if (biometrics.contains(BiometricType.fingerprint)) {
      return 'Empreinte digitale';
    } else if (biometrics.contains(BiometricType.iris)) {
      return 'Iris';
    } else if (biometrics.contains(BiometricType.strong) || 
               biometrics.contains(BiometricType.weak)) {
      return 'Biométrie';
    }
    return 'Authentification biométrique';
  }

  /// Authenticate with biometrics
  Future<bool> authenticate({
    required String reason,
    bool biometricOnly = true,
    bool stickyAuth = true,
  }) async {
    try {
      final bool canAuthenticateWithBiometrics = await canCheckBiometrics();
      final bool canAuthenticate = canAuthenticateWithBiometrics || await isDeviceSupported();

      if (!canAuthenticate) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          biometricOnly: biometricOnly,
          stickyAuth: stickyAuth,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Error during authentication: $e');
      return false;
    }
  }

  /// Quick login with biometrics
  Future<bool> authenticateForLogin() async {
    return await authenticate(
      reason: 'Authentifiez-vous pour vous connecter',
      biometricOnly: true,
      stickyAuth: true,
    );
  }

  /// Authenticate for checkout
  Future<bool> authenticateForCheckout() async {
    return await authenticate(
      reason: 'Authentifiez-vous pour confirmer votre achat',
      biometricOnly: true,
      stickyAuth: true,
    );
  }

  /// Authenticate for sensitive action
  Future<bool> authenticateForSensitiveAction(String action) async {
    return await authenticate(
      reason: 'Authentifiez-vous pour $action',
      biometricOnly: true,
      stickyAuth: true,
    );
  }

  /// Check if biometric authentication is enabled by user
  Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  /// Enable biometric authentication
  Future<void> enableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, true);
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, false);
  }

  /// Toggle biometric authentication
  Future<bool> toggleBiometric() async {
    final isEnabled = await isBiometricEnabled();
    if (isEnabled) {
      await disableBiometric();
      return false;
    } else {
      // Verify biometric before enabling
      final authenticated = await authenticate(
        reason: 'Authentifiez-vous pour activer la connexion biométrique',
        biometricOnly: true,
      );
      
      if (authenticated) {
        await enableBiometric();
        return true;
      }
      return false;
    }
  }

  /// Stop authentication (cancel)
  Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } on PlatformException catch (e) {
      debugPrint('Error stopping authentication: $e');
    }
  }
}
