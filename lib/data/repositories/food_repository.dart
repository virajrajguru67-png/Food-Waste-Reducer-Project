import '../models/food_item_model.dart';
import '../models/restaurant_model.dart';
import '../datasources/remote/api_service.dart';

class FoodRepository {
  final ApiService _apiService;

  FoodRepository(this._apiService);

  // Get all food items
  Future<List<FoodItemModel>> getFoodItems({
    String? category,
    double? maxDistance,
    double? minDiscount,
    String? searchQuery,
  }) async {
    try {
      // TODO: Replace with actual API call
      // For now, return mock data
      return _getMockFoodItems();
    } catch (e) {
      throw Exception('Failed to fetch food items: $e');
    }
  }

  // Get food item by ID
  Future<FoodItemModel> getFoodItemById(String id) async {
    try {
      // TODO: Replace with actual API call
      final items = _getMockFoodItems();
      return items.firstWhere((item) => item.id == id);
    } catch (e) {
      throw Exception('Failed to fetch food item: $e');
    }
  }

  // Get restaurants
  Future<List<RestaurantModel>> getRestaurants({
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    try {
      // TODO: Replace with actual API call
      return _getMockRestaurants();
    } catch (e) {
      throw Exception('Failed to fetch restaurants: $e');
    }
  }

  // Get restaurant by ID
  Future<RestaurantModel> getRestaurantById(String id) async {
    try {
      // TODO: Replace with actual API call
      final restaurants = _getMockRestaurants();
      return restaurants.firstWhere((restaurant) => restaurant.id == id);
    } catch (e) {
      throw Exception('Failed to fetch restaurant: $e');
    }
  }

  // Mock data - will be replaced with actual API calls
  List<FoodItemModel> _getMockFoodItems() {
    return [
      FoodItemModel(
        id: '1',
        restaurantId: '1',
        name: 'Prime Steak Frites',
        description: 'Roasted red peppers, Classic Chimichurri Steak Sauce',
        category: 'Steak Special',
        images: ['https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800'],
        originalPrice: 29.00,
        discountedPrice: 14.50,
        quantityAvailable: 5,
        expiryTime: DateTime.now().add(const Duration(hours: 2)),
        pickupTimeWindow: {
          'start': DateTime.now().add(const Duration(minutes: 20)).toIso8601String(),
          'end': DateTime.now().add(const Duration(minutes: 25)).toIso8601String(),
        },
        status: 'available',
        createdAt: DateTime.now(),
      ),
      FoodItemModel(
        id: '2',
        restaurantId: '2',
        name: 'Fresh Salad Bowl',
        description: 'Mixed greens with seasonal vegetables',
        category: 'Salads',
        images: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800'],
        originalPrice: 12.00,
        discountedPrice: 6.00,
        quantityAvailable: 8,
        expiryTime: DateTime.now().add(const Duration(hours: 1)),
        pickupTimeWindow: {
          'start': DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
          'end': DateTime.now().add(const Duration(minutes: 20)).toIso8601String(),
        },
        status: 'available',
        createdAt: DateTime.now(),
      ),
      FoodItemModel(
        id: '3',
        restaurantId: '3',
        name: 'Gourmet Burger',
        description: 'Premium beef patty with special sauce',
        category: 'Burgers',
        images: ['https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800'],
        originalPrice: 18.00,
        discountedPrice: 7.20,
        quantityAvailable: 3,
        expiryTime: DateTime.now().add(const Duration(hours: 3)),
        pickupTimeWindow: {
          'start': DateTime.now().add(const Duration(minutes: 10)).toIso8601String(),
          'end': DateTime.now().add(const Duration(minutes: 15)).toIso8601String(),
        },
        status: 'available',
        createdAt: DateTime.now(),
      ),
    ];
  }

  List<RestaurantModel> _getMockRestaurants() {
    return [
      RestaurantModel(
        id: '1',
        ownerId: 'owner1',
        name: 'Slice Pizza',
        description: 'Authentic Italian pizza',
        category: 'Italian',
        address: {
          'street': '123 Main St',
          'city': 'Huntington Beach',
          'state': 'CA',
          'zip': '92647',
        },
        location: {'lat': 33.6595, 'lng': -117.9988},
        images: ['https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800'],
        operatingHours: {
          'monday': {'open': '11:00', 'close': '22:00'},
          'tuesday': {'open': '11:00', 'close': '22:00'},
        },
        verified: true,
        rating: 4.5,
        reviewCount: 120,
        createdAt: DateTime.now(),
      ),
      RestaurantModel(
        id: '2',
        ownerId: 'owner2',
        name: 'The Coffee Bean',
        description: 'Fresh coffee and pastries',
        category: 'Cafe',
        address: {
          'street': '456 Oak Ave',
          'city': 'Huntington Beach',
          'state': 'CA',
          'zip': '92647',
        },
        location: {'lat': 33.6600, 'lng': -117.9990},
        images: ['https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=800'],
        operatingHours: {
          'monday': {'open': '07:00', 'close': '20:00'},
        },
        verified: true,
        rating: 4.3,
        reviewCount: 85,
        createdAt: DateTime.now(),
      ),
    ];
  }
}

