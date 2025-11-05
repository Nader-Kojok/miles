import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../models/address.dart';
import '../services/profile_service.dart';
import '../utils/error_handler.dart';

/// Profile Provider for global state management
/// Following 2025 best practices with proper error handling
class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService = ProfileService();

  Profile? _profile;
  List<Address> _addresses = [];
  Address? _defaultAddress;
  
  bool _isLoading = false;
  String? _error;

  // Getters
  Profile? get profile => _profile;
  List<Address> get addresses => _addresses;
  Address? get defaultAddress => _defaultAddress;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasProfile => _profile != null;

  /// Load user profile
  Future<void> loadProfile() async {
    try {
      _setLoading(true);
      _error = null;

      _profile = await GlobalErrorHandler.retryOperation(
        operation: () => _profileService.getUserProfile(),
        maxAttempts: 2,
      );

      notifyListeners();
    } catch (e) {
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error loading profile: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Update user profile
  Future<void> updateProfile({
    String? fullName,
    String? phone,
    String? email,
    String? address,
    DateTime? birthDate,
    String? avatarUrl,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _profileService.updateProfile(
        fullName: fullName,
        phone: phone,
        email: email,
        address: address,
        birthDate: birthDate,
        avatarUrl: avatarUrl,
      );

      // Reload profile to get updated data
      await loadProfile();
    } catch (e) {
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error updating profile: $e');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Load addresses
  Future<void> loadAddresses() async {
    try {
      _setLoading(true);
      _error = null;

      _addresses = await GlobalErrorHandler.retryOperation(
        operation: () => _profileService.getAddresses(),
        maxAttempts: 2,
      );

      try {
        _defaultAddress = _addresses.firstWhere((addr) => addr.isDefault);
      } catch (e) {
        _defaultAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }

      notifyListeners();
    } catch (e) {
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error loading addresses: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Add new address
  Future<void> addAddress({
    required String label,
    required String fullName,
    required String phone,
    required String addressLine1,
    String? addressLine2,
    required String city,
    String? postalCode,
    String country = 'CI',
    bool isDefault = false,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final newAddress = await _profileService.addAddress(
        label: label,
        fullName: fullName,
        phone: phone,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        postalCode: postalCode,
        country: country,
        isDefault: isDefault,
      );

      _addresses.insert(0, newAddress);
      
      if (isDefault) {
        _defaultAddress = newAddress;
      }

      notifyListeners();
    } catch (e) {
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error adding address: $e');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Update address
  Future<void> updateAddress(
    String addressId, {
    String? label,
    String? fullName,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      await _profileService.updateAddress(
        addressId,
        label: label,
        fullName: fullName,
        phone: phone,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        postalCode: postalCode,
        country: country,
        isDefault: isDefault,
      );

      // Reload addresses to get updated data
      await loadAddresses();
    } catch (e) {
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error updating address: $e');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Delete address
  Future<void> deleteAddress(String addressId) async {
    try {
      _setLoading(true);
      _error = null;

      await _profileService.deleteAddress(addressId);

      _addresses.removeWhere((addr) => addr.id == addressId);
      
      if (_defaultAddress?.id == addressId) {
        _defaultAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }

      notifyListeners();
    } catch (e) {
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error deleting address: $e');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Set default address
  Future<void> setDefaultAddress(String addressId) async {
    try {
      _setLoading(true);
      _error = null;

      await _profileService.setDefaultAddress(addressId);

      // Update local state
      for (var addr in _addresses) {
        addr = addr.copyWith(isDefault: addr.id == addressId);
      }
      
      _defaultAddress = _addresses.firstWhere((addr) => addr.id == addressId);

      notifyListeners();
    } catch (e) {
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error setting default address: $e');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear all data (on logout)
  void clear() {
    _profile = null;
    _addresses = [];
    _defaultAddress = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
