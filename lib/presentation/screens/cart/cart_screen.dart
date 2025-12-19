import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/clean_button.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartTotal = ref.watch(cartTotalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart(context)
          : _buildCartContent(context, ref, cartItems, cartTotal),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 100,
            color: AppColors.textSecondary,
          )
              .animate()
              .scale(delay: const Duration(milliseconds: 200)),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Your cart is empty',
            style: AppTextStyles.heading2,
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 400)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add some delicious food to get started!',
            style: AppTextStyles.bodyMediumWithColor(AppColors.textSecondary),
          )
              .animate()
              .fadeIn(delay: const Duration(milliseconds: 600)),
        ],
      ),
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    WidgetRef ref,
    List<dynamic> cartItems,
    double cartTotal,
  ) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
              return _CartItemCard(
                cartItem: cartItem,
                onIncrement: () {
                  ref.read(cartProvider.notifier).incrementQuantity(
                        cartItem.foodItem.id,
                      );
                },
                onDecrement: () {
                  ref.read(cartProvider.notifier).decrementQuantity(
                        cartItem.foodItem.id,
                      );
                },
                onRemove: () {
                  ref.read(cartProvider.notifier).removeItem(
                        cartItem.foodItem.id,
                      );
                },
              )
                  .animate()
                  .fadeIn(delay: Duration(milliseconds: 100 * index))
                  .slideX(begin: -0.1, end: 0);
            },
          ),
        ),
        _buildBottomBar(context, cartTotal, ref),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    double cartTotal,
    WidgetRef ref,
  ) {
    return Container(
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: AppTextStyles.heading3,
                ),
                Text(
                  CurrencyFormatter.format(cartTotal),
                  style: AppTextStyles.heading2WithColor(AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            CleanButton(
              label: 'Proceed to Checkout',
              icon: Icons.arrow_forward,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckoutScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic cartItem;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.cartItem,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
            child: CachedNetworkImage(
              imageUrl: cartItem.foodItem.images.isNotEmpty
                  ? cartItem.foodItem.images.first
                  : 'https://via.placeholder.com/100',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.foodItem.name,
                  style: AppTextStyles.subheading2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${CurrencyFormatter.format(cartItem.foodItem.discountedPrice)} each',
                  style: AppTextStyles.bodyMediumWithColor(
                    AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Quantity Controls
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: cartItem.canDecrement ? onDecrement : null,
                      color: AppColors.primary,
                      iconSize: 20,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: Text(
                        '${cartItem.quantity}',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: cartItem.canIncrement ? onIncrement : null,
                      color: AppColors.primary,
                      iconSize: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Price and Remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                CurrencyFormatter.format(cartItem.totalPrice),
                style: AppTextStyles.subheading1WithColor(
                  AppColors.primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: onRemove,
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

