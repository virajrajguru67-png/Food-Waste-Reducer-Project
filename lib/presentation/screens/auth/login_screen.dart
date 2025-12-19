import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/safe_navigation.dart';
import '../../../services/google_sign_in_service.dart';
import '../../../services/api_service.dart';
import '../../widgets/animated_button.dart';
import '../../widgets/clean_button.dart';
import '../main/main_screen.dart';
import 'register_screen.dart';
import 'complete_profile_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  final ApiService _apiService = ApiService();

  static const String defaultEmail = 'demo@foodwastereducer.com';
  static const String defaultPassword = 'demo123';

  @override
  void initState() {
    super.initState();
    _emailController.text = defaultEmail;
    _passwordController.text = defaultPassword;
    _checkAndClearGoogleSignIn();
  }

  Future<void> _checkAndClearGoogleSignIn() async {
    // Clear any partial Google sign-in state that might cause errors
    try {
      final currentUser = _googleSignInService.currentUser;
      if (currentUser != null) {
        // User is partially signed in, clear it
        await _googleSignInService.signOut();
      }
    } catch (e) {
      // Ignore errors during cleanup
      debugPrint('Error clearing Google sign-in: $e');
    }
  }

  Future<void> _handleLogout() async {
    try {
      // Sign out from Google
      await _googleSignInService.signOut();
      // Clear API token
      _apiService.setToken(null);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${error.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await _apiService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (result['success'] == true && mounted) {
        await SafeNavigation.navigateAfterDelay(
          context,
          () => const MainScreen(),
          replace: true,
          delay: const Duration(milliseconds: 100),
        );
      } else if (mounted) {
        SafeNavigation.showSnackBar(
          context,
          result['message'] ?? 'Invalid email or password',
          backgroundColor: AppColors.error,
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login failed: ${error.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (!mounted) return;
    setState(() => _isGoogleLoading = true);

    try {
      // Add a small delay to ensure widget is ready
      await Future.delayed(const Duration(milliseconds: 50));
      if (!mounted) return;

      final account = await _googleSignInService.signIn();
      
      // Check mounted after async operation
      if (!mounted) return;
      
      if (account == null) {
        SafeNavigation.showSnackBar(
          context,
          'Google Sign-In cancelled',
          backgroundColor: AppColors.warning,
        );
        if (mounted) setState(() => _isGoogleLoading = false);
        return;
      }

      if (account.id.isEmpty || account.email.isEmpty) {
        throw Exception('Invalid Google account data');
      }

      // Add delay before API call to allow any callbacks to complete
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;

      final result = await _apiService.googleSignIn(
        googleId: account.id,
        email: account.email,
        name: account.displayName?.isNotEmpty == true ? account.displayName : null,
        photoUrl: account.photoUrl,
      );

      // Check mounted after API call
      if (!mounted) return;

      if (result['success'] == true) {
        final user = result['user'] as Map<String, dynamic>?;
        final needsProfileCompletion = user?['phone'] == null ||
            (user?['phone'] as String?)?.isEmpty == true;

        if (needsProfileCompletion) {
          // Use safe navigation with delay
          await SafeNavigation.navigateAfterDelay(
            context,
            () => CompleteProfileScreen(
              email: account.email,
              name: account.displayName?.isNotEmpty == true
                  ? account.displayName!
                  : account.email.split('@')[0],
              googleId: account.id,
              photoUrl: account.photoUrl,
            ),
            replace: true,
            delay: const Duration(milliseconds: 150),
          );
        } else {
          // Use safe navigation with delay
          await SafeNavigation.navigateAfterDelay(
            context,
            () => const MainScreen(),
            replace: true,
            delay: const Duration(milliseconds: 150),
          );
        }
      } else {
        final errorMessage = result['message'] ??
            result['errorDetails'] ??
            'Google Sign-In failed';
        SafeNavigation.showSnackBar(
          context,
          errorMessage,
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        );
      }
    } catch (error) {
      if (!mounted) return;
      final errorString = error.toString();
      
      // Suppress known harmless web errors
      if (errorString.contains('unknown_reason') ||
          errorString.contains('NetworkError') ||
          errorString.contains('window.closed') ||
          errorString.contains('Cross-Origin-Opener-Policy')) {
        debugPrint('Google Sign-In web error (suppressed): $errorString');
        // Don't show error to user for these cases
      } else {
        SafeNavigation.showSnackBar(
          context,
          'Google Sign-In failed: ${error.toString()}',
          backgroundColor: AppColors.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Form(
              key: _formKey,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Compact Logo
                    Icon(
                      Icons.restaurant_menu_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Title
                    Text(
                      'Welcome Back',
                      style: AppTextStyles.heading1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Sign in to continue',
                      style: AppTextStyles.bodyMediumWithColor(
                        AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: AppTextStyles.bodySmallWithColor(
                          AppColors.textSecondary,
                        ),
                        prefixIcon: Icon(Icons.email_outlined, size: 20),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: AppTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: AppTextStyles.bodySmallWithColor(
                          AppColors.textSecondary,
                        ),
                        prefixIcon: Icon(Icons.lock_outlined, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot Password?',
                          style: AppTextStyles.bodySmallWithColor(AppColors.primary),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Sign In Button
                    AnimatedButton(
                      label: 'Sign In',
                      icon: Icons.login_rounded,
                      isLoading: _isLoading,
                      onPressed: _isLoading || _isGoogleLoading ? null : _handleLogin,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                          child: Text(
                            'OR',
                            style: AppTextStyles.captionWithColor(
                              AppColors.textTertiary,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Google Sign-In Button
                    AnimatedButton(
                      label: _isGoogleLoading ? 'Signing in...' : 'Continue with Google',
                      icon: _isGoogleLoading ? null : Icons.g_mobiledata,
                      isLoading: _isGoogleLoading,
                      isOutlined: true,
                      onPressed: _isLoading || _isGoogleLoading ? null : _handleGoogleSignIn,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Default Credentials Info
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Default Credentials',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Email: $defaultEmail',
                            style: AppTextStyles.captionWithColor(AppColors.textSecondary),
                          ),
                          Text(
                            'Password: $defaultPassword',
                            style: AppTextStyles.captionWithColor(AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.bodySmallWithColor(AppColors.textSecondary),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Sign Up',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    
                    // Logout Button (if user is partially signed in)
                    Builder(
                      builder: (context) {
                        final hasUser = _googleSignInService.currentUser != null;
                        if (hasUser) {
                          return CleanButton(
                            label: 'Clear Google Sign-In',
                            icon: Icons.logout,
                            isPrimary: false,
                            onPressed: _handleLogout,
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    
                    // Error Explanation
                    if (_isGoogleLoading == false)
                      Container(
                        margin: const EdgeInsets.only(top: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                          border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                                const SizedBox(width: AppSpacing.xs),
                                Text(
                                  'Google Sign-In Error Help',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warning,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'If you see "Not signed in" or "NetworkError" errors, this usually means:\n'
                              '1. Redirect URI not configured in Google Cloud Console\n'
                              '2. OAuth client not properly set up\n\n'
                              'See GOOGLE_SIGNIN_FEDCM_FIX.md for detailed setup instructions.',
                              style: AppTextStyles.captionWithColor(AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
