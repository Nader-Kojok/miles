import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

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
          'Conditions Générales',
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
            _buildSection(
              '1. Acceptation des conditions',
              'En accédant et en utilisant l\'application Miles, vous acceptez d\'être lié par ces conditions générales d\'utilisation. '
              'Si vous n\'acceptez pas ces conditions, veuillez ne pas utiliser l\'application.',
            ),
            _buildSection(
              '2. Utilisation du service',
              'L\'application Miles est destinée à faciliter l\'achat et la vente de pièces détachées automobiles. '
              'Vous vous engagez à utiliser ce service de manière légale et éthique.',
            ),
            _buildSection(
              '3. Compte utilisateur',
              'Vous êtes responsable de maintenir la confidentialité de votre compte et de votre mot de passe. '
              'Vous acceptez de nous informer immédiatement de toute utilisation non autorisée de votre compte.',
            ),
            _buildSection(
              '4. Commandes et paiements',
              'Toutes les commandes sont soumises à disponibilité et à confirmation du prix. '
              'Les paiements sont sécurisés et traités par des services tiers de confiance. '
              'Les prix sont affichés en FCFA et incluent toutes les taxes applicables.',
            ),
            _buildSection(
              '5. Livraison',
              'Nous nous efforçons de livrer dans les délais annoncés. Cependant, les délais de livraison sont indicatifs '
              'et peuvent varier en fonction des circonstances. Nous ne sommes pas responsables des retards de livraison indépendants de notre volonté.',
            ),
            _buildSection(
              '6. Retours et remboursements',
              'Les produits peuvent être retournés dans les 14 jours suivant la réception, à condition qu\'ils soient dans leur emballage d\'origine. '
              'Les remboursements seront effectués dans un délai de 14 jours après réception du produit retourné.',
            ),
            _buildSection(
              '7. Garanties',
              'Tous les produits vendus sont garantis contre les défauts de fabrication conformément aux conditions du fabricant. '
              'La garantie ne couvre pas l\'usure normale ou les dommages causés par une mauvaise utilisation.',
            ),
            _buildSection(
              '8. Responsabilités',
              'Nous ne sommes pas responsables des dommages indirects ou consécutifs résultant de l\'utilisation de nos produits. '
              'Notre responsabilité est limitée au montant payé pour le produit.',
            ),
            _buildSection(
              '9. Propriété intellectuelle',
              'Tous les contenus de l\'application (textes, images, logos) sont protégés par le droit d\'auteur et appartiennent à Miles. '
              'Toute reproduction sans autorisation est interdite.',
            ),
            _buildSection(
              '10. Modifications',
              'Nous nous réservons le droit de modifier ces conditions à tout moment. '
              'Les modifications entreront en vigueur dès leur publication sur l\'application.',
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
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Pour toute question, contactez-nous à contact@miles.sn',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
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
