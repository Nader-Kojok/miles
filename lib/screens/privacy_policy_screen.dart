import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          'Politique de Confidentialité',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chez Miles, nous prenons très au sérieux la confidentialité et la protection de vos données personnelles.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Données collectées',
              'Nous collectons les informations suivantes:\n\n'
              '• Nom complet et prénom\n'
              '• Adresse email\n'
              '• Numéro de téléphone\n'
              '• Adresse de livraison\n'
              '• Informations de paiement (traitées de manière sécurisée par nos prestataires)\n'
              '• Historique des commandes\n'
              '• Données de navigation (cookies)',
            ),
            _buildSection(
              '2. Utilisation des données',
              'Vos données sont utilisées pour:\n\n'
              '• Traiter vos commandes et assurer la livraison\n'
              '• Vous contacter concernant vos commandes\n'
              '• Améliorer nos services\n'
              '• Vous envoyer des offres promotionnelles (avec votre consentement)\n'
              '• Analyser l\'utilisation de notre application',
            ),
            _buildSection(
              '3. Partage des données',
              'Nous ne vendons jamais vos données personnelles. Vos données peuvent être partagées avec:\n\n'
              '• Prestataires de paiement (Wave, Orange Money, etc.)\n'
              '• Sociétés de livraison\n'
              '• Fournisseurs de services d\'analyse\n\n'
              'Ces partenaires sont contractuellement tenus de protéger vos données.',
            ),
            _buildSection(
              '4. Cookies et tracking',
              'Nous utilisons des cookies pour:\n\n'
              '• Maintenir votre session active\n'
              '• Mémoriser vos préférences\n'
              '• Analyser le trafic avec Google Analytics\n\n'
              'Vous pouvez désactiver les cookies dans les paramètres de votre navigateur.',
            ),
            _buildSection(
              '5. Sécurité des données',
              'Nous mettons en œuvre des mesures techniques et organisationnelles appropriées pour protéger vos données:\n\n'
              '• Cryptage des données sensibles\n'
              '• Serveurs sécurisés\n'
              '• Accès restreint aux données personnelles\n'
              '• Audits de sécurité réguliers',
            ),
            _buildSection(
              '6. Vos droits',
              'Conformément à la législation en vigueur, vous avez le droit de:\n\n'
              '• Accéder à vos données personnelles\n'
              '• Rectifier vos données\n'
              '• Supprimer vos données\n'
              '• Vous opposer au traitement de vos données\n'
              '• Exporter vos données\n\n'
              'Pour exercer ces droits, contactez-nous à privacy@miles.sn',
            ),
            _buildSection(
              '7. Conservation des données',
              'Nous conservons vos données pendant la durée nécessaire aux finalités pour lesquelles elles ont été collectées:\n\n'
              '• Données de compte: Tant que votre compte est actif\n'
              '• Historique de commandes: 3 ans après la dernière commande\n'
              '• Données de paiement: Selon les exigences légales',
            ),
            _buildSection(
              '8. Modifications de la politique',
              'Nous pouvons modifier cette politique de temps en temps. '
              'Nous vous informerons de tout changement significatif par email ou via une notification dans l\'application.',
            ),
            _buildSection(
              '9. Contact',
              'Pour toute question concernant cette politique de confidentialité ou vos données personnelles:\n\n'
              'Email: privacy@miles.sn\n'
              'Téléphone: +221 33 123 4567\n'
              'Adresse: Dakar, Sénégal',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Dernière mise à jour: 30 Octobre 2025',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
