import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../widgets/clean_button.dart';

class CleanOrderTrackingScreen extends StatelessWidget {
  final String orderNumber;
  final String restaurantName;
  final String status;
  final String type; // 'Delivery' or 'Pickup'
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String? deliveryAddress;

  const CleanOrderTrackingScreen({
    super.key,
    required this.orderNumber,
    required this.restaurantName,
    required this.status,
    required this.type,
    required this.items,
    required this.totalAmount,
    this.deliveryAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order ID #$orderNumber'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(status),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getStatusTitle(status),
                                style: AppTextStyles.subheading1.copyWith(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getStatusMessage(status),
                                style: AppTextStyles.bodySmallWithColor(
                                  AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Progress Steps
                  _ProgressSteps(currentStatus: status),
                  const SizedBox(height: 24),
                  // Restaurant Info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.restaurant,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurantName,
                                style: AppTextStyles.subheading1,
                              ),
                              if (deliveryAddress != null) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        deliveryAddress!,
                                        style: AppTextStyles.bodySmallWithColor(
                                          AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.phone, color: AppColors.primary),
                          onPressed: () {
                            // TODO: Call restaurant
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Order Items
                  Text(
                    'Order Items',
                    style: AppTextStyles.subheading2,
                  ),
                  const SizedBox(height: 12),
                  ...items.map((item) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            if (item['image'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: item['image'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] ?? '',
                                    style: AppTextStyles.bodyMedium,
                                  ),
                                  Text(
                                    'Quantity: ${item['quantity'] ?? 1}',
                                    style: AppTextStyles.bodySmallWithColor(
                                      AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              CurrencyFormatter.format(
                                (item['price'] ?? 0.0) * (item['quantity'] ?? 1),
                              ),
                              style: AppTextStyles.subheading2,
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                  // Total
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: AppTextStyles.heading2,
                        ),
                        Text(
                          CurrencyFormatter.format(totalAmount),
                          style: AppTextStyles.heading2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Action Button
          if (status == 'delivered')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: CleanButton(
                label: 'Rate Order',
                icon: Icons.star,
                onPressed: () {
                  // TODO: Navigate to rating screen
                },
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'preparing':
        return AppColors.info;
      case 'ready':
        return AppColors.success;
      case 'delivered':
        return AppColors.success;
      case 'cancelled':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.assignment_turned_in;
      case 'delivered':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  String _getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Order Placed';
      case 'preparing':
        return 'Order in preparation';
      case 'ready':
        return 'Ready for Delivery';
      case 'delivered':
        return 'Order Delivered';
      case 'cancelled':
        return 'Order Cancelled';
      default:
        return status.toUpperCase();
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Your order has been confirmed';
      case 'preparing':
        return 'Your food is being prepared';
      case 'ready':
        return 'Your order is ready for pickup';
      case 'delivered':
        return 'Your order has been delivered';
      case 'cancelled':
        return 'This order has been cancelled';
      default:
        return 'Order status: $status';
    }
  }
}

class _ProgressSteps extends StatelessWidget {
  final String currentStatus;

  const _ProgressSteps({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final steps = [
      {'label': 'Order Placed', 'status': 'confirmed'},
      {'label': 'Preparing', 'status': 'preparing'},
      {'label': 'Ready', 'status': 'ready'},
      {'label': 'Delivered', 'status': 'delivered'},
    ];

    int currentIndex = steps.indexWhere(
      (step) => step['status'] == currentStatus.toLowerCase(),
    );
    if (currentIndex == -1) currentIndex = 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.asMap().entries.map((entry) {
              final index = entry.key;
              final isCompleted = index <= currentIndex;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.border,
                        shape: BoxShape.circle,
                      ),
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: AppColors.textOnPrimary,
                              size: 18,
                            )
                          : null,
                    ),
                    if (index < steps.length - 1)
                      Container(
                        height: 2,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        color: index < currentIndex
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.map((step) {
              return Expanded(
                child: Text(
                  step['label']!,
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

