import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle.dart';
import '../services/vehicle_service.dart';
import '../utils/error_handler.dart';

/// Vehicle Provider for global state management
/// Following 2025 best practices
class VehicleProvider extends ChangeNotifier {
  final VehicleService _vehicleService = VehicleService();
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Vehicle> _vehicles = [];
  Vehicle? _selectedVehicle;
  
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Vehicle> get vehicles => _vehicles;
  Vehicle? get selectedVehicle => _selectedVehicle;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasVehicles => _vehicles.isNotEmpty;
  bool get hasSelectedVehicle => _selectedVehicle != null;

  String? get _userId => _supabase.auth.currentUser?.id;

  /// Load user vehicles
  Future<void> loadVehicles() async {
    if (_userId == null) {
      _error = 'Utilisateur non connecté';
      return;
    }

    try {
      _setLoading(true);
      _error = null;

      _vehicles = await GlobalErrorHandler.retryOperation(
        operation: () => _vehicleService.getUserVehicles(_userId!),
        maxAttempts: 2,
      );

      // Set first vehicle as selected if none selected
      if (_selectedVehicle == null && _vehicles.isNotEmpty) {
        _selectedVehicle = _vehicles.first;
      }

      notifyListeners();
    } catch (e) {
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error loading vehicles: $e');
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  /// Save vehicle to garage
  Future<void> saveVehicleToGarage(Vehicle vehicle) async {
    if (_userId == null) {
      _error = 'Utilisateur non connecté';
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      _error = null;

      await _vehicleService.saveToGarage(_userId!, vehicle);

      // Add to local list if not already there
      if (!_vehicles.any((v) => v.id == vehicle.id)) {
        _vehicles.insert(0, vehicle);
      }
      
      // Set as selected if it's the first vehicle
      if (_vehicles.length == 1) {
        _selectedVehicle = vehicle;
      }

      notifyListeners();
    } catch (e) {
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error saving vehicle to garage: $e');
      notifyListeners();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Get vehicle by chassis number
  Future<Vehicle?> getVehicleByChassisNumber(String chassisNumber) async {
    try {
      _setLoading(true);
      _error = null;

      final vehicle = await _vehicleService.getVehicleByChassisNumber(chassisNumber);
      
      notifyListeners();
      return vehicle;
    } catch (e) {
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error getting vehicle by chassis: $e');
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Get vehicle by make, model, motorization
  Future<Vehicle?> getVehicle({
    required String make,
    required String model,
    String? motorization,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final vehicle = await _vehicleService.getVehicle(
        make: make,
        model: model,
        motorization: motorization,
      );
      
      notifyListeners();
      return vehicle;
    } catch (e) {
      _error = GlobalErrorHandler.getErrorMessage(e);
      debugPrint('Error getting vehicle: $e');
      notifyListeners();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Select vehicle
  void selectVehicle(Vehicle vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  /// Clear all data (on logout)
  void clear() {
    _vehicles = [];
    _selectedVehicle = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
