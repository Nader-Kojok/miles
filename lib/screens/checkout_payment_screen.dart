import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/biometric_auth_service.dart';
import 'checkout_confirmation_screen.dart';

class CheckoutPaymentScreen extends StatefulWidget {
  const CheckoutPaymentScreen({super.key});

  @override
  State<CheckoutPaymentScreen> createState() => _CheckoutPaymentScreenState();
}

class _CheckoutPaymentScreenState extends State<CheckoutPaymentScreen> {
  final _biometricService = BiometricAuthService();
  String? _selectedPaymentMethod;
  bool _biometricAvailable = false;
  String _biometricType = '';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final canAuth = await _biometricService.canCheckBiometrics();
    if (canAuth) {
      final biometrics = await _biometricService.getAvailableBiometrics();
      final typeName = _biometricService.getBiometricTypeName(biometrics);
      setState(() {
        _biometricAvailable = true;
        _biometricType = typeName;
      });
    }
  }

  Future<void> _confirmPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un mode de paiement'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Require biometric authentication if available
    if (_biometricAvailable) {
      final authenticated = await _biometricService.authenticateForCheckout();
      
      if (!authenticated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentification $_biometricType requise pour confirmer le paiement'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    // Proceed to confirmation
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const CheckoutConfirmationScreen(),
        ),
      );
    }
  }

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'wave',
      'name': 'Wave',
      'icon': Icons.account_balance_wallet,
      'color': AppColors.info,
    },
    {
      'id': 'max_it',
      'name': 'Max it',
      'icon': Icons.payment,
      'color': AppColors.warning,
    },
    {
      'id': 'orange_money_app',
      'name': 'Orange Money (Application)',
      'icon': Icons.phone_android,
      'color': AppColors.statusProcessing,
    },
    {
      'id': 'orange_money_ussd',
      'name': 'Orange Money (USSD)',
      'icon': Icons.dialpad,
      'color': AppColors.statusProcessing,
    },
    {
      'id': 'carte',
      'name': 'Carte bancaire',
      'icon': Icons.credit_card,
      'color': AppColors.primary,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Paiement',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: const [
                Icon(Icons.lock_outline, size: 18, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Paiement sécurisé',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Indicateur d'étapes
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Row(
              children: [
                _StepIndicator(
                  number: 1,
                  label: 'Livraison',
                  isActive: false,
                  isCompleted: true,
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: Colors.black,
                  ),
                ),
                _StepIndicator(
                  number: 2,
                  label: 'Paiement',
                  isActive: true,
                  isCompleted: false,
                ),
                Expanded(
                  child: Container(
                    height: 2,
                    color: Colors.grey[300],
                  ),
                ),
                _StepIndicator(
                  number: 3,
                  label: 'Confirmation',
                  isActive: false,
                  isCompleted: false,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Titre
          const Padding(
            padding: EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Choisissez un moyen de paiement',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Liste des moyens de paiement
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                final isSelected = _selectedPaymentMethod == method['id'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = method['id'];
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: (method['color'] as Color).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              method['icon'] as IconData,
                              color: method['color'] as Color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              method['name'],
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.black : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Bouton Continuer
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _selectedPaymentMethod != null ? _confirmPayment : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_biometricAvailable) ...[
                    Icon(
                      _biometricType.contains('Face') ? Icons.face : Icons.fingerprint,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepIndicator({
    required this.number,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isCompleted ? Colors.black : Colors.white,
            border: Border.all(
              color: isActive || isCompleted ? Colors.black : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : Colors.grey,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }
}
