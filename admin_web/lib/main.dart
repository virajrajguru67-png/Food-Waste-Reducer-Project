import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/admin_colors.dart';
import 'features/auth/admin_login_screen.dart';
import 'services/admin_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service
  final apiService = AdminApiService();
  
  runApp(
    ProviderScope(
      child: MyApp(apiService: apiService),
    ),
  );
}

class MyApp extends StatelessWidget {
  final AdminApiService apiService;

  const MyApp({super.key, required this.apiService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SaveFood - Admin Panel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AdminColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AdminColors.background,
        textTheme: GoogleFonts.interTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: AdminColors.surface,
          elevation: 0,
          centerTitle: false,
        ),
        cardTheme: CardThemeData(
          color: AdminColors.cardBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: AdminLoginScreen(apiService: apiService),
    );
  }
}
