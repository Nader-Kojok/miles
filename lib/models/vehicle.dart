class Vehicle {
  final String id;
  final String? chassisNumber;
  final String make; // Fabricant
  final String model; // Modèle
  final String? motorization; // Motorisation
  final int? year;
  final String? type; // SUV, Sedan, etc.
  final String? engineType; // Type de moteur
  final String? fuelType; // Type de carburant
  final String? transmission; // Transmission
  final String? displacement; // Cylindrée
  final String? seriesNumber; // Numéro de série
  final String? manufactureLocation; // Lieu de fabrication
  final String? imageUrl;

  Vehicle({
    required this.id,
    this.chassisNumber,
    required this.make,
    required this.model,
    this.motorization,
    this.year,
    this.type,
    this.engineType,
    this.fuelType,
    this.transmission,
    this.displacement,
    this.seriesNumber,
    this.manufactureLocation,
    this.imageUrl,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? '',
      chassisNumber: json['chassis_number'],
      make: json['make'] ?? '',
      model: json['model'] ?? '',
      motorization: json['motorization'],
      year: json['year'],
      type: json['type'],
      engineType: json['engine_type'],
      fuelType: json['fuel_type'],
      transmission: json['transmission'],
      displacement: json['displacement'],
      seriesNumber: json['series_number'],
      manufactureLocation: json['manufacture_location'],
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chassis_number': chassisNumber,
      'make': make,
      'model': model,
      'motorization': motorization,
      'year': year,
      'type': type,
      'engine_type': engineType,
      'fuel_type': fuelType,
      'transmission': transmission,
      'displacement': displacement,
      'series_number': seriesNumber,
      'manufacture_location': manufactureLocation,
      'image_url': imageUrl,
    };
  }

  String get displayName {
    final parts = <String>[make, model];
    if (motorization != null) parts.add(motorization!);
    return parts.join(' ');
  }
}
