import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInService {
  static final GoogleSignInService _instance = GoogleSignInService._internal();
  factory GoogleSignInService() => _instance;
  GoogleSignInService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    // Web: Use client ID from meta tag in web/index.html
    // For web, the redirect URI must be added in Google Cloud Console
    // Common redirect URIs for Flutter web:
    // - http://localhost:3000/
    // - http://localhost:8080/
    // - http://localhost:5000/
    // - http://localhost:*/ (for any port)
    clientId: kIsWeb 
        ? '509177086998-ebrtvg0um5fd26k79nd91to7430r7tni.apps.googleusercontent.com'
        : null,
    // Android: Automatically uses SHA-1 fingerprint to match OAuth client
    // iOS: Configured via Info.plist (reversed client ID)
  );

  GoogleSignInAccount? _currentUser;
  bool _isSigningIn = false;
  final List<Completer<GoogleSignInAccount?>> _pendingSignInCompleters = [];

  GoogleSignInAccount? get currentUser => _currentUser;

  bool get isSignedIn => _currentUser != null;
  bool get isSigningIn => _isSigningIn;

  /// Sign in with Google with proper lifecycle handling
  /// This method ensures only one sign-in process runs at a time
  /// and properly handles callbacks that may fire after widget disposal
  Future<GoogleSignInAccount?> signIn() async {
    // If already signing in, wait for the existing process
    if (_isSigningIn) {
      final completer = Completer<GoogleSignInAccount?>();
      _pendingSignInCompleters.add(completer);
      return completer.future;
    }

    _isSigningIn = true;

    try {
      // Add a small delay to ensure any previous operations complete
      await Future.delayed(const Duration(milliseconds: 50));

      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      
      // Add another delay to allow any callbacks to complete
      await Future.delayed(const Duration(milliseconds: 100));
      
      _currentUser = account;
      
      // Complete any pending sign-in requests
      for (var completer in _pendingSignInCompleters) {
        if (!completer.isCompleted) {
          completer.complete(account);
        }
      }
      _pendingSignInCompleters.clear();
      
      return account;
    } catch (error) {
      final errorString = error.toString();
      
      // Suppress known harmless errors in web
      if (kIsWeb && (
        errorString.contains('unknown_reason') ||
        errorString.contains('NetworkError') ||
        errorString.contains('window.closed') ||
        errorString.contains('Cross-Origin-Opener-Policy')
      )) {
        debugPrint('Google Sign-In web error (suppressed): $errorString');
        // Complete pending requests with null
        for (var completer in _pendingSignInCompleters) {
          if (!completer.isCompleted) {
            completer.complete(null);
          }
        }
        _pendingSignInCompleters.clear();
        return null;
      }
      
      debugPrint('Error signing in: $error');
      // Log more details for debugging
      if (kIsWeb) {
        debugPrint('Web Google Sign-In Error Details:');
        debugPrint('Client ID: ${_googleSignIn.clientId ?? "Not set"}');
        debugPrint('Error type: ${error.runtimeType}');
        debugPrint('Error message: $error');
      }
      
      // Complete pending requests with error
      for (var completer in _pendingSignInCompleters) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      }
      _pendingSignInCompleters.clear();
      
      rethrow;
    } finally {
      _isSigningIn = false;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
    } catch (error) {
      debugPrint('Error signing out: $error');
      rethrow;
    }
  }

  /// Get the current signed-in user with proper error handling
  Future<GoogleSignInAccount?> getCurrentUser() async {
    try {
      // Add a small delay to prevent race conditions
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Suppress errors from silent sign-in (common in web when not configured)
      _currentUser = await _googleSignIn.signInSilently();
      return _currentUser;
    } catch (error) {
      // Silently ignore sign-in errors - they're expected when user isn't signed in
      // Only log if it's not a common "not signed in" error
      final errorString = error.toString();
      if (!errorString.contains('sign_in_required') && 
          !errorString.contains('unknown_reason') &&
          !errorString.contains('NetworkError') &&
          !errorString.contains('window.closed') &&
          !errorString.contains('Cross-Origin-Opener-Policy')) {
        debugPrint('Error getting current user: $error');
      }
      return null;
    }
  }

  /// Disconnect from Google account
  Future<void> disconnect() async {
    try {
      await _googleSignIn.disconnect();
      _currentUser = null;
    } catch (error) {
      debugPrint('Error disconnecting: $error');
      rethrow;
    }
  }
}

