import 'package:flutter_test/flutter_test.dart';
import 'package:bolide/utils/error_handler.dart';

/// Unit tests for GlobalErrorHandler
/// Following Flutter 2025 testing best practices
void main() {
  group('GlobalErrorHandler', () {
    group('getErrorMessage', () {
      test('returns connection error message for SocketException', () {
        final error = Exception('SocketException: Connection failed');
        final message = GlobalErrorHandler.getErrorMessage(error);
        
        expect(
          message,
          'Problème de connexion internet. Veuillez vérifier votre connexion.',
        );
      });

      test('returns timeout message for TimeoutException', () {
        final error = Exception('TimeoutException: Request timed out');
        final message = GlobalErrorHandler.getErrorMessage(error);
        
        expect(message, 'La requête a expiré. Veuillez réessayer.');
      });

      test('returns unauthorized message for 401 error', () {
        final error = Exception('401 Unauthorized');
        final message = GlobalErrorHandler.getErrorMessage(error);
        
        expect(message, 'Session expirée. Veuillez vous reconnecter.');
      });

      test('returns forbidden message for 403 error', () {
        final error = Exception('403 Forbidden');
        final message = GlobalErrorHandler.getErrorMessage(error);
        
        expect(message, 'Accès non autorisé.');
      });

      test('returns not found message for 404 error', () {
        final error = Exception('404 Not Found');
        final message = GlobalErrorHandler.getErrorMessage(error);
        
        expect(message, 'Ressource introuvable.');
      });

      test('returns server error message for 500 error', () {
        final error = Exception('500 Server Error');
        final message = GlobalErrorHandler.getErrorMessage(error);
        
        expect(message, 'Erreur serveur. Veuillez réessayer plus tard.');
      });

      test('returns generic error message for unknown error', () {
        final error = Exception('Unknown error occurred');
        final message = GlobalErrorHandler.getErrorMessage(error);
        
        expect(message, 'Une erreur est survenue. Veuillez réessayer.');
      });
    });

    group('retryOperation', () {
      test('succeeds on first attempt', () async {
        int attempts = 0;
        
        final result = await GlobalErrorHandler.retryOperation<String>(
          operation: () async {
            attempts++;
            return 'Success';
          },
          maxAttempts: 3,
        );

        expect(result, 'Success');
        expect(attempts, 1);
      });

      test('retries and succeeds on third attempt', () async {
        int attempts = 0;
        
        final result = await GlobalErrorHandler.retryOperation<String>(
          operation: () async {
            attempts++;
            if (attempts < 3) {
              throw Exception('Temporary failure');
            }
            return 'Success after retries';
          },
          maxAttempts: 3,
        );

        expect(result, 'Success after retries');
        expect(attempts, 3);
      });

      test('throws error after max attempts exceeded', () async {
        int attempts = 0;
        
        expect(
          () async => await GlobalErrorHandler.retryOperation<String>(
            operation: () async {
              attempts++;
              throw Exception('Persistent failure');
            },
            maxAttempts: 3,
          ),
          throwsException,
        );

        expect(attempts, 3);
      });

      test('respects initial delay', () async {
        final stopwatch = Stopwatch()..start();
        int attempts = 0;
        
        try {
          await GlobalErrorHandler.retryOperation<String>(
            operation: () async {
              attempts++;
              throw Exception('Error');
            },
            maxAttempts: 2,
            initialDelay: const Duration(milliseconds: 100),
          );
        } catch (e) {
          // Expected to fail
        }

        stopwatch.stop();
        expect(attempts, 2);
        // Should have waited at least 100ms before second attempt
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(100));
      });
    });
  });
}
