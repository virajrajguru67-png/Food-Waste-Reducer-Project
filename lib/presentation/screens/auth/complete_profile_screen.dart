import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/safe_navigation.dart';
import '../../../services/api_service.dart';
import '../../widgets/animated_button.dart';
import '../main/main_screen.dart';

class CompleteProfileScreen extends StatefulWidget {
  final String email;
  final String name;
  final String googleId;
  final String? photoUrl;

  const CompleteProfileScreen({
    super.key,
    required this.email,
    required this.name,
    required this.googleId,
    this.photoUrl,
  });

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _completeProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // First, ensure Google Sign-In is complete (get user ID from token)
      final googleResult = await _apiService.googleSignIn(
        googleId: widget.googleId,
        email: widget.email,
        name: widget.name,
        photoUrl: widget.photoUrl,
      );

      if (googleResult['success'] != true) {
        throw Exception(googleResult['message'] ?? 'Google Sign-In failed');
      }

      final user = googleResult['user'] as Map<String, dynamic>?;
      final userId = user?['id']?.toString();

      if (userId == null) {
        throw Exception('User ID not found');
      }

      // Update user profile with phone number if provided
      if (_phoneController.text.trim().isNotEmpty) {
        final updateResult = await _apiService.updateProfile(
          userId: userId,
          phone: _phoneController.text.trim(),
        );

        if (updateResult['success'] != true) {
          // Phone update failed, but sign-in was successful, so continue
          debugPrint('Warning: Failed to update phone: ${updateResult['message']}');
        }
      }

      // Navigate to home screen using safe navigation
      if (mounted) {
        await SafeNavigation.navigateAfterDelay(
          context,
          () => const MainScreen(),
          replace: true,
          delay: const Duration(milliseconds: 150),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${error.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
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

                // Success Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    size: 50,
                    color: AppColors.success,
                  ),
                )
                    .animate()
                    .scale(delay: const Duration(milliseconds: 100)),
                const SizedBox(height: AppSpacing.lg),

                // Welcome Text
                Text(
                  'Complete Profile',
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 200))
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Google Sign-In successful!\nPlease complete your profile',
                  style: AppTextStyles.bodyLargeWithColor(
                    AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 300))
                    .slideY(begin: 0.1, end: 0),
                const SizedBox(height: AppSpacing.xl),

                // Email Display (Read-only)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    border: Border.all(
                      color: AppColors.textSecondary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              widget.email,
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 400)),
                const SizedBox(height: AppSpacing.md),

                // Phone Field (Optional)
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    hintText: 'Enter your phone number',
                    prefixIcon: const Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                    ),
                    filled: true,
                    fillColor: AppColors.cardBackground,
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 500))
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppSpacing.xl),

                // Complete Profile Button
                AnimatedButton(
                  label: 'Complete Profile',
                  icon: Icons.check,
                  isLoading: _isLoading,
                  onPressed: _isLoading ? null : _completeProfile,
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 600))
                    .slideY(begin: 0.2, end: 0),
                const SizedBox(height: AppSpacing.md),

                // Skip for now
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // Complete sign-in without phone
                          _completeProfile();
                        },
                  child: Text(
                    'Skip for now',
                    style: AppTextStyles.bodyMediumWithColor(
                      AppColors.textSecondary,
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

