import 'dart:async';
import 'package:flutter/foundation.dart';

/// A debouncer utility that delays function execution until after a specified duration
/// has elapsed since the last time it was invoked.
/// 
/// This is particularly useful for search inputs to avoid making too many API calls
/// while the user is still typing.
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  /// Calls [action] after the debounce delay.
  /// If called again before the delay expires, the previous call is cancelled.
  void call(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(delay, action);
  }

  /// Cancels any pending debounced actions
  void cancel() {
    _timer?.cancel();
  }

  /// Disposes the debouncer and cancels any pending actions
  void dispose() {
    _timer?.cancel();
  }
}
