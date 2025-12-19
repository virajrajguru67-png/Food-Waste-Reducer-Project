import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../core/config/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DeliveryService {
  static final DeliveryService _instance = DeliveryService._internal();
  factory DeliveryService() => _instance;
  DeliveryService._internal();

  final ApiService _apiService = ApiService();

  /// Get delivery status for an order
  Future<Map<String, dynamic>> getDeliveryStatus(String orderId) async {
    return await _apiService.getDeliveryStatus(orderId);
  }

  /// Track delivery by tracking number (public endpoint)
  Future<Map<String, dynamic>> trackByTrackingNumber(String trackingNumber) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.deliveryTracking(trackingNumber)),
        headers: ApiConfig.getHeaders(),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'data': data['data']};
      }
      return {'success': false, 'message': data['message'] ?? 'Tracking not found'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Placeholder for external delivery API integration
  /// This will be implemented when the user provides the delivery API
  Future<Map<String, dynamic>> updateDeliveryFromExternal({
    required String orderId,
    required Map<String, dynamic> externalData,
  }) async {
    // TODO: Implement when external delivery API is provided
    debugPrint('External delivery API integration - to be implemented');
    return {
      'success': false,
      'message': 'External delivery API integration pending',
    };
  }

  /// Get delivery status history
  List<Map<String, dynamic>> getStatusHistory(Map<String, dynamic>? trackingData) {
    if (trackingData == null || trackingData['statusHistory'] == null) {
      return [];
    }
    return List<Map<String, dynamic>>.from(trackingData['statusHistory']);
  }

  /// Get current delivery status
  String getCurrentStatus(Map<String, dynamic>? trackingData) {
    return trackingData?['status'] ?? 'pending';
  }

  /// Get estimated delivery time
  DateTime? getEstimatedDeliveryTime(Map<String, dynamic>? trackingData) {
    if (trackingData == null || trackingData['estimatedDeliveryTime'] == null) {
      return null;
    }
    try {
      return DateTime.parse(trackingData['estimatedDeliveryTime']);
    } catch (e) {
      return null;
    }
  }
}

