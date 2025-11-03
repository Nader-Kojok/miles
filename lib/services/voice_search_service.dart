import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceSearchService {
  static final VoiceSearchService _instance = VoiceSearchService._internal();
  late stt.SpeechToText _speechToText;
  bool _initialized = false;
  String _currentLocale = 'fr-FR'; // Default to French

  factory VoiceSearchService() {
    return _instance;
  }

  VoiceSearchService._internal() {
    _speechToText = stt.SpeechToText();
  }

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // Speech recognition is not supported on web
      if (kIsWeb) {
        print('VoiceSearchService: Speech recognition not available on web');
        _initialized = false;
        return false;
      }

      final available = await _speechToText.initialize(
        onError: (error) => print('Speech recognition error: $error'),
        onStatus: (status) => print('Speech recognition status: $status'),
      );

      _initialized = available;
      return available;
    } catch (e) {
      print('Error initializing speech recognition: $e');
      return false;
    }
  }

  /// Get available locales
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    try {
      return await _speechToText.locales();
    } catch (e) {
      print('Error getting available locales: $e');
      return [];
    }
  }

  /// Set the locale for speech recognition
  void setLocale(String localeId) {
    _currentLocale = localeId;
  }

  /// Get current locale
  String get currentLocale => _currentLocale;

  /// Check if speech recognition is available
  bool get isAvailable => _initialized && _speechToText.isAvailable;

  /// Check if currently listening
  bool get isListening => _speechToText.isListening;

  /// Start listening for speech (with callback)
  Future<void> startListening({
    required Function(String) onResult,
    Function(String)? onPartialResult,
    String? localeId,
    Duration pauseDuration = const Duration(seconds: 3),
  }) async {
    if (!_initialized) {
      final initialized = await initialize();
      if (!initialized) {
        throw Exception('Speech recognition not available');
      }
    }

    if (_speechToText.isListening) {
      await _speechToText.stop();
    }

    try {
      await _speechToText.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
          } else if (onPartialResult != null) {
            onPartialResult(result.recognizedWords);
          }
        },
        localeId: localeId ?? _currentLocale,
        listenMode: stt.ListenMode.search,
        pauseFor: pauseDuration,
        partialResults: onPartialResult != null,
        onSoundLevelChange: null,
        cancelOnError: true,
        listenFor: const Duration(seconds: 30),
      );
    } catch (e) {
      print('Error starting speech recognition: $e');
      rethrow;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
    } catch (e) {
      print('Error stopping speech recognition: $e');
    }
  }

  /// Cancel listening
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
    } catch (e) {
      print('Error canceling speech recognition: $e');
    }
  }

  /// Get last recognized words
  String get lastRecognizedWords => _speechToText.lastRecognizedWords;

  /// Check if a specific locale is available
  Future<bool> isLocaleAvailable(String localeId) async {
    final locales = await getAvailableLocales();
    return locales.any((locale) => locale.localeId == localeId);
  }

  /// Get French locales
  Future<List<stt.LocaleName>> getFrenchLocales() async {
    final locales = await getAvailableLocales();
    return locales.where((locale) =>
      locale.localeId.startsWith('fr')).toList();
  }

  /// Dispose of resources
  void dispose() {
    _speechToText.stop();
  }
}
