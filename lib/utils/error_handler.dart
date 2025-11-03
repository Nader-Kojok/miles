import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Global error handler following Flutter 2025 best practices
class GlobalErrorHandler {
  static final GlobalErrorHandler _instance = GlobalErrorHandler._internal();
  factory GlobalErrorHandler() => _instance;
  GlobalErrorHandler._internal();

  /// Initialize global error handling
  static void initialize() {
    // Catch Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError(details.exception, details.stack, 'Flutter Error');
      
      // In release mode, send to crash reporting service
      if (kReleaseMode) {
        // TODO: Send to Firebase Crashlytics or similar
        _sendToCrashReporting(details.exception, details.stack);
      }
    };

    // Catch errors outside of Flutter
    PlatformDispatcher.instance.onError = (error, stack) {
      _logError(error, stack, 'Platform Error');
      
      if (kReleaseMode) {
        _sendToCrashReporting(error, stack);
      }
      
      return true; // Prevents default behavior
    };

    // Catch async errors
    runZonedGuarded<Future<void>>(
      () async {
        // Application initialization happens in main
      },
      (error, stack) {
        _logError(error, stack, 'Async Error');
        if (kReleaseMode) {
          _sendToCrashReporting(error, stack);
        }
      },
    );
  }

  /// Log error to console with context
  static void _logError(Object error, StackTrace? stack, String context) {
    developer.log(
      'Error caught in $context',
      error: error,
      stackTrace: stack,
      name: 'ErrorHandler',
      level: 1000, // High severity
    );
  }

  /// Send error to crash reporting service
  static void _sendToCrashReporting(Object error, StackTrace? stack) {
    // TODO: Integrate with Firebase Crashlytics
    // FirebaseCrashlytics.instance.recordError(error, stack);
    developer.log(
      'Would send to crash reporting: $error',
      name: 'ErrorHandler',
    );
  }

  /// Handle network errors with user-friendly messages
  static String getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException') ||
        error.toString().contains('ClientException')) {
      return 'Problème de connexion internet. Veuillez vérifier votre connexion.';
    }
    
    if (error.toString().contains('TimeoutException')) {
      return 'La requête a expiré. Veuillez réessayer.';
    }
    
    if (error.toString().contains('FormatException')) {
      return 'Données invalides reçues du serveur.';
    }
    
    if (error.toString().contains('401') || error.toString().contains('Unauthorized')) {
      return 'Session expirée. Veuillez vous reconnecter.';
    }
    
    if (error.toString().contains('403') || error.toString().contains('Forbidden')) {
      return 'Accès non autorisé.';
    }
    
    if (error.toString().contains('404') || error.toString().contains('Not Found')) {
      return 'Ressource introuvable.';
    }
    
    if (error.toString().contains('500') || error.toString().contains('Server Error')) {
      return 'Erreur serveur. Veuillez réessayer plus tard.';
    }
    
    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  /// Show error snackbar to user
  static void showErrorSnackBar(BuildContext context, dynamic error) {
    if (!context.mounted) return;
    
    final message = getErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Retry function with exponential backoff
  static Future<T> retryOperation<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffMultiplier = 2.0,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        attempt++;
        return await operation();
      } catch (error) {
        if (attempt >= maxAttempts) {
          rethrow;
        }

        developer.log(
          'Retry attempt $attempt failed, retrying in ${delay.inSeconds}s...',
          name: 'ErrorHandler',
        );

        await Future.delayed(delay);
        delay *= backoffMultiplier;
      }
    }
  }
}

/// Custom error widget to show when widget build fails
class CustomErrorWidget extends StatelessWidget {
  final FlutterErrorDetails errorDetails;

  const CustomErrorWidget({
    super.key,
    required this.errorDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red[700],
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              kReleaseMode
                  ? 'Une erreur est survenue'
                  : 'Error: ${errorDetails.exception}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 16),
              Text(
                errorDetails.stack.toString(),
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 10,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
