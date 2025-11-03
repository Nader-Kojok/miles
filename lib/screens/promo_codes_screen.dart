import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PromoCodesScreen extends StatefulWidget {
  const PromoCodesScreen({super.key});

  @override
  State<PromoCodesScreen> createState() => _PromoCodesScreenState();
}

class _PromoCodesScreenState extends State<PromoCodesScreen> {
  // Mock promo codes data
  final List<PromoCode> _activeCodes = [
    PromoCode(
      code: 'BOLID10',
      discount: 10,
      description: '10% de réduction sur tout',
      expiryDate: DateTime.now().add(const Duration(days: 15)),
      minAmount: 50000,
      isActive: true,
    ),
    PromoCode(
      code: 'FIRST20',
      discount: 20,
      description: '20% pour votre première commande',
      expiryDate: DateTime.now().add(const Duration(days: 30)),
      minAmount: 0,
      isActive: true,
    ),
    PromoCode(
      code: 'FREINS15',
      discount: 15,
      description: '15% sur tous les freins',
      expiryDate: DateTime.now().add(const Duration(days: 7)),
      minAmount: 30000,
      isActive: true,
    ),
  ];

  final List<PromoCode> _expiredCodes = [
    PromoCode(
      code: 'NOEL25',
      discount: 25,
      description: 'Promo de Noël - 25% de réduction',
      expiryDate: DateTime.now().subtract(const Duration(days: 30)),
      minAmount: 100000,
      isActive: false,
    ),
  ];

  void _copyCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Code "$code" copié'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _applyCode(String code) {
    Navigator.pop(context, code);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code "$code" appliqué au panier'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Codes promo',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Active Codes
          if (_activeCodes.isNotEmpty) ...[
            const Text(
              'Codes actifs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._activeCodes.map((code) => _PromoCodeCard(
                  promoCode: code,
                  onCopy: () => _copyCode(code.code),
                  onApply: () => _applyCode(code.code),
                )),
          ],

          // Expired Codes
          if (_expiredCodes.isNotEmpty) ...[
            const SizedBox(height: 24),
            ExpansionTile(
              title: const Text(
                'Codes expirés',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: _expiredCodes
                  .map((code) => _PromoCodeCard(
                        promoCode: code,
                        onCopy: () => _copyCode(code.code),
                        onApply: null,
                      ))
                  .toList(),
            ),
          ],

          const SizedBox(height: 32),

          // Info section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    const Text(
                      'Comment utiliser un code promo ?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '1. Copiez le code promo\n'
                  '2. Ajoutez des produits à votre panier\n'
                  '3. Collez le code dans le champ prévu à cet effet\n'
                  '4. Profitez de votre réduction !',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PromoCodeCard extends StatelessWidget {
  final PromoCode promoCode;
  final VoidCallback onCopy;
  final VoidCallback? onApply;

  const _PromoCodeCard({
    required this.promoCode,
    required this.onCopy,
    this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final isExpired = !promoCode.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isExpired
            ? LinearGradient(
                colors: [Colors.grey[300]!, Colors.grey[400]!],
              )
            : const LinearGradient(
                colors: [Color(0xFFFF9500), Color(0xFFFF6B00)],
              ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Left side - Code info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    promoCode.code,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    promoCode.description,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isExpired
                            ? 'Expiré le ${_formatDate(promoCode.expiryDate)}'
                            : 'Expire le ${_formatDate(promoCode.expiryDate)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (promoCode.minAmount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Minimum ${promoCode.minAmount.toStringAsFixed(0)} F',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Dashed divider
          CustomPaint(
            size: const Size(1, 100),
            painter: _DashedLinePainter(),
          ),

          // Right side - Actions
          SizedBox(
            width: 80,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.content_copy, color: Colors.white),
                  onPressed: onCopy,
                  tooltip: 'Copier',
                ),
                const Text(
                  'Copier',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                if (onApply != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onApply,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                    ),
                    child: const Text(
                      'Appliquer',
                      style: TextStyle(
                        color: Color(0xFFFF9500),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    const dashHeight = 5;
    const dashSpace = 5;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(0, startY),
        Offset(0, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PromoCode {
  final String code;
  final int discount;
  final String description;
  final DateTime expiryDate;
  final double minAmount;
  final bool isActive;

  PromoCode({
    required this.code,
    required this.discount,
    required this.description,
    required this.expiryDate,
    required this.minAmount,
    required this.isActive,
  });
}
