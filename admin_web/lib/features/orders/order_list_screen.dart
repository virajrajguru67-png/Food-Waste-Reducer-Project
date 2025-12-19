import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../core/theme/admin_colors.dart';
import '../../services/admin_api_service.dart';

class OrderListScreen extends StatefulWidget {
  final AdminApiService apiService;

  const OrderListScreen({super.key, required this.apiService});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    final result = await widget.apiService.getOrders();
    if (result['success'] == true) {
      setState(() {
        _orders = result['data'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return AdminColors.warning;
      case 'confirmed':
      case 'preparing':
        return AdminColors.info;
      case 'ready':
      case 'delivered':
        return AdminColors.success;
      case 'cancelled':
        return AdminColors.error;
      default:
        return AdminColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Orders',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: DataTable2(
                columns: [
                  DataColumn2(label: Text('Order #')),
                  DataColumn2(label: Text('Restaurant')),
                  DataColumn2(label: Text('Amount')),
                  DataColumn2(label: Text('Status')),
                  DataColumn2(label: Text('Payment')),
                  DataColumn2(label: Text('Actions')),
                ],
                rows: _orders.map((order) {
                  return DataRow2(
                    cells: [
                      DataCell(Text(order['orderNumber'] ?? '')),
                      DataCell(Text(order['restaurantName'] ?? '')),
                      DataCell(Text('₹${order['finalAmount']?.toStringAsFixed(2) ?? '0.00'}')),
                      DataCell(Chip(
                        label: Text(order['status'] ?? ''),
                        backgroundColor: _getStatusColor(order['status']),
                      )),
                      DataCell(Text(order['paymentStatus'] ?? '')),
                      DataCell(
                        DropdownButton<String>(
                          value: order['status'],
                          items: const [
                            DropdownMenuItem(value: 'pending', child: Text('Pending')),
                            DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
                            DropdownMenuItem(value: 'preparing', child: Text('Preparing')),
                            DropdownMenuItem(value: 'ready', child: Text('Ready')),
                            DropdownMenuItem(value: 'delivered', child: Text('Delivered')),
                            DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
                          ],
                          onChanged: (value) async {
                            if (value != null) {
                              await widget.apiService.updateOrderStatus(
                                order['id'],
                                value,
                              );
                              _loadOrders();
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

