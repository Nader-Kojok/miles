import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service to monitor network connectivity following 2025 best practices
class ConnectivityService extends ChangeNotifier {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  ConnectivityService() {
    _initialize();
  }

  /// Initialize connectivity monitoring
  Future<void> _initialize() async {
    try {
      // Check initial connectivity
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      
      // Listen to connectivity changes
      _subscription = _connectivity.onConnectivityChanged.listen(
        _updateConnectionStatus,
        onError: (error) {
          debugPrint('Connectivity error: $error');
        },
      );
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize connectivity service: $e');
    }
  }

  /// Update connection status based on connectivity result
  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    
    // Check if any connection type is available
    _isOnline = results.any((result) => 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet
    );
    
    // Only notify if status changed
    if (wasOnline != _isOnline) {
      debugPrint('Connectivity changed: ${_isOnline ? "Online" : "Offline"}');
      notifyListeners();
    }
  }

  /// Check if device is currently online
  Future<bool> checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateConnectionStatus(result);
      return _isOnline;
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
