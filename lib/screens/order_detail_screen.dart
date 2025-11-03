import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderNumber;
  final String status; // 'processing', 'shipped', 'delivered', 'cancelled'

  const OrderDetailScreen({
    super.key,
    required this.orderNumber,
    this.status = 'shipped',
  });

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
        title: Text(
          'Commande #$orderNumber',
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: () => _shareOrder(context),
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.black),
            onPressed: () => _downloadInvoice(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Badge
            _buildStatusBadge(),
            
            const SizedBox(height: 24),
            
            // Order Timeline
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildOrderTimeline(),
            ),
            
            const SizedBox(height: 32),
            
            // Products Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Produits commandés',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildProductsList(),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Delivery Information
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildDeliveryInfo(),
            ),
            
            const SizedBox(height: 32),
            
            // Payment Summary
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildPaymentSummary(),
            ),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: _buildActionButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String statusText;
    IconData icon;
    
    switch (status) {
      case 'processing':
        badgeColor = AppColors.statusProcessing;
        statusText = 'En cours de traitement';
        icon = Icons.pending;
        break;
      case 'shipped':
        badgeColor = AppColors.statusShipped;
        statusText = 'Expédiée';
        icon = Icons.local_shipping;
        break;
      case 'delivered':
        badgeColor = AppColors.statusDelivered;
        statusText = 'Livrée';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        badgeColor = AppColors.statusCancelled;
        statusText = 'Annulée';
        icon = Icons.cancel;
        break;
      default:
        badgeColor = AppColors.disabled;
        statusText = 'Inconnu';
        icon = Icons.help;
    }
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Livraison prévue le 24 Oct 2025',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTimeline() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Suivi de commande',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        _TimelineStep(
          title: 'Commande confirmée',
          date: '20 Oct 2025, 14:30',
          isCompleted: true,
          icon: Icons.check_circle,
        ),
        _TimelineStep(
          title: 'Préparation en cours',
          date: '21 Oct 2025, 09:15',
          isCompleted: true,
          icon: Icons.inventory,
        ),
        _TimelineStep(
          title: 'Expédiée',
          date: '22 Oct 2025, 11:00',
          isCompleted: true,
          isActive: status == 'shipped',
          icon: Icons.local_shipping,
        ),
        _TimelineStep(
          title: 'Livraison prévue',
          date: '24 Oct 2025',
          isCompleted: status == 'delivered',
          isActive: false,
          isLast: true,
          icon: Icons.home,
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    // Mock data - replace with actual data
    final products = [
      {
        'name': 'Plaquettes de frein avant',
        'quantity': 2,
        'price': 45000,
      },
      {
        'name': 'Filtre à huile moteur',
        'quantity': 1,
        'price': 15000,
      },
    ];
    
    return Column(
      children: products.map((product) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.car_repair, size: 30),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(product['price'] as int).toStringAsFixed(0)} F',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'x${product['quantity']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDeliveryInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations de livraison',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildInfoRow('Nom', 'Fanta Diallo'),
              const SizedBox(height: 12),
              _buildInfoRow('Téléphone', '+221 77 123 4567'),
              const SizedBox(height: 12),
              _buildInfoRow('Adresse', 'Hann Maristes, Rue Broche Durée, 228'),
              const SizedBox(height: 12),
              _buildInfoRow('Ville', 'Dakar, Sénégal'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Récapitulatif du paiement',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildSummaryRow('Sous-total', '105,000 F'),
              const SizedBox(height: 8),
              _buildSummaryRow('Frais de livraison', 'Gratuit', valueColor: AppColors.success),
              const SizedBox(height: 8),
              _buildSummaryRow('Code promo', '-10,500 F', valueColor: AppColors.warning),
              const Divider(height: 24),
              _buildSummaryRow('TOTAL', '94,500 F', isTotal: true),
              const Divider(height: 24),
              _buildInfoRow('Méthode de paiement', 'Wave'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value, {Color? valueColor, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.support_agent),
                label: const Text('Contacter'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _contactSupport(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('Facture'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _downloadInvoice(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (status == 'shipped')
          ElevatedButton.icon(
            icon: const Icon(Icons.local_shipping),
            label: const Text('Suivre le colis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _trackPackage(context),
          ),
        if (status == 'delivered')
          OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Commander à nouveau'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => _reorder(context),
          ),
      ],
    );
  }

  void _shareOrder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Partage de la commande...')),
    );
  }

  void _downloadInvoice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Facture téléchargée'),
          ],
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _contactSupport(BuildContext context) {
    // Navigate to assistance screen or open chat
  }

  void _trackPackage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ouverture du suivi de colis...')),
    );
  }

  void _reorder(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ajout au panier...')),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String title;
  final String date;
  final bool isCompleted;
  final bool isActive;
  final bool isLast;
  final IconData icon;

  const _TimelineStep({
    required this.title,
    required this.date,
    required this.isCompleted,
    this.isActive = false,
    this.isLast = false,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isActive ? Colors.black : Colors.white,
                  border: Border.all(
                    color: isCompleted || isActive ? Colors.black : Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Icon(
                        icon,
                        color: isActive ? Colors.white : Colors.grey,
                        size: 20,
                      ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 60,
                  color: isCompleted ? Colors.black : Colors.grey[300],
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isCompleted || isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isCompleted || isActive ? Colors.black : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
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
