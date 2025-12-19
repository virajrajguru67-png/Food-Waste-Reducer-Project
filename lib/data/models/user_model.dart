class UserModel {
  final String id;
  final String googleId;
  final String email;
  final String name;
  final String? phone;
  final String? avatarUrl;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? preferences;
  final String? subscriptionTier;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.googleId,
    required this.email,
    required this.name,
    this.phone,
    this.avatarUrl,
    this.address,
    this.preferences,
    this.subscriptionTier,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      googleId: json['google_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      address: json['address'] as Map<String, dynamic>?,
      preferences: json['preferences'] as Map<String, dynamic>?,
      subscriptionTier: json['subscription_tier'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'google_id': googleId,
      'email': email,
      'name': name,
      'phone': phone,
      'avatar_url': avatarUrl,
      'address': address,
      'preferences': preferences,
      'subscription_tier': subscriptionTier,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

