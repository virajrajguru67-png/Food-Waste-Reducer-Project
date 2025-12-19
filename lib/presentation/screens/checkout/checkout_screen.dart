import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/animated_button.dart';
import '../order_tracking/order_tracking_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _selectedPaymentMethod = 'card';
  bool _isProcessing = false;

  Future<void> _placeOrder() async {
    setState(() => _isProcessing = true);

    try {
      final cartItems = ref.read(cartProvider);
      final cartTotal = ref.read(cartTotalProvider);

      // Convert cart items to order items
      final orderItems = cartItems.map((cartItem) {
        return {
          'food_item_id': cartItem.foodItem.id,
          'food_item_name': cartItem.foodItem.name,
          'food_item_image': cartItem.foodItem.images.isNotEmpty
              ? cartItem.foodItem.images.first
              : '',
          'quantity': cartItem.quantity,
          'unit_price': cartItem.foodItem.discountedPrice,
          'total_price': cartItem.totalPrice,
        };
      }).toList();

      // Calculate totals
      final totalAmount = cartItems.fold(
        0.0,
        (sum, item) => sum + (item.foodItem.originalPrice * item.quantity),
      );
      final discountAmount = totalAmount - cartTotal;

      // Place order
      final orderRepository = ref.read(orderRepositoryProvider);
      final order = await orderRepository.placeOrder(
        userId: 'user1', // TODO: Get from auth
        restaurantId: cartItems.first.foodItem.restaurantId,
        items: orderItems,
        totalAmount: totalAmount,
        discountAmount: discountAmount,
        paymentMethod: _selectedPaymentMethod,
      );

      // Clear cart
      ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OrderTrackingScreen(orderId: order.id),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to place order: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final totalOriginal = cartItems.fold(
      0.0,
      (sum, item) => sum + (item.foodItem.originalPrice * item.quantity),
    );
    final discount = totalOriginal - cartTotal;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Summary
            Text(
              'Order Summary',
              style: AppTextStyles.heading2,
            )
                .animate()
                .fadeIn()
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
                  ...cartItems.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${item.quantity}x ${item.foodItem.name}',
                              style: AppTextStyles.bodyMedium,
                            ),
                            Text(
                              CurrencyFormatter.format(item.totalPrice),
                              style: AppTextStyles.bodyMedium,
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        CurrencyFormatter.format(totalOriginal),
                        style: AppTextStyles.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discount',
                        style: AppTextStyles.bodyMediumWithColor(
                          AppColors.success,
                        ),
                      ),
                      Text(
                        '-${CurrencyFormatter.format(discount)}',
                        style: AppTextStyles.bodyMediumWithColor(
                          AppColors.success,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTextStyles.heading3,
                      ),
                      Text(
                        CurrencyFormatter.format(cartTotal),
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
                .fadeIn(delay: const Duration(milliseconds: 100))
                .slideY(begin: 0.1, end: 0),
            const SizedBox(height: AppSpacing.xl),

            // Payment Method
            Text(
              'Payment Method',
              style: AppTextStyles.heading2,
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 200))
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: AppSpacing.md),
            _PaymentMethodOption(
              value: 'card',
              label: 'Credit/Debit Card',
              icon: Icons.credit_card,
              isSelected: _selectedPaymentMethod == 'card',
              onTap: () => setState(() => _selectedPaymentMethod = 'card'),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 300))
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: AppSpacing.sm),
            _PaymentMethodOption(
              value: 'wallet',
              label: 'Digital Wallet',
              icon: Icons.account_balance_wallet,
              isSelected: _selectedPaymentMethod == 'wallet',
              onTap: () => setState(() => _selectedPaymentMethod = 'wallet'),
            )
                .animate()
                .fadeIn(delay: const Duration(milliseconds: 400))
                .slideX(begin: -0.1, end: 0),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: AnimatedButton(
            label: _isProcessing ? 'Processing...' : 'Place Order',
            icon: _isProcessing ? null : Icons.check,
            isLoading: _isProcessing,
            onPressed: _isProcessing ? null : _placeOrder,
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge,
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

