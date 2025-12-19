import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'food_provider.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(apiServiceProvider));
});

final ordersProvider = FutureProvider.family<List<OrderModel>, String>((ref, userId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return await repository.getUserOrders(userId);
});

final orderProvider = FutureProvider.family<OrderModel, String>((ref, orderId) async {
  final repository = ref.watch(orderRepositoryProvider);
  return await repository.getOrderById(orderId);
});

final orderStatusProvider = StreamProvider.family<OrderModel, String>((ref, orderId) async* {
  final repository = ref.watch(orderRepositoryProvider);
  // Poll for order status updates
  while (true) {
    final order = await repository.getOrderById(orderId);
    yield order;
    await Future.delayed(const Duration(seconds: 5));
  }
});

