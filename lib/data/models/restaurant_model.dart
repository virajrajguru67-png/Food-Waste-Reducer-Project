class RestaurantModel {
  final String id;
  final String ownerId;
  final String name;
  final String? description;
  final String category;
  final Map<String, dynamic> address;
  final Map<String, double> location; // {lat, lng}
  final String? phone;
  final String? email;
  final List<String> images;
  final Map<String, dynamic> operatingHours;
  final bool verified;
  final double rating;
  final int reviewCount;
  final DateTime createdAt;

  RestaurantModel({
    required this.id,
    required this.ownerId,
    required this.name,
    this.description,
    required this.category,
    required this.address,
    required this.location,
    this.phone,
    this.email,
    required this.images,
    required this.operatingHours,
    required this.verified,
    required this.rating,
    required this.reviewCount,
    required this.createdAt,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      address: json['address'] as Map<String, dynamic>,
      location: Map<String, double>.from(json['location'] as Map),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      images: List<String>.from(json['images'] as List),
      operatingHours: json['operating_hours'] as Map<String, dynamic>,
      verified: json['verified'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['review_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'name': name,
      'description': description,
      'category': category,
      'address': address,
      'location': location,
      'phone': phone,
      'email': email,
      'images': images,
      'operating_hours': operatingHours,
      'verified': verified,
      'rating': rating,
      'review_count': reviewCount,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

