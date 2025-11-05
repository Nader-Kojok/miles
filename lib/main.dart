import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'services/supabase_service.dart';
import 'services/cart_service.dart';
import 'services/push_notification_service.dart';
import 'services/connectivity_service.dart';
import 'services/analytics_service.dart';
import 'providers/profile_provider.dart';
import 'providers/favorite_provider.dart';
import 'providers/vehicle_provider.dart';
import 'utils/app_colors.dart';
import 'utils/error_handler.dart';

void main() async {
  // Run app with zone error handling
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      
      // Initialize global error handling (2025 best practice)
      GlobalErrorHandler.initialize();
      
      // Set custom error widget
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return CustomErrorWidget(errorDetails: details);
      };
      
      // Initialize Supabase
      await Supabase.initialize(
        url: 'https://uerwlrpatvumjdksfgbj.supabase.co',
        anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVlcndscnBhdHZ1bWpka3NmZ2JqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4MzczNTEsImV4cCI6MjA3NzQxMzM1MX0.Q_TykGHuIEMyhOvf2OfmDh7PQbk54cZehNJKnc4CWYg',
      );
      
      // Initialize Analytics (2025 best practice - using Supabase)
      Analytics.initialize(enableSupabaseTracking: true);
      
      // Initialize Push Notifications (OneSignal)
      await PushNotificationService().initialize('924c65ff-2ef3-4dfb-ab0c-a101adda03f8');
      
      runApp(const MyApp());
    },
    (error, stack) {
      // Catch any errors during app initialization
      debugPrint('App initialization error: $error');
      debugPrint('Stack trace: $stack');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Services
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => ConnectivityService()),
        
        // State Management Providers (2025 best practice)
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
      ],
      child: MaterialApp(
        title: 'Miles - Pièces détachées',
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
