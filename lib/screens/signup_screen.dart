import 'package:flutter/material.dart';
import 'auth_method_choice_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Affiche l'écran de choix de méthode d'authentification
    return const AuthMethodChoiceScreen(isSignup: true);
  }
}
