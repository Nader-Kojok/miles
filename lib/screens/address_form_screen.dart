import 'package:flutter/material.dart';
import '../models/address.dart';
import '../services/profile_service.dart';

class AddressFormScreen extends StatefulWidget {
  final Address? address;

  const AddressFormScreen({super.key, this.address});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileService _profileService = ProfileService();
  late TextEditingController _labelController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressLine1Controller;
  late TextEditingController _addressLine2Controller;
  late TextEditingController _cityController;
  late TextEditingController _postalCodeController;
  String _selectedCountry = 'Sénégal';
  bool _isDefault = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final address = widget.address;
    _labelController = TextEditingController(text: address?.label ?? '');
    _fullNameController = TextEditingController(text: address?.fullName ?? '');
    _phoneController = TextEditingController(text: address?.phone ?? '');
    _addressLine1Controller = TextEditingController(text: address?.addressLine1 ?? '');
    _addressLine2Controller = TextEditingController(text: address?.addressLine2 ?? '');
    _cityController = TextEditingController(text: address?.city ?? '');
    _postalCodeController = TextEditingController(text: address?.postalCode ?? '');
    _selectedCountry = address?.country ?? 'Sénégal';
    _isDefault = address?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSaving = true);
      
      try {
        if (widget.address == null) {
          // Add new address
          await _profileService.addAddress(
            label: _labelController.text,
            fullName: _fullNameController.text,
            phone: _phoneController.text,
            addressLine1: _addressLine1Controller.text,
            addressLine2: _addressLine2Controller.text.isEmpty ? null : _addressLine2Controller.text,
            city: _cityController.text,
            postalCode: _postalCodeController.text.isEmpty ? null : _postalCodeController.text,
            country: _selectedCountry,
            isDefault: _isDefault,
          );
        } else {
          // Update existing address
          await _profileService.updateAddress(
            widget.address!.id,
            label: _labelController.text,
            fullName: _fullNameController.text,
            phone: _phoneController.text,
            addressLine1: _addressLine1Controller.text,
            addressLine2: _addressLine2Controller.text.isEmpty ? null : _addressLine2Controller.text,
            city: _cityController.text,
            postalCode: _postalCodeController.text.isEmpty ? null : _postalCodeController.text,
            country: _selectedCountry,
            isDefault: _isDefault,
          );
        }
        
        if (mounted) {
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() => _isSaving = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEditing ? 'Modifier l\'adresse' : 'Nouvelle adresse',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildTextField(
              controller: _labelController,
              label: 'Libellé',
              hint: 'Ex: Domicile, Bureau, Autre',
              icon: Icons.label,
              validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _fullNameController,
              label: 'Nom complet',
              icon: Icons.person,
              validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _phoneController,
              label: 'Numéro de téléphone',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressLine1Controller,
              label: 'Adresse ligne 1',
              icon: Icons.location_on,
              validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _addressLine2Controller,
              label: 'Adresse ligne 2 (optionnel)',
              icon: Icons.location_on,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'Ville',
                    icon: Icons.location_city,
                    validator: (value) => value?.isEmpty ?? true ? 'Requis' : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    controller: _postalCodeController,
                    label: 'Code postal',
                    icon: Icons.local_post_office,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCountry,
              decoration: InputDecoration(
                labelText: 'Pays',
                prefixIcon: const Icon(Icons.flag),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: ['Sénégal', 'Mali', 'Côte d\'Ivoire', 'Guinée', 'Burkina Faso']
                  .map((country) => DropdownMenuItem(
                        value: country,
                        child: Text(country),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCountry = value);
                }
              },
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Définir comme adresse par défaut'),
              value: _isDefault,
              onChanged: (value) {
                setState(() => _isDefault = value);
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _isSaving ? null : _saveAddress,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      isEditing ? 'Enregistrer les modifications' : 'Ajouter l\'adresse',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      validator: validator,
    );
  }
}
