import 'package:flutter/material.dart';
import '../../widgets/bottom_navigation_bar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../home/home_screen.dart';
import '../order_history/order_history_screen.dart';
import '../profile/enhanced_profile_screen.dart';
import '../auth/login_screen.dart';
import '../../widgets/clean_button.dart';
import '../../../services/google_sign_in_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const HomeScreen(),
          const OrderHistoryScreen(),
          const _LoyaltyScreen(), // Placeholder
          const _AccountScreen(), // Will show profile
        ],
      ),
      bottomNavigationBar: CleanBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

class _LoyaltyScreen extends StatelessWidget {
  const _LoyaltyScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loyalty'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: const Center(
        child: Text('Loyalty program coming soon'),
      ),
    );
  }
}

class _AccountScreen extends StatefulWidget {
  const _AccountScreen();

  @override
  State<_AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<_AccountScreen> {
  @override
  Widget build(BuildContext context) {
    final user = GoogleSignInService().currentUser;
    if (user != null) {
      return EnhancedProfileScreen(user: user);
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                'Please login',
                style: AppTextStyles.heading3.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You need to be logged in to view your profile',
                style: AppTextStyles.bodyMediumWithColor(
                  AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              CleanButton(
                label: 'Go to Login',
                icon: Icons.login,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

