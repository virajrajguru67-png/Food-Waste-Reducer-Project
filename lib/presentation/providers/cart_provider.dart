import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/cart_item_model.dart';
import '../../data/models/food_item_model.dart';

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  void addItem(FoodItemModel foodItem) {
    final existingIndex = state.indexWhere(
      (item) => item.foodItem.id == foodItem.id,
    );

    if (existingIndex >= 0) {
      // Item already in cart, increment quantity
      final updatedCart = List<CartItemModel>.from(state);
      if (updatedCart[existingIndex].canIncrement) {
        updatedCart[existingIndex].increment();
        state = updatedCart;
      }
    } else {
      // New item, add to cart
      state = [...state, CartItemModel(foodItem: foodItem, quantity: 1)];
    }
  }

  void removeItem(String foodItemId) {
    state = state.where((item) => item.foodItem.id != foodItemId).toList();
  }

  void updateQuantity(String foodItemId, int quantity) {
    if (quantity <= 0) {
      removeItem(foodItemId);
      return;
    }

    final updatedCart = state.map((item) {
      if (item.foodItem.id == foodItemId) {
        final newItem = CartItemModel(
          foodItem: item.foodItem,
          quantity: quantity.clamp(1, item.foodItem.quantityAvailable),
        );
        return newItem;
      }
      return item;
    }).toList();

    state = updatedCart;
  }

  void incrementQuantity(String foodItemId) {
    final updatedCart = List<CartItemModel>.from(state);
    final index = updatedCart.indexWhere((item) => item.foodItem.id == foodItemId);
    if (index >= 0 && updatedCart[index].canIncrement) {
      updatedCart[index].increment();
      state = updatedCart;
    }
  }

  void decrementQuantity(String foodItemId) {
    final updatedCart = List<CartItemModel>.from(state);
    final index = updatedCart.indexWhere((item) => item.foodItem.id == foodItemId);
    if (index >= 0) {
      if (updatedCart[index].quantity > 1) {
        updatedCart[index].decrement();
      } else {
        updatedCart.removeAt(index);
      }
      state = updatedCart;
    }
  }

  void clearCart() {
    state = [];
  }

  double get totalPrice {
    return state.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get itemCount {
    return state.fold(0, (sum, item) => sum + item.quantity);
  }

  bool get isEmpty => state.isEmpty;
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((ref) {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0.0, (sum, item) => sum + item.totalPrice);
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (sum, item) => sum + item.quantity);
});

