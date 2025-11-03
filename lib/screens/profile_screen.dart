import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../services/supabase_service.dart';
import '../services/profile_service.dart';
import '../models/profile.dart';
import '../utils/app_colors.dart';
import 'welcome_screen.dart';
import 'edit_profile_screen.dart';
import 'addresses_screen.dart';
import 'settings_screen.dart';
import 'faq_screen.dart';
import 'about_us_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  final _supabaseService = SupabaseService();
  Profile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadProfile();
  }

  Future<void> _checkAuthAndLoadProfile() async {
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
      return;
    }
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileService.getUserProfile();
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getInitial(String? fullName, String? email, String? phone) {
    // Try to get initial from full name
    if (fullName != null && fullName.isNotEmpty) {
      return fullName.substring(0, 1).toUpperCase();
    }
    
    // Try to get initial from email
    if (email != null && email.isNotEmpty) {
      return email.substring(0, 1).toUpperCase();
    }
    
    // Try to get initial from phone
    if (phone != null && phone.isNotEmpty) {
      return phone.substring(0, 1);
    }
    
    // Default to 'U'
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    final supabaseService = SupabaseService();
    final user = supabaseService.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.person, color: AppColors.textPrimary, size: 22),
            SizedBox(width: 8),
            Text(
              'Profil',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Avatar et informations utilisateur
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _isLoading
                        ? const CircularProgressIndicator()
                        : _profile?.avatarUrl != null
                            ? CircleAvatar(
                                radius: 50,
                                backgroundImage: CachedNetworkImageProvider(
                                  _profile!.avatarUrl!,
                                ),
                              )
                            : CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColors.primary,
                                child: Text(
                                  _getInitial(_profile?.fullName, user?.email, user?.phone),
                                  style: const TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                    const SizedBox(height: 16),
                    Text(
                      _profile?.fullName ?? user?.userMetadata?['full_name']?.toString() ?? 'Utilisateur',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _profile?.phone ?? user?.email ?? user?.phone ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // MES INFORMATIONS - Personal user data
            _buildSectionTitle('MES INFORMATIONS'),
            _MenuItem(
              icon: Icons.person_outline,
              title: 'Modifier mon profil',
              subtitle: 'Nom, téléphone, email, photo',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(),
                  ),
                );
                // Reload profile if updated
                if (result == true) {
                  _loadProfile();
                }
              },
            ),
            _MenuItem(
              icon: Icons.location_on_outlined,
              title: 'Mes adresses',
              subtitle: 'Gérer les adresses de livraison',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddressesScreen(),
                  ),
                );
              },
            ),
            _MenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'Mes commandes',
              subtitle: 'Historique et suivi',
              onTap: () {
                // TODO: Navigate to orders screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonctionnalité à venir')),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // CONFIGURATIONS - App settings
            _buildSectionTitle('PARAMÈTRES DE L\'APPLICATION'),
            _MenuItem(
              icon: Icons.settings_outlined,
              title: 'Paramètres',
              subtitle: 'Notifications, langue, thème',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            _MenuItem(
              icon: Icons.help_outline,
              title: 'Aide et support',
              subtitle: 'FAQ, nous contacter',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FAQScreen(),
                  ),
                );
              },
            ),
            _MenuItem(
              icon: Icons.info_outline,
              title: 'À propos',
              subtitle: 'Version, mentions légales',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Bouton de déconnexion
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Déconnexion'),
                      content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Déconnexion'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await supabaseService.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomeScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.textSecondary),
                label: const Text(
                  'Déconnexion',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.textPrimary),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
