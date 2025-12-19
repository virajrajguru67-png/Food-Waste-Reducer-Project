class ApiConfig {
  // Backend API base URL
  static const String baseUrl = 'http://localhost:5000/api';
  
  // Auth endpoints
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String googleSignIn = '$baseUrl/auth/google';
  static const String getCurrentUser = '$baseUrl/auth/me';
  static const String updateProfile = '$baseUrl/auth/profile';
  
  // Orders endpoints
  static const String orders = '$baseUrl/orders';
  static String orderById(String id) => '$orders/$id';
  static String orderStatus(String id) => '$orders/$id/status';
  static String cancelOrder(String id) => '$orders/$id/cancel';
  
  // Delivery endpoints
  static String deliveryByOrderId(String orderId) => '$baseUrl/delivery/$orderId';
  static String deliveryTracking(String trackingNumber) => '$baseUrl/delivery/track/$trackingNumber';
  
  // Coupons endpoints
  static const String coupons = '$baseUrl/coupons';
  static String validateCoupon(String code) => '$coupons/$code/validate';
  
  // Reviews endpoints
  static const String reviews = '$baseUrl/reviews';
  static String reviewsByRestaurant(String restaurantId) => '$reviews/restaurant/$restaurantId';
  
  // Headers
  static Map<String, String> getHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    
    return headers;
  }
}

