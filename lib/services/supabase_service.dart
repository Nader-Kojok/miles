import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient _client = Supabase.instance.client;
  
  SupabaseClient get client => _client;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Authentification par numéro de téléphone
  Future<void> signInWithPhone(String phoneNumber) async {
    try {
      // Ensure phone number is in E.164 format (e.g., +221771234567)
      final formattedPhone = phoneNumber.startsWith('+') 
          ? phoneNumber 
          : '+$phoneNumber';
      
      // Remove any spaces or special characters except +
      final cleanPhone = formattedPhone.replaceAll(RegExp(r'[^\d+]'), '');
      
      print('📱 Sending OTP to: $cleanPhone'); // Debug log
      
      await _client.auth.signInWithOtp(
        phone: cleanPhone,
      );
      
      print('✅ OTP sent successfully'); // Debug log
    } on AuthException catch (e) {
      print('❌ Auth error: ${e.message} (${e.statusCode})'); // Debug log
      // Handle specific Supabase auth errors
      if (e.statusCode == '422') {
        // Check for Twilio configuration errors
        if (e.message.contains('Invalid From Number') || e.message.contains('21212')) {
          throw Exception(
            'Configuration Twilio incorrecte. '
            'Veuillez vérifier que:\n'
            '1. Un numéro de téléphone valide est configuré dans Supabase Dashboard\n'
            '2. Ou que votre Messaging Service Twilio contient un numéro dans le Sender Pool'
          );
        }
        throw Exception('Vérifiez que l\'authentification par téléphone est activée dans Supabase Dashboard');
      }
      throw Exception('Erreur d\'authentification: ${e.message}');
    } catch (e) {
      print('❌ Error: $e'); // Debug log
      throw Exception('Erreur lors de l\'envoi du code: $e');
    }
  }

  // Vérification du code OTP
  Future<AuthResponse> verifyOTP({
    required String phone,
    required String token,
  }) async {
    try {
      // Ensure phone number is in E.164 format
      final formattedPhone = phone.startsWith('+') 
          ? phone 
          : '+$phone';
      
      return await _client.auth.verifyOTP(
        phone: formattedPhone,
        token: token,
        type: OtpType.sms,
      );
    } on AuthException catch (e) {
      throw Exception('Code invalide: ${e.message}');
    } catch (e) {
      throw Exception('Erreur de vérification: $e');
    }
  }

  // Authentification par email - Inscription
  Future<void> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user != null && response.user!.emailConfirmedAt == null) {
        throw Exception('Veuillez vérifier votre email pour confirmer votre compte');
      }
    } on AuthException catch (e) {
      if (e.message.contains('already registered')) {
        throw Exception('Cet email est déjà utilisé');
      }
      throw Exception('Erreur d\'inscription: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de l\'inscription: $e');
    }
  }

  // Authentification par email - Connexion
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      if (e.message.contains('Invalid login credentials')) {
        throw Exception('Email ou mot de passe incorrect');
      }
      throw Exception('Erreur de connexion: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la connexion: $e');
    }
  }

  // Envoi d'un lien magic link par email
  Future<void> signInWithEmailOTP(String email) async {
    try {
      await _client.auth.signInWithOtp(
        email: email,
        emailRedirectTo: null, // Can be configured for deep linking
      );
    } on AuthException catch (e) {
      throw Exception('Erreur lors de l\'envoi du lien: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du lien: $e');
    }
  }

  // Vérification du code OTP email
  Future<AuthResponse> verifyEmailOTP({
    required String email,
    required String token,
  }) async {
    try {
      return await _client.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.email,
      );
    } on AuthException catch (e) {
      throw Exception('Code invalide: ${e.message}');
    } catch (e) {
      throw Exception('Erreur de vérification: $e');
    }
  }

  // Réinitialisation du mot de passe
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('Erreur lors de la réinitialisation: ${e.message}');
    } catch (e) {
      throw Exception('Erreur lors de la réinitialisation: $e');
    }
  }

  // Authentification avec Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        serverClientId: 'YOUR_WEB_CLIENT_ID', // À remplacer par votre Client ID
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Connexion Google annulée');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Tokens Google manquants');
      }

      return await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      throw Exception('Erreur lors de la connexion Google: $e');
    }
  }

  // Déconnexion
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw Exception('Erreur lors de la déconnexion: $e');
    }
  }

  // Écouter les changements d'état d'authentification
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
}
