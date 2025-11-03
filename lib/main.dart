import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/supabase_service.dart';
import 'services/cart_service.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialiser Supabase
  await Supabase.initialize(
    url: 'https://uerwlrpatvumjdksfgbj.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVlcndscnBhdHZ1bWpka3NmZ2JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MzczNTEsImV4cCI6MjA3NzQxMzM1MX0.Q_TykGHuIEMyhOvf2OfmDh7PQbk54cZehNJKnc4CWYg',
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: MaterialApp(
        title: 'Bolide - Pièces détachées',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.accent,
            error: AppColors.error,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
          ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppColors.primary,
            contentTextStyle: const TextStyle(color: Colors.white),
            behavior: SnackBarBehavior.floating,
          ),
          fontFamily: 'SF Pro Text',
        ),
        routes: {
          '/home': (context) => const HomeScreen(),
        },
        home: const SplashScreen(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseService = SupabaseService();
    
    return StreamBuilder<AuthState>(
      stream: supabaseService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.grey[100],
            body: const Center(
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            ),
          );
        }
        
        final session = snapshot.data?.session;
        
        if (session != null) {
          return const HomeScreen();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
