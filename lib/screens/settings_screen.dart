import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'welcome_screen.dart';
import 'faq_screen.dart';
import 'about_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _supabaseService = SupabaseService();
  bool _pushNotifications = true;
  bool _orderNotifications = true;
  bool _promoNotifications = false;
  bool _newsNotifications = true;
  bool _darkMode = false;
  String _language = 'Français';
  String _currency = 'FCFA';

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Check if user is authenticated
    if (!_supabaseService.isAuthenticated) {
      // Redirect to welcome screen
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.settings, color: Colors.black, size: 22),
            SizedBox(width: 8),
            Text(
              'Paramètres',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Configurez votre expérience d\'application',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildSection(
            title: 'NOTIFICATIONS',
            children: [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Notifications push',
                value: _pushNotifications,
                onChanged: (value) => setState(() => _pushNotifications = value),
              ),
              _buildSwitchTile(
                icon: Icons.shopping_bag,
                title: 'Commandes',
                subtitle: 'Mise à jour de vos commandes',
                value: _orderNotifications,
                onChanged: (value) => setState(() => _orderNotifications = value),
              ),
              _buildSwitchTile(
                icon: Icons.local_offer,
                title: 'Promotions',
                subtitle: 'Offres spéciales et réductions',
                value: _promoNotifications,
                onChanged: (value) => setState(() => _promoNotifications = value),
              ),
              _buildSwitchTile(
                icon: Icons.stars,
                title: 'Nouveautés',
                subtitle: 'Nouveaux produits et fonctionnalités',
                value: _newsNotifications,
                onChanged: (value) => setState(() => _newsNotifications = value),
              ),
            ],
          ),
          _buildSection(
            title: 'PRÉFÉRENCES',
            children: [
              _buildListTile(
                icon: Icons.language,
                title: 'Langue',
                trailing: Text(_language, style: const TextStyle(color: Colors.grey)),
                onTap: () => _showLanguageDialog(),
              ),
              _buildListTile(
                icon: Icons.attach_money,
                title: 'Devise',
                trailing: Text(_currency, style: const TextStyle(color: Colors.grey)),
                onTap: () => _showCurrencyDialog(),
              ),
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Mode sombre',
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
              ),
            ],
          ),
          _buildSection(
            title: 'AIDE & SUPPORT',
            children: [
              _buildListTile(
                icon: Icons.help,
                title: 'Centre d\'aide',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FAQScreen()),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.contact_support,
                title: 'Nous contacter',
                onTap: () {
                  // TODO: Open contact form or email
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Contact: support@bolide.com')),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.bug_report,
                title: 'Signaler un problème',
                onTap: () {
                  // TODO: Open issue reporting form
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Envoyez vos rapports à support@bolide.com')),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: 'LÉGAL',
            children: [
              _buildListTile(
                icon: Icons.description,
                title: 'Conditions générales',
                onTap: () {
                  // TODO: Open terms and conditions
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Consultez nos CGU sur notre site web')),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.privacy_tip,
                title: 'Politique de confidentialité',
                onTap: () {
                  // TODO: Open privacy policy
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Consultez notre politique sur notre site web')),
                  );
                },
              ),
              _buildListTile(
                icon: Icons.info,
                title: 'À propos',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutUsScreen()),
                  );
                },
              ),
            ],
          ),
          _buildSection(
            title: 'ACTIONS DU COMPTE',
            children: [
              _buildListTile(
                icon: Icons.logout,
                title: 'Se déconnecter',
                titleColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _showLogoutDialog(),
              ),
              _buildListTile(
                icon: Icons.delete_forever,
                title: 'Supprimer mon compte',
                titleColor: Colors.red,
                iconColor: Colors.red,
                onTap: () => _showDeleteAccountDialog(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  'Version 1.0.0',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '© 2025 Bolide',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey[300]!),
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          color: titleColor,
          fontSize: 15,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      value: value,
      onChanged: onChanged,
      activeTrackColor: Colors.black,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la langue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['Français', 'English', 'العربية']
              .map((lang) => RadioListTile<String>(
                    title: Text(lang),
                    value: lang,
                    groupValue: _language,
                    onChanged: (value) {
                      setState(() => _language = value!);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showCurrencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choisir la devise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['FCFA', 'EUR', 'USD']
              .map((curr) => RadioListTile<String>(
                    title: Text(curr),
                    value: curr,
                    groupValue: _currency,
                    onChanged: (value) {
                      setState(() => _currency = value!);
                      Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showLogoutDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Se déconnecter'),
        content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Déconnecter'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await SupabaseService().signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showDeleteAccountDialog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le compte'),
        content: const Text(
          'Cette action est irréversible. Toutes vos données seront définitivement supprimées. Tapez "SUPPRIMER" pour confirmer.',
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // TODO: Implement account deletion through Supabase service
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fonctionnalité de suppression de compte à implémenter'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }
}
