import '../models/order_model.dart';
import '../datasources/remote/api_service.dart';

class OrderRepository {
  final ApiService _apiService;

  OrderRepository(this._apiService);

  // Place order
  Future<OrderModel> placeOrder({
    required String userId,
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required double discountAmount,
    String? paymentMethod,
    Map<String, dynamic>? address,
  }) async {
    try {
      // TODO: Replace with actual API call
      // For now, return mock order
      return _createMockOrder(
        userId: userId,
        restaurantId: restaurantId,
        items: items,
        totalAmount: totalAmount,
        discountAmount: discountAmount,
      );
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  // Get order by ID
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      // TODO: Replace with actual API call
      return _getMockOrders().firstWhere((order) => order.id == orderId);
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  // Get user orders
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      // TODO: Replace with actual API call
      return _getMockOrders().where((order) => order.userId == userId).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  // Update order status
  Future<OrderModel> updateOrderStatus(String orderId, String status) async {
    try {
      // TODO: Replace with actual API call
      final order = await getOrderById(orderId);
      return OrderModel(
        id: order.id,
        userId: order.userId,
        restaurantId: order.restaurantId,
        restaurantName: order.restaurantName,
        items: order.items,
        totalAmount: order.totalAmount,
        discountAmount: order.discountAmount,
        finalAmount: order.finalAmount,
        status: status,
        paymentStatus: order.paymentStatus,
        paymentMethod: order.paymentMethod,
        pickupTime: order.pickupTime,
        address: order.address,
        createdAt: order.createdAt,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  // Mock data
  OrderModel _createMockOrder({
    required String userId,
    required String restaurantId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required double discountAmount,
  }) {
    return OrderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      restaurantId: restaurantId,
      restaurantName: 'Slice Pizza',
      items: items.map((item) => OrderItem.fromJson(item)).toList(),
      totalAmount: totalAmount,
      discountAmount: discountAmount,
      finalAmount: totalAmount - discountAmount,
      status: 'confirmed',
      paymentStatus: 'pending',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  List<OrderModel> _getMockOrders() {
    return [
      OrderModel(
        id: '1',
        userId: 'user1',
        restaurantId: '1',
        restaurantName: 'Slice Pizza',
        items: [
          OrderItem(
            foodItemId: '1',
            foodItemName: 'Prime Steak Frites',
            foodItemImage: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
            quantity: 2,
            unitPrice: 14.50,
            totalPrice: 29.00,
          ),
        ],
        totalAmount: 29.00,
        discountAmount: 14.50,
        finalAmount: 14.50,
        status: 'ready',
        paymentStatus: 'paid',
        paymentMethod: 'card',
        pickupTime: DateTime.now().add(const Duration(minutes: 10)),
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        updatedAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
  }
}

