import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_animations.dart';

class StatusBanner extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final bool showPulse;
  final VoidCallback? onDismiss;

  const StatusBanner({
    super.key,
    required this.message,
    required this.icon,
    this.backgroundColor = AppColors.success,
    this.showPulse = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          showPulse
              ? Icon(
                  icon,
                  color: AppColors.textOnPrimary,
                  size: AppSpacing.iconMedium,
                )
                    .animate(
                      onPlay: (controller) => controller.repeat(),
                    )
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.2, 1.2),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                    )
                    .then()
                    .scale(
                      begin: const Offset(1.2, 1.2),
                      end: const Offset(1.0, 1.0),
                      duration: const Duration(seconds: 1),
                      curve: Curves.easeInOut,
                    )
              : Icon(
                  icon,
                  color: AppColors.textOnPrimary,
                  size: AppSpacing.iconMedium,
                ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.subheading2.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(
                Icons.close,
                color: AppColors.textOnPrimary,
                size: AppSpacing.iconSmall,
              ),
              onPressed: onDismiss,
            ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -0.5, end: 0, curve: AppAnimations.bounceCurve)
        .fadeIn(duration: AppAnimations.normal);
  }
}

