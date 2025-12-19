import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_spacing.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main/main_screen.dart';
import 'services/api_service.dart';
import 'services/google_sign_in_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Handle Flutter errors gracefully (especially for web)
  FlutterError.onError = (FlutterErrorDetails details) {
    // Suppress "disposed EngineFlutterView" errors in web
    if (details.exception is AssertionError) {
      final errorString = details.exception.toString();
      if (errorString.contains('isDisposed') || 
          errorString.contains('EngineFlutterView') ||
          errorString.contains('Trying to render a disposed')) {
        // Silently ignore disposed view errors - they're harmless in web
        return;
      }
    }
    // Log other errors normally
    FlutterError.presentError(details);
  };
  
  // Handle platform errors (like disposed view errors)
  PlatformDispatcher.instance.onError = (error, stack) {
    final errorString = error.toString();
    // Suppress disposed view errors
    if (errorString.contains('isDisposed') || 
        errorString.contains('EngineFlutterView') ||
        errorString.contains('Trying to render a disposed')) {
      return true; // Error handled, don't crash
    }
    // Let other errors propagate
    return false;
  };
  
  // Initialize API service and load saved token
  final apiService = ApiService();
  await apiService.init();
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  Future<void> _checkAuthentication() async {
    try {
      final apiService = ApiService();
      final googleSignInService = GoogleSignInService();
      
      // Check if we have a saved token
      final hasToken = apiService.token != null && apiService.token!.isNotEmpty;
      
      // Check Google Sign-In state (suppress errors)
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignInService.getCurrentUser();
      } catch (e) {
        // Ignore Google Sign-In errors during auth check
        debugPrint('Google Sign-In check error (ignored): $e');
      }
      final hasGoogleUser = googleUser != null;
      
      // If we have either token or Google user, consider authenticated
      if (!mounted) return;
      
      if (hasToken || hasGoogleUser) {
        setState(() {
          _isAuthenticated = true;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isAuthenticated = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isAuthenticated = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: AppColors.background,
          body: Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'SaveFood - Save Food, Save Planet',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.background,
        textTheme: TextTheme(
          displayLarge: AppTextStyles.heading1,
          displayMedium: AppTextStyles.heading2,
          displaySmall: AppTextStyles.heading3,
          titleLarge: AppTextStyles.subheading1,
          titleMedium: AppTextStyles.subheading2,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.buttonLarge,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: AppTextStyles.heading2,
        ),
        cardTheme: CardThemeData(
          color: AppColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
          ),
        ),
      ),
      home: _isAuthenticated ? const MainScreen() : const LoginScreen(),
    );
  }
}
