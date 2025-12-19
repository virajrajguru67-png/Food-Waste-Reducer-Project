class FoodItemModel {
  final String id;
  final String restaurantId;
  final String name;
  final String? description;
  final String category;
  final List<String> images;
  final double originalPrice;
  final double discountedPrice;
  final int quantityAvailable;
  final DateTime? expiryTime;
  final Map<String, dynamic> pickupTimeWindow;
  final List<String>? ingredients;
  final List<String>? allergens;
  final Map<String, dynamic>? dietaryInfo;
  final String status; // available, reserved, sold_out
  final DateTime createdAt;

  FoodItemModel({
    required this.id,
    required this.restaurantId,
    required this.name,
    this.description,
    required this.category,
    required this.images,
    required this.originalPrice,
    required this.discountedPrice,
    required this.quantityAvailable,
    this.expiryTime,
    required this.pickupTimeWindow,
    this.ingredients,
    this.allergens,
    this.dietaryInfo,
    required this.status,
    required this.createdAt,
  });

  double get discountPercentage {
    if (originalPrice == 0) return 0;
    return ((originalPrice - discountedPrice) / originalPrice * 100).round().toDouble();
  }

  bool get isAvailable => status == 'available' && quantityAvailable > 0;

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      id: json['id'] as String,
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      images: List<String>.from(json['images'] as List),
      originalPrice: (json['original_price'] as num).toDouble(),
      discountedPrice: (json['discounted_price'] as num).toDouble(),
      quantityAvailable: json['quantity_available'] as int,
      expiryTime: json['expiry_time'] != null
          ? DateTime.parse(json['expiry_time'] as String)
          : null,
      pickupTimeWindow: json['pickup_time_window'] as Map<String, dynamic>,
      ingredients: json['ingredients'] != null
          ? List<String>.from(json['ingredients'] as List)
          : null,
      allergens: json['allergens'] != null
          ? List<String>.from(json['allergens'] as List)
          : null,
      dietaryInfo: json['dietary_info'] as Map<String, dynamic>?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurant_id': restaurantId,
      'name': name,
      'description': description,
      'category': category,
      'images': images,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'quantity_available': quantityAvailable,
      'expiry_time': expiryTime?.toIso8601String(),
      'pickup_time_window': pickupTimeWindow,
      'ingredients': ingredients,
      'allergens': allergens,
      'dietary_info': dietaryInfo,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

