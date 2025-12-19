import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_animations.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/order_provider.dart';
import '../../widgets/status_banner.dart';

class OrderTrackingScreen extends ConsumerWidget {
  final String orderId;

  const OrderTrackingScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderProvider(orderId));

    return Scaffold(
      body: orderAsync.when(
        data: (order) => _buildContent(context, order),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, order) {
    final statusSteps = [
      'confirmed',
      'preparing',
      'ready',
      'picked_up',
    ];
    final currentStep = statusSteps.indexOf(order.status);
    final progress = currentStep >= 0 ? (currentStep + 1) / statusSteps.length : 0.0;

    return CustomScrollView(
      slivers: [
        // Status Banner
        SliverToBoxAdapter(
          child: StatusBanner(
            message: _getStatusMessage(order.status),
            icon: _getStatusIcon(order.status),
            backgroundColor: AppColors.success,
            showPulse: order.status == 'ready',
          ),
        ),

        // Progress Timeline
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Progress',
                  style: AppTextStyles.heading2,
                )
                    .animate()
                    .fadeIn()
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppSpacing.lg),
                _ProgressTimeline(
                  steps: statusSteps,
                  currentStep: currentStep,
                  progress: progress,
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 100))
                    .slideY(begin: 0.1, end: 0),
              ],
            ),
          ),
        ),

        // Order Details
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order Details',
                  style: AppTextStyles.heading2,
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 200))
                    .slideX(begin: -0.1, end: 0),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  ),
                  child: Column(
                    children: [
                          ...(order.items as List).map<Widget>((item) => Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.md),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSmall,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: item.foodItemImage,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.foodItemName,
                                        style: AppTextStyles.bodyLarge,
                                      ),
                                      Text(
                                        'Quantity: ${item.quantity}',
                                        style: AppTextStyles.bodySmallWithColor(
                                          AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.format(item.totalPrice),
                                  style: AppTextStyles.subheading2,
                                ),
                              ],
                            ),
                          )),
                      const Divider(height: AppSpacing.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: AppTextStyles.heading3,
                          ),
                          Text(
                            CurrencyFormatter.format(order.finalAmount),
                            style: AppTextStyles.heading2WithColor(
                              AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: const Duration(milliseconds: 300))
                    .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0)),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'confirmed':
        return 'Order Confirmed! Your food is being prepared.';
      case 'preparing':
        return 'Your order is being prepared.';
      case 'ready':
        return 'Your order is ready for pickup!';
      case 'picked_up':
        return 'Order Delivered! Enjoy your meal!';
      default:
        return 'Order Status: ${status.toUpperCase()}';
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.assignment_turned_in;
      case 'picked_up':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }
}

class _ProgressTimeline extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final double progress;

  const _ProgressTimeline({
    required this.steps,
    required this.currentStep,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress Bar
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
              ),
            )
                .animate()
                .scaleX(begin: 0, end: 1, duration: AppAnimations.slow),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        // Steps
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isCompleted = index <= currentStep;
            final isCurrent = index == currentStep;

            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.border,
                      shape: BoxShape.circle,
                    ),
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            color: AppColors.textOnPrimary,
                          )
                        : Text(
                            '${index + 1}',
                            style: AppTextStyles.bodyMedium,
                          ),
                  )
                      .animate(target: isCurrent ? 1 : 0)
                      .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.2, 1.2))
                      .then()
                      .scale(begin: const Offset(1.2, 1.2), end: const Offset(1.0, 1.0)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _formatStepName(step),
                    style: AppTextStyles.caption.copyWith(
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _formatStepName(String step) {
    return step.split('_').map((word) {
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

