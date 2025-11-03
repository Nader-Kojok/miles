import 'package:flutter/material.dart';
import 'assistance_screen.dart';

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  State<FAQScreen> createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<FAQCategory> _categories = [
    FAQCategory(
      icon: Icons.shopping_bag,
      title: 'Commandes & Livraison',
      faqs: [
        FAQ(
          question: 'Comment suivre ma commande ?',
          answer: 'Pour suivre votre commande, accédez à l\'onglet "Commandes" depuis le menu principal. '
              'Vous y trouverez l\'état de votre commande en temps réel et le numéro de suivi si elle a été expédiée.',
        ),
        FAQ(
          question: 'Quels sont les délais de livraison ?',
          answer: 'Les délais de livraison varient selon votre zone:\n\n'
              '• Dakar: 24-48h\n'
              '• Régions: 3-5 jours\n\n'
              'Livraison gratuite pour toute commande supérieure à 50,000 FCFA.',
        ),
        FAQ(
          question: 'Puis-je modifier mon adresse de livraison ?',
          answer: 'Vous pouvez modifier votre adresse de livraison tant que votre commande n\'a pas été expédiée. '
              'Contactez notre service client au +221 33 123 4567.',
        ),
      ],
    ),
    FAQCategory(
      icon: Icons.payment,
      title: 'Paiement',
      faqs: [
        FAQ(
          question: 'Quels sont les moyens de paiement acceptés ?',
          answer: 'Nous acceptons:\n\n'
              '• Wave\n'
              '• Orange Money (App & USSD)\n'
              '• Max It\n'
              '• Carte bancaire (Visa, Mastercard)\n\n'
              'Tous les paiements sont sécurisés.',
        ),
        FAQ(
          question: 'Est-ce sécurisé de payer en ligne ?',
          answer: 'Oui, absolument. Toutes les transactions sont cryptées avec le protocole SSL. '
              'Nous ne stockons jamais vos informations bancaires. '
              'Les paiements sont traités par des prestataires certifiés PCI DSS.',
        ),
        FAQ(
          question: 'Puis-je payer à la livraison ?',
          answer: 'Le paiement à la livraison n\'est pas disponible pour le moment. '
              'Nous travaillons à ajouter cette option prochainement.',
        ),
      ],
    ),
    FAQCategory(
      icon: Icons.assignment_return,
      title: 'Retours & Remboursements',
      faqs: [
        FAQ(
          question: 'Comment retourner un produit ?',
          answer: 'Vous disposez de 14 jours pour retourner un produit:\n\n'
              '1. Contactez le service client\n'
              '2. Retournez le produit dans son emballage d\'origine\n'
              '3. Recevez votre remboursement sous 7-14 jours',
        ),
        FAQ(
          question: 'Quels produits peuvent être retournés ?',
          answer: 'Tous les produits peuvent être retournés sauf:\n\n'
              '• Produits personnalisés\n'
              '• Produits ouverts ou utilisés\n'
              '• Produits sans emballage d\'origine',
        ),
        FAQ(
          question: 'Combien de temps pour recevoir mon remboursement ?',
          answer: 'Le remboursement est traité sous 7-14 jours ouvrés après réception du produit retourné. '
              'Il sera crédité sur le même moyen de paiement utilisé lors de l\'achat.',
        ),
      ],
    ),
    FAQCategory(
      icon: Icons.person,
      title: 'Compte',
      faqs: [
        FAQ(
          question: 'Comment créer un compte ?',
          answer: 'Téléchargez l\'application et créez votre compte en quelques secondes avec:\n\n'
              '• Votre numéro de téléphone\n'
              '• Votre compte Google\n\n'
              'Vous recevrez un code de vérification par SMS.',
        ),
        FAQ(
          question: 'J\'ai oublié mon mot de passe',
          answer: 'Sur l\'écran de connexion, cliquez sur "Mot de passe oublié". '
              'Entrez votre numéro de téléphone et suivez les instructions pour réinitialiser votre mot de passe.',
        ),
        FAQ(
          question: 'Comment supprimer mon compte ?',
          answer: 'Pour supprimer votre compte:\n\n'
              '1. Allez dans Paramètres\n'
              '2. Sélectionnez "Supprimer mon compte"\n'
              '3. Confirmez la suppression\n\n'
              'Cette action est irréversible.',
        ),
      ],
    ),
    FAQCategory(
      icon: Icons.security,
      title: 'Sécurité',
      faqs: [
        FAQ(
          question: 'Mes données sont-elles protégées ?',
          answer: 'Oui, nous prenons la sécurité très au sérieux:\n\n'
              '• Cryptage SSL de toutes les communications\n'
              '• Serveurs sécurisés\n'
              '• Conformité RGPD\n'
              '• Pas de partage de données avec des tiers',
        ),
        FAQ(
          question: 'Comment signaler une activité suspecte ?',
          answer: 'Si vous remarquez une activité suspecte sur votre compte, '
              'contactez immédiatement notre service client au +221 33 123 4567 '
              'ou par email à security@bolide.sn',
        ),
      ],
    ),
  ];

  List<FAQCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;

    return _categories.map((category) {
      final filteredFAQs = category.faqs.where((faq) {
        return faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            faq.answer.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();

      return FAQCategory(
        icon: category.icon,
        title: category.title,
        faqs: filteredFAQs,
      );
    }).where((category) => category.faqs.isNotEmpty).toList();
  }

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
          'Centre d\'aide',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher dans l\'aide...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
            ),
          ),

          // FAQ List
          Expanded(
            child: _filteredCategories.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredCategories.length,
                    itemBuilder: (context, index) {
                      return _FAQCategorySection(
                        category: _filteredCategories[index],
                      );
                    },
                  ),
          ),

          // Contact Support Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Vous n\'avez pas trouvé la réponse ?',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  icon: const Icon(Icons.support_agent, color: Colors.white),
                  label: const Text('Contacter le support', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AssistanceScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Aucun résultat trouvé',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Essayez avec d\'autres mots-clés',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}

class _FAQCategorySection extends StatelessWidget {
  final FAQCategory category;

  const _FAQCategorySection({required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(category.icon, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        ...category.faqs.map((faq) => _FAQItem(faq: faq)),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _FAQItem extends StatefulWidget {
  final FAQ faq;

  const _FAQItem({required this.faq});

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isHelpful = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.faq.question,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.faq.answer,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  Row(
                    children: [
                      const Text(
                        'Cet article vous a-t-il été utile ?',
                        style: TextStyle(fontSize: 13),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        icon: Icon(
                          _isHelpful ? Icons.thumb_up : Icons.thumb_up_outlined,
                          size: 16,
                        ),
                        label: const Text('Oui'),
                        onPressed: () {
                          setState(() => _isHelpful = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Merci pour votre retour !'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.thumb_down_outlined, size: 16),
                        label: const Text('Non'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Nous allons améliorer cet article'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FAQCategory {
  final IconData icon;
  final String title;
  final List<FAQ> faqs;

  FAQCategory({
    required this.icon,
    required this.title,
    required this.faqs,
  });
}

class FAQ {
  final String question;
  final String answer;

  FAQ({
    required this.question,
    required this.answer,
  });
}
