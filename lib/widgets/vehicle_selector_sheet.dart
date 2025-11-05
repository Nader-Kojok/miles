import 'package:flutter/material.dart';
import '../services/vehicle_service.dart';
import '../models/vehicle.dart';
import 'vehicle_result_sheet.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleSelectorSheet extends StatefulWidget {
  const VehicleSelectorSheet({super.key});

  @override
  State<VehicleSelectorSheet> createState() => _VehicleSelectorSheetState();
}

class _VehicleSelectorSheetState extends State<VehicleSelectorSheet> {
  final VehicleService _vehicleService = VehicleService();
  final TextEditingController _chassisController = TextEditingController();
  
  List<String> _makes = [];
  List<String> _models = [];
  List<String> _motorizations = [];
  
  String? _selectedMake;
  String? _selectedModel;
  String? _selectedMotorization;
  
  bool _isLoadingMakes = true;
  bool _isLoadingModels = false;
  bool _isLoadingMotorizations = false;

  @override
  void initState() {
    super.initState();
    _loadMakes();
  }

  Future<void> _loadMakes() async {
    setState(() => _isLoadingMakes = true);
    try {
      final makes = await _vehicleService.getMakes();
      setState(() {
        _makes = makes;
        _isLoadingMakes = false;
      });
    } catch (e) {
      setState(() => _isLoadingMakes = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _loadModels(String make) async {
    setState(() {
      _isLoadingModels = true;
      _selectedModel = null;
      _selectedMotorization = null;
      _models = [];
      _motorizations = [];
    });
    
    try {
      final models = await _vehicleService.getModels(make);
      setState(() {
        _models = models;
        _isLoadingModels = false;
      });
    } catch (e) {
      setState(() => _isLoadingModels = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _loadMotorizations(String make, String model) async {
    setState(() {
      _isLoadingMotorizations = true;
      _selectedMotorization = null;
      _motorizations = [];
    });
    
    try {
      final motorizations = await _vehicleService.getMotorizations(make, model);
      setState(() {
        _motorizations = motorizations;
        _isLoadingMotorizations = false;
      });
    } catch (e) {
      setState(() => _isLoadingMotorizations = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _searchByChassis() async {
    if (_chassisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un numéro de châssis')),
      );
      return;
    }
    
    try {
      final vehicle = await _vehicleService.getVehicleByChassisNumber(
        _chassisController.text,
      );
      
      if (vehicle != null) {
        _showVehicleResult(vehicle);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Véhicule non trouvé')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _searchBySelection() async {
    if (_selectedMake == null || _selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins le fabricant et le modèle')),
      );
      return;
    }
    
    try {
      final vehicle = await _vehicleService.getVehicle(
        make: _selectedMake!,
        model: _selectedModel!,
        motorization: _selectedMotorization,
      );
      
      if (vehicle != null) {
        _showVehicleResult(vehicle);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  void _showVehicleResult(Vehicle vehicle) {
    Navigator.pop(context); // Close current sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VehicleResultSheet(vehicle: vehicle),
    );
  }

  Future<void> _launchWhatsApp() async {
    final Uri url = Uri.parse('https://wa.me/1234567890');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir WhatsApp')),
        );
      }
    }
  }

  Future<void> _launchPhone() async {
    final Uri url = Uri.parse('tel:+1234567890');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d\'ouvrir le téléphone')),
        );
      }
    }
  }

  @override
  void dispose() {
    _chassisController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Search Modal',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Chassis Number Section
                  Row(
                    children: [
                      const Text(
                        'Numéro de châssis',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.help_outline,
                        size: 18,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: TextField(
                      controller: _chassisController,
                      decoration: InputDecoration(
                        hintText: 'KM8 SRDHF5 EUI23456',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      ),
                      onSubmitted: (_) => _searchByChassis(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider with "ou"
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Fabricant (Make)
                  const Text(
                    'Fabricant',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _isLoadingMakes
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            initialValue: _selectedMake,
                            decoration: InputDecoration(
                              hintText: 'Choisissez une marque',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: _makes.map((make) {
                              return DropdownMenuItem(
                                value: make,
                                child: Text(make),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _selectedMake = value);
                              if (value != null) {
                                _loadModels(value);
                              }
                            },
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Modèle (Model)
                  const Text(
                    'Modèle',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _isLoadingModels
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            initialValue: _selectedModel,
                            decoration: InputDecoration(
                              hintText: 'Choisissez votre modèle',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: _models.map((model) {
                              return DropdownMenuItem(
                                value: model,
                                child: Text(model),
                              );
                            }).toList(),
                            onChanged: _selectedMake == null
                                ? null
                                : (value) {
                                    setState(() => _selectedModel = value);
                                    if (value != null && _selectedMake != null) {
                                      _loadMotorizations(_selectedMake!, value);
                                    }
                                  },
                          ),
                  ),

                  const SizedBox(height: 20),

                  // Motorisation
                  const Text(
                    'Motorisation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: _isLoadingMotorizations
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            ),
                          )
                        : DropdownButtonFormField<String>(
                            initialValue: _selectedMotorization,
                            decoration: InputDecoration(
                              hintText: 'Choisissez votre moteur',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            icon: const Icon(Icons.keyboard_arrow_down),
                            items: _motorizations.map((motorization) {
                              return DropdownMenuItem(
                                value: motorization,
                                child: Text(
                                  motorization,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: _selectedModel == null
                                ? null
                                : (value) {
                                    setState(() => _selectedMotorization = value);
                                  },
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Search button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _selectedMake != null && _selectedModel != null
                          ? _searchBySelection
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Rechercher',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider with "ou"
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'ou',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Contact buttons
                  InkWell(
                    onTap: _launchWhatsApp,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF25D366),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.chat,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Contacter par WhatsApp',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  InkWell(
                    onTap: _launchPhone,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.phone,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Appeler un commercial',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
