import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../screens/profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/about_us_screen.dart';
import '../screens/welcome_screen.dart';
import '../services/supabase_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _handleAuthRequired(BuildContext context, Widget destination, String featureName) {
    final supabaseService = SupabaseService();
    
    if (!supabaseService.isAuthenticated) {
      // Show dialog prompting to login
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Connexion requise'),
          content: Text('Veuillez vous connecter pour accéder à $featureName.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close drawer
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              child: const Text('Se connecter'),
            ),
          ],
        ),
      );
    } else {
      Navigator.pop(context); // Close drawer
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          // Header spacing (Menu text removed)
          const SizedBox(height: 60),

          // Miles Logo with text
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: SvgPicture.asset(
              'assets/logo_miles_white _text.svg',
              width: 80,
              height: 80,
            ),
          ),

          const SizedBox(height: 20),

          // Menu Items
          _DrawerMenuItem(
            icon: Icons.person_outline,
            title: 'Profil',
            onTap: () => _handleAuthRequired(
              context,
              const ProfileScreen(),
              'votre profil',
            ),
          ),

          _DrawerMenuItem(
            icon: Icons.settings_outlined,
            title: 'Paramètres',
            onTap: () => _handleAuthRequired(
              context,
              const SettingsScreen(),
              'les paramètres',
            ),
          ),

          const Spacer(),

          // Social Media Icons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _SocialIcon(
                  icon: Icons.camera_alt,
                  onTap: () {
                    // Instagram link
                  },
                ),
                _SocialIcon(
                  icon: Icons.facebook,
                  onTap: () {
                    // Facebook link
                  },
                ),
                _SocialIcon(
                  icon: Icons.close, // Twitter X
                  onTap: () {
                    // Twitter link
                  },
                ),
                _SocialIcon(
                  icon: Icons.business_center, // LinkedIn
                  onTap: () {
                    // LinkedIn link
                  },
                ),
              ],
            ),
          ),

          // Footer Link
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AboutUsScreen(),
                  ),
                );
              },
              child: const Text(
                'À Propos Du Développeur',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white,
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white54, width: 1),
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
