import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/food_item_model.dart';
import '../../data/models/restaurant_model.dart';
import '../../data/repositories/food_repository.dart';
import '../../data/datasources/remote/api_service.dart';

// Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final foodRepositoryProvider = Provider<FoodRepository>((ref) {
  return FoodRepository(ref.watch(apiServiceProvider));
});

final foodItemsProvider = FutureProvider<List<FoodItemModel>>((ref) async {
  final repository = ref.watch(foodRepositoryProvider);
  return await repository.getFoodItems();
});

final restaurantsProvider = FutureProvider<List<RestaurantModel>>((ref) async {
  final repository = ref.watch(foodRepositoryProvider);
  return await repository.getRestaurants();
});

final foodItemProvider = FutureProvider.family<FoodItemModel, String>((ref, id) async {
  final repository = ref.watch(foodRepositoryProvider);
  return await repository.getFoodItemById(id);
});

final restaurantProvider = FutureProvider.family<RestaurantModel, String>((ref, id) async {
  final repository = ref.watch(foodRepositoryProvider);
  return await repository.getRestaurantById(id);
});

