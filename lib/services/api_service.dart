import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  static const String _tokenKey = 'auth_token';

  String? get token => _token;

  // Initialize and load token from storage
  Future<void> init() async {
    await _loadToken();
  }

  // Load token from shared preferences
  Future<void> _loadToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString(_tokenKey);
      debugPrint('Token loaded from storage: ${_token != null ? 'Yes' : 'No'}');
    } catch (e) {
      debugPrint('Error loading token: $e');
    }
  }

  // Save token to shared preferences
  Future<void> _saveToken(String? token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (token != null) {
        await prefs.setString(_tokenKey, token);
        debugPrint('Token saved to storage');
      } else {
        await prefs.remove(_tokenKey);
        debugPrint('Token removed from storage');
      }
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }

  void setToken(String? token) {
    _token = token;
    _saveToken(token);
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
        }),
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid response from server: ${response.body}',
        };
      }
      
      if (response.statusCode == 201 && data['success'] == true) {
        final token = data['data']?['token'];
        setToken(token);
        return {
          'success': true,
          'user': data['data']?['user'],
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']['token'];
        setToken(token);
        return {
          'success': true,
          'user': data['data']['user'],
          'token': token,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> googleSignIn({
    required String googleId,
    required String email,
    String? name,
    String? photoUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.googleSignIn),
        headers: ApiConfig.getHeaders(),
        body: jsonEncode({
          'googleId': googleId,
          'email': email,
          'name': name,
          'photoUrl': photoUrl,
        }),
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid response from server: ${response.body}',
        };
      }
      
      if (response.statusCode == 200 && data['success'] == true) {
        final token = data['data']?['token'];
        setToken(token);
        return {
          'success': true,
          'user': data['data']?['user'],
          'token': token,
        };
      } else {
        // Log the full error response for debugging
        debugPrint('Google Sign-In error response: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return {
          'success': false,
          'message': data['message'] ?? data['error'] ?? 'Google Sign-In failed',
          'errorDetails': data['error'] ?? response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? phone,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(ApiConfig.updateProfile),
        headers: ApiConfig.getHeaders(token: _token),
        body: jsonEncode({
          'userId': userId,
          'phone': phone,
        }),
      );

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (e) {
        return {
          'success': false,
          'message': 'Invalid response from server: ${response.body}',
        };
      }
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': data['data']?['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.getCurrentUser}?userId=$_token'),
        headers: ApiConfig.getHeaders(token: _token),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'user': data['data']['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to get user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  // Orders
  Future<Map<String, dynamic>> getOrders({String? status}) async {
    try {
      final uri = Uri.parse(ApiConfig.orders).replace(
        queryParameters: status != null ? {'status': status} : null,
      );
      final response = await http.get(
        uri,
        headers: ApiConfig.getHeaders(token: _token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch orders'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getOrderById(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.orderById(orderId)),
        headers: ApiConfig.getHeaders(token: _token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch order'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> cancelOrder(String orderId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.cancelOrder(orderId)),
        headers: ApiConfig.getHeaders(token: _token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to cancel order'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Delivery Tracking
  Future<Map<String, dynamic>> getDeliveryStatus(String orderId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.deliveryByOrderId(orderId)),
        headers: ApiConfig.getHeaders(token: _token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch delivery status'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Coupons
  Future<Map<String, dynamic>> validateCoupon(String code, double orderAmount, {int? restaurantId}) async {
    try {
      final uri = Uri.parse(ApiConfig.validateCoupon(code)).replace(
        queryParameters: {
          'orderAmount': orderAmount.toString(),
          if (restaurantId != null) 'restaurantId': restaurantId.toString(),
        },
      );
      final response = await http.get(
        uri,
        headers: ApiConfig.getHeaders(token: _token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Invalid coupon'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> getCoupons() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.coupons),
        headers: ApiConfig.getHeaders(token: _token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch coupons'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Reviews
  Future<Map<String, dynamic>> getReviewsByRestaurant(String restaurantId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.reviewsByRestaurant(restaurantId)),
        headers: ApiConfig.getHeaders(token: _token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch reviews'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> createReview({
    required String restaurantId,
    required int rating,
    String? comment,
    String? orderId,
    List<String>? images,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.reviews),
        headers: ApiConfig.getHeaders(token: _token),
        body: jsonEncode({
          'restaurantId': restaurantId,
          'rating': rating,
          'comment': comment,
          'orderId': orderId,
          'images': images,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Failed to create review'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
