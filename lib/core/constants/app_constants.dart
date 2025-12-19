class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'SaveFood';
  static const String appTagline = 'Save Food, Save Planet';

  // API Configuration (to be updated with actual backend)
  static const String baseUrl = 'https://api.foodwastereducer.com';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Pagination
  static const int itemsPerPage = 20;
  static const int maxRetries = 3;

  // Cache
  static const Duration cacheExpiration = Duration(hours: 1);

  // Food Categories
  static const List<String> foodCategories = [
    'All',
    'Bakery',
    'Fruits & Vegetables',
    'Dairy',
    'Meat & Seafood',
    'Prepared Meals',
    'Beverages',
    'Snacks',
    'Desserts',
  ];

  // Order Status
  static const String orderStatusPending = 'pending';
  static const String orderStatusConfirmed = 'confirmed';
  static const String orderStatusPreparing = 'preparing';
  static const String orderStatusReady = 'ready';
  static const String orderStatusPickedUp = 'picked_up';
  static const String orderStatusCancelled = 'cancelled';
}

