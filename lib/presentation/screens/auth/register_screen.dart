import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/safe_navigation.dart';
import '../../../services/google_sign_in_service.dart';
import '../../../services/api_service.dart';
import '../../widgets/animated_button.dart';
import '../home/home_screen.dart';
import 'complete_profile_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final GoogleSignInService _googleSignInService = GoogleSignInService();
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call backend API
      final result = await _apiService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
      );

      if (result['success'] == true && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to home
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const HomeScreen(),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration failed'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${error.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
    });

    try {
      // Sign in with Google
      final account = await _googleSignInService.signIn();
      
      if (account == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Sign-In cancelled'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      // Send Google account info to backend
      // Ensure we have valid data
      if (account.id.isEmpty || account.email.isEmpty) {
        throw Exception('Invalid Google account data');
      }
      
      final result = await _apiService.googleSignIn(
        googleId: account.id,
        email: account.email,
        name: account.displayName?.isNotEmpty == true ? account.displayName : null,
        photoUrl: account.photoUrl,
      );

      if (result['success'] == true && mounted) {
        final user = result['user'] as Map<String, dynamic>?;
        final needsProfileCompletion = user?['phone'] == null || 
                                      (user?['phone'] as String?)?.isEmpty == true;
        
        if (needsProfileCompletion) {
          // Navigate to profile completion screen using safe navigation
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
          // User profile is complete, go to home
          SafeNavigation.showSnackBar(
            context,
            'Registration successful!',
            backgroundColor: AppColors.success,
          );
          await SafeNavigation.navigateAfterDelay(
            context,
            () => const HomeScreen(),
            replace: true,
            delay: const Duration(milliseconds: 150),
          );
        }
      } else if (mounted) {
        SafeNavigation.showSnackBar(
          context,
          result['message'] ?? 'Google Sign-In failed',
          backgroundColor: AppColors.error,
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
      } else {
        SafeNavigation.showSnackBar(
          context,
          'Google Sign-In failed: ${errorString}',
          backgroundColor: AppColors.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Welcome Text
                Text(
                  'Create Account',
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Get started with your account',
                  style: AppTextStyles.bodyMediumWithColor(
                    AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 100))
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSpacing.xl),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 200))
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppSpacing.md),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
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
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 300))
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppSpacing.md),

                // Phone Field
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    if (value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 400))
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppSpacing.md),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
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
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 500))
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppSpacing.md),

                // Confirm Password Field
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Confirm your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 600))
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppSpacing.xl),

                // Register Button
                AnimatedButton(
                  label: 'Create Account',
                  icon: Icons.person_add,
                  isLoading: _isLoading,
                  onPressed: _isLoading || _isGoogleLoading ? null : _handleRegister,
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 700))
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: AppSpacing.lg),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      child: Text(
                        'OR',
                        style: AppTextStyles.bodyMediumWithColor(
                          AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: AppColors.textSecondary.withOpacity(0.3),
                        thickness: 1,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 750)),
                const SizedBox(height: AppSpacing.lg),

                // Google Sign-In Button
                AnimatedButton(
                  label: _isGoogleLoading ? 'Signing up...' : 'Continue with Google',
                  icon: _isGoogleLoading ? null : Icons.g_mobiledata,
                  isLoading: _isGoogleLoading,
                  isOutlined: true,
                  onPressed: _isLoading || _isGoogleLoading ? null : _handleGoogleSignIn,
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 800))
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: AppSpacing.md),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: AppTextStyles.bodyMediumWithColor(
                        AppColors.textSecondary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Sign In',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 800)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

