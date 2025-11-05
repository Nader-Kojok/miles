import 'package:flutter/material.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

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
          'À propos de nous',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'B',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'MILES',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pièces détachées automobiles',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 40),
            
            // Mission
            _buildSection(
              icon: Icons.stars,
              title: 'Notre mission',
              content: 'Faciliter l\'accès aux pièces détachées automobiles de qualité au Sénégal. '
                  'Nous connectons les automobilistes avec les meilleurs fournisseurs pour garantir '
                  'des produits authentiques et abordables.',
            ),
            
            const SizedBox(height: 24),
            
            // Stats
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStat('5+', 'Années'),
                  _buildDivider(),
                  _buildStat('10K+', 'Produits'),
                  _buildDivider(),
                  _buildStat('25K+', 'Clients'),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Values
            _buildSection(
              icon: Icons.verified,
              title: 'Nos valeurs',
              content: '• Qualité garantie\n'
                  '• Livraison rapide\n'
                  '• Prix compétitifs\n'
                  '• Service client réactif\n'
                  '• Satisfaction client',
            ),
            
            const SizedBox(height: 32),
            
            // Contact
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Contactez-nous',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            _buildContactItem(
              icon: Icons.email,
              text: 'contact@miles.sn',
            ),
            _buildContactItem(
              icon: Icons.phone,
              text: '+221 33 123 4567',
            ),
            _buildContactItem(
              icon: Icons.location_on,
              text: 'Dakar, Sénégal',
            ),
            
            const SizedBox(height: 24),
            
            // Social Media
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildSocialIcon(Icons.facebook),
                const SizedBox(width: 16),
                _buildSocialIcon(Icons.close), // Twitter X
                const SizedBox(width: 16),
                _buildSocialIcon(Icons.camera_alt), // Instagram
              ],
            ),
            
            const SizedBox(height: 40),
            
            // Version
            Text(
              'Version 1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '© 2025 Miles. Tous droits réservés.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 40,
      color: Colors.grey[300],
    );
  }

  Widget _buildContactItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}
