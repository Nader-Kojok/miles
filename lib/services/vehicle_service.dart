import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/vehicle.dart';

class VehicleService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get list of vehicle makes (manufacturers)
  Future<List<String>> getMakes() async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select('make')
          .order('make');

      final makes = (response as List)
          .map((item) => item['make'] as String)
          .toSet()
          .toList();
      
      makes.sort();
      return makes;
    } catch (e) {
      print('Error fetching makes: $e');
      // Return sample data for demo
      return [
        'Audi',
        'BMW',
        'Ford',
        'Honda',
        'Hyundai',
        'Mercedes-Benz',
        'Nissan',
        'Peugeot',
        'Renault',
        'Toyota',
        'Volkswagen',
      ];
    }
  }

  // Get models for a specific make
  Future<List<String>> getModels(String make) async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select('model')
          .eq('make', make)
          .order('model');

      final models = (response as List)
          .map((item) => item['model'] as String)
          .toSet()
          .toList();
      
      models.sort();
      return models;
    } catch (e) {
      print('Error fetching models: $e');
      // Return sample data for demo
      if (make == 'Hyundai') {
        return ['Santa Fe', 'Tucson', 'Elantra', 'Sonata', 'Kona'];
      }
      return ['Model 1', 'Model 2', 'Model 3'];
    }
  }

  // Get motorizations for a specific make and model
  Future<List<String>> getMotorizations(String make, String model) async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select('motorization')
          .eq('make', make)
          .eq('model', model)
          .not('motorization', 'is', null)
          .order('motorization');

      final motorizations = (response as List)
          .map((item) => item['motorization'] as String)
          .toSet()
          .toList();
      
      motorizations.sort();
      return motorizations;
    } catch (e) {
      print('Error fetching motorizations: $e');
      // Return sample data for demo
      return [
        'Essence - 3.3 4WD (199 KW / 270 CV)',
        'Diesel - 2.2 CRDi (147 KW / 200 CV)',
        'Hybride - 1.6 T-GDI (169 KW / 230 CV)',
      ];
    }
  }

  // Get vehicle by chassis number
  Future<Vehicle?> getVehicleByChassisNumber(String chassisNumber) async {
    try {
      final response = await _supabase
          .from('vehicles')
          .select()
          .eq('chassis_number', chassisNumber)
          .maybeSingle();

      if (response == null) return null;
      return Vehicle.fromJson(response);
    } catch (e) {
      print('Error fetching vehicle by chassis: $e');
      return null;
    }
  }

  // Get vehicle by make, model, and motorization
  Future<Vehicle?> getVehicle({
    required String make,
    required String model,
    String? motorization,
  }) async {
    try {
      var query = _supabase
          .from('vehicles')
          .select()
          .eq('make', make)
          .eq('model', model);

      if (motorization != null) {
        query = query.eq('motorization', motorization);
      }

      final response = await query.maybeSingle();

      if (response == null) {
        // If no vehicle found in DB, create a mock vehicle for demo
        return Vehicle(
          id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
          make: make,
          model: model,
          motorization: motorization,
          year: 2014,
          type: 'SUV',
          engineType: 'V6',
          fuelType: 'Essence',
          transmission: 'Automatique',
          displacement: '3.3L',
          seriesNumber: '123456',
          manufactureLocation: 'Ulsan, Corée du Sud',
          imageUrl: 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800',
        );
      }
      
      return Vehicle.fromJson(response);
    } catch (e) {
      print('Error fetching vehicle: $e');
      // Return mock data for demo
      return Vehicle(
        id: 'demo-${DateTime.now().millisecondsSinceEpoch}',
        make: make,
        model: model,
        motorization: motorization,
        year: 2014,
        type: 'SUV',
        engineType: 'V6',
        fuelType: 'Essence',
        transmission: 'Automatique',
        displacement: '3.3L',
        seriesNumber: '123456',
        manufactureLocation: 'Ulsan, Corée du Sud',
        imageUrl: 'https://images.unsplash.com/photo-1519641471654-76ce0107ad1b?w=800',
      );
    }
  }

  // Save user's vehicle to their garage
  Future<void> saveToGarage(String userId, Vehicle vehicle) async {
    try {
      await _supabase.from('user_vehicles').insert({
        'user_id': userId,
        'vehicle_id': vehicle.id,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error saving to garage: $e');
      rethrow;
    }
  }

  // Get user's saved vehicles
  Future<List<Vehicle>> getUserVehicles(String userId) async {
    try {
      final response = await _supabase
          .from('user_vehicles')
          .select('vehicle_id, vehicles(*)')
          .eq('user_id', userId);

      return (response as List)
          .map((item) => Vehicle.fromJson(item['vehicles']))
          .toList();
    } catch (e) {
      print('Error fetching user vehicles: $e');
      return [];
    }
  }
}
