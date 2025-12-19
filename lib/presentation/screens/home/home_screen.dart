import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/constants/app_constants.dart';
import '../../widgets/premium_food_card.dart';
import '../../widgets/clean_search_bar.dart';
import '../../widgets/animated_category_chip.dart';
import '../../providers/food_provider.dart';
import '../../providers/cart_provider.dart';
import '../food_detail/food_detail_screen.dart';
import '../cart/cart_screen.dart';
import '../order_history/order_history_screen.dart';
import '../profile/enhanced_profile_screen.dart';
import '../auth/login_screen.dart';
import '../../../services/google_sign_in_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Refresh data
            await Future.delayed(const Duration(seconds: 1));
          },
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // App Bar with Search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.eco_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    'SaveFood',
                                    style: AppTextStyles.heading2,
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Find food near you',
                                style: AppTextStyles.bodySmallWithColor(
                                  AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          PopupMenuButton(
                            icon: const CircleAvatar(
                              backgroundColor: AppColors.cardBackground,
                              child: Icon(Icons.person),
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.person),
                                    SizedBox(width: AppSpacing.sm),
                                    Text('Profile'),
                                  ],
                                ),
                                onTap: () {
                                  Future.delayed(Duration.zero, () {
                                    final user = GoogleSignInService().currentUser;
                                    if (user != null) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EnhancedProfileScreen(user: user),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Please login to view your profile'),
                                          backgroundColor: AppColors.warning,
                                          action: SnackBarAction(
                                            label: 'Login',
                                            textColor: AppColors.textOnPrimary,
                                            onPressed: () {
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => const LoginScreen(),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  });
                                },
                              ),
                              PopupMenuItem(
                                child: const Row(
                                  children: [
                                    Icon(Icons.history),
                                    SizedBox(width: AppSpacing.sm),
                                    Text('Order History'),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const OrderHistoryScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      CleanSearchBar(
                        hintText: 'Search for restaurant, dish...',
                        controller: _searchController,
                      ),
                    ],
                  ),
                ),
              ),

              // Compact Banner
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Save Food, Save Planet',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.textOnPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              'Reduce waste, save money',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textOnPrimary.withOpacity(0.85),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.eco, color: AppColors.textOnPrimary, size: 32),
                    ],
                  ),
                ),
              ),

              // Category Chips
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                  ),
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.screenPadding,
                      ),
                      itemCount: AppConstants.foodCategories.length,
                      itemBuilder: (context, index) {
                        final category = AppConstants.foodCategories[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: AnimatedCategoryChip(
                            label: category,
                            icon: index == 0 ? Icons.restaurant : null,
                            isSelected: _selectedCategory == category,
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Food Items List
              Consumer(
                builder: (context, ref, child) {
                  final foodItemsAsync = ref.watch(foodItemsProvider);
                  return foodItemsAsync.when(
                    data: (foodItems) => SliverPadding(
                      padding: const EdgeInsets.all(AppSpacing.screenPadding),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item = foodItems[index];
                            return AnimationConfiguration.staggeredList(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              child: SlideAnimation(
                                verticalOffset: 50.0,
                                child: FadeInAnimation(
                                  child: PremiumFoodCard(
                                    imageUrl: item.images.isNotEmpty
                                        ? item.images.first
                                        : 'https://via.placeholder.com/800',
                                    restaurantName: 'Restaurant ${item.restaurantId}',
                                    location: '2 mi away',
                                    discountBadge: '${item.discountPercentage.toInt()}% OFF',
                                    timeRemaining: '20-25 mins',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FoodDetailScreen(
                                            foodItemId: item.id,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                          childCount: foodItems.length,
                        ),
                      ),
                    ),
                    loading: () => const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.xxl),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    ),
                    error: (error, stack) => SliverToBoxAdapter(
                      child: Center(
                        child: Text('Error: $error'),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Consumer(
        builder: (context, ref, child) {
          final cartItemCount = ref.watch(cartItemCountProvider);
          return Stack(
            children: [
              FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CartScreen(),
                    ),
                  );
                },
                backgroundColor: AppColors.primary,
                icon: const Icon(Icons.shopping_cart),
                label: Text('Cart${cartItemCount > 0 ? ' ($cartItemCount)' : ''}'),
              ),
              if (cartItemCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$cartItemCount',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textOnPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

