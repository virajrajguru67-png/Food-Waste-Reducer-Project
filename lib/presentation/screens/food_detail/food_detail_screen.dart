import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/food_item_model.dart';
import '../../providers/food_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/clean_button.dart';
import '../cart/cart_screen.dart';

class FoodDetailScreen extends ConsumerStatefulWidget {
  final String foodItemId;

  const FoodDetailScreen({
    super.key,
    required this.foodItemId,
  });

  @override
  ConsumerState<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends ConsumerState<FoodDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _addToCart(FoodItemModel foodItem) {
    for (int i = 0; i < _quantity; i++) {
      ref.read(cartProvider.notifier).addItem(foodItem);
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $_quantity ${foodItem.name} to cart'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppColors.textOnPrimary,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodItemAsync = ref.watch(foodItemProvider(widget.foodItemId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: foodItemAsync.when(
        data: (foodItem) => Column(
          children: [
            Expanded(child: _buildContent(foodItem)),
            _buildBottomBar(foodItem),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildContent(FoodItemModel foodItem) {
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.55; // 55% of screen height

    return Stack(
      children: [
        // Food Image - Top Section
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: imageHeight,
          child: Stack(
            children: [
              // Food Image
              CachedNetworkImage(
                imageUrl: foodItem.images.isNotEmpty
                    ? foodItem.images.first
                    : 'https://via.placeholder.com/800',
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
              // Back Button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              // Discount Badge - Top Right
              Positioned(
                top: 60,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${foodItem.discountPercentage.toInt()}% OFF',
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Details Card - Overlapping the image
        Positioned(
          top: imageHeight - 40, // Overlap by 40px
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dish Name
                  Text(
                    foodItem.name,
                    style: AppTextStyles.heading1,
                  ),
                  const SizedBox(height: 8),
                  // Availability
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Available for pickup in ${_getTimeRemaining(foodItem)}',
                        style: AppTextStyles.bodySmallWithColor(
                          AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Description Heading
                  Text(
                    'Description',
                    style: AppTextStyles.subheading1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Description Text
                  if (foodItem.description != null)
                    Text(
                      foodItem.description!,
                      style: AppTextStyles.bodyMediumWithColor(
                        AppColors.textPrimary,
                      ),
                    ),
                  const SizedBox(height: 24),
                  // Pricing Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Original Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Original Price',
                            style: AppTextStyles.bodySmallWithColor(
                              AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(foodItem.originalPrice),
                            style: AppTextStyles.bodyMedium.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      // Discounted Price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Your Price',
                            style: AppTextStyles.bodySmallWithColor(
                              AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            CurrencyFormatter.format(foodItem.discountedPrice),
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(FoodItemModel foodItem) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Quantity Selector - More Compact
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Minus Button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                    color: AppColors.textSecondary,
                    padding: EdgeInsets.zero,
                  ),
                ),
                // Quantity Display
                Container(
                  width: 44,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    '$_quantity',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Plus Button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: _quantity < foodItem.quantityAvailable
                        ? () => setState(() => _quantity++)
                        : null,
                    color: AppColors.textOnPrimary,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            // Add to Cart Button - Takes remaining space
            Expanded(
              child: CleanButton(
                label: 'Add to Cart - ${CurrencyFormatter.format(_quantity * foodItem.discountedPrice)}',
                icon: Icons.shopping_cart,
                onPressed: foodItem.isAvailable
                    ? () => _addToCart(foodItem)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTimeRemaining(FoodItemModel foodItem) {
    if (foodItem.expiryTime == null) return 'N/A';
    final now = DateTime.now();
    final difference = foodItem.expiryTime!.difference(now);
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes';
    } else {
      return '${difference.inHours} hours';
    }
  }
}

