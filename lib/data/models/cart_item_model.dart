import 'food_item_model.dart';

class CartItemModel {
  final FoodItemModel foodItem;
  int quantity;

  CartItemModel({
    required this.foodItem,
    this.quantity = 1,
  });

  double get totalPrice => foodItem.discountedPrice * quantity;

  void increment() {
    if (quantity < foodItem.quantityAvailable) {
      quantity++;
    }
  }

  void decrement() {
    if (quantity > 1) {
      quantity--;
    }
  }

  bool get canIncrement => quantity < foodItem.quantityAvailable;
  bool get canDecrement => quantity > 1;
}

