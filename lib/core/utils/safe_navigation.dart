import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Utility class for safe navigation that prevents disposed view errors
class SafeNavigation {
  /// Safely navigate after ensuring the widget is still mounted and
  /// allowing any pending callbacks to complete
  static Future<void> navigateAfterDelay(
    BuildContext context,
    Widget Function() builder, {
    Duration delay = const Duration(milliseconds: 100),
    bool replace = false,
    bool removeUntil = false,
  }) async {
    // Wait a bit to ensure any pending callbacks complete
    await Future.delayed(delay);
    
    // Use post-frame callback to ensure we're in a safe state
    if (!context.mounted) return;
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      
      final route = MaterialPageRoute(builder: (_) => builder());
      
      if (replace) {
        Navigator.of(context).pushReplacement(route);
      } else if (removeUntil) {
        Navigator.of(context).pushAndRemoveUntil(
          route,
          (route) => false,
        );
      } else {
        Navigator.of(context).push(route);
      }
    });
  }

  /// Safely show a snackbar after ensuring the widget is mounted
  static void showSnackBar(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          duration: duration,
        ),
      );
    });
  }

  /// Safely execute a callback after ensuring the widget is mounted
  static void executeSafely(
    BuildContext context,
    VoidCallback callback, {
    Duration delay = const Duration(milliseconds: 50),
  }) {
    Future.delayed(delay, () {
      if (!context.mounted) return;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        callback();
      });
    });
  }
}

