import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/admin_colors.dart';
import '../../services/admin_api_service.dart';
import '../restaurants/restaurant_list_screen.dart';
import '../orders/order_list_screen.dart';
import '../users/user_list_screen.dart';
import '../coupons/coupon_list_screen.dart';
import '../analytics/analytics_dashboard_screen.dart';
import '../auth/admin_login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AdminApiService apiService;

  const AdminDashboardScreen({super.key, required this.apiService});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;
  Map<String, dynamic>? _dashboardStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() => _isLoading = true);
    final result = await widget.apiService.getDashboardStats();
    if (result['success'] == true) {
      setState(() {
        _dashboardStats = result['data'];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _handleLogout() async {
    await widget.apiService.clearToken();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => AdminLoginScreen(apiService: widget.apiService),
        ),
      );
    }
  }

  Widget _buildDashboard() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final stats = _dashboardStats ?? {};
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: GoogleFonts.inter(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Users',
                  value: '${stats['totalUsers'] ?? 0}',
                  icon: Icons.people,
                  color: AdminColors.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Total Restaurants',
                  value: '${stats['totalRestaurants'] ?? 0}',
                  icon: Icons.restaurant,
                  color: AdminColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Total Orders',
                  value: '${stats['totalOrders'] ?? 0}',
                  icon: Icons.shopping_cart,
                  color: AdminColors.info,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatCard(
                  title: 'Total Revenue',
                  value: '₹${(stats['totalRevenue'] ?? 0).toStringAsFixed(0)}',
                  icon: Icons.currency_rupee,
                  color: AdminColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            'Recent Orders',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AdminColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Order #')),
                DataColumn(label: Text('User')),
                DataColumn(label: Text('Amount')),
                DataColumn(label: Text('Status')),
              ],
              rows: (stats['recentOrders'] as List? ?? []).take(5).map((order) {
                return DataRow(
                  cells: [
                    DataCell(Text(order['orderNumber'] ?? '')),
                    DataCell(Text('User ${order['userId']}')),
                    DataCell(Text('₹${order['finalAmount']?.toStringAsFixed(2) ?? '0.00'}')),
                    DataCell(
                      Chip(
                        label: Text(order['status'] ?? ''),
                        backgroundColor: _getStatusColor(order['status']),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
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
    final screens = [
      _buildDashboard(),
      RestaurantListScreen(apiService: widget.apiService),
      OrderListScreen(apiService: widget.apiService),
      UserListScreen(apiService: widget.apiService),
      CouponListScreen(apiService: widget.apiService),
      AnalyticsDashboardScreen(apiService: widget.apiService),
    ];

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.restaurant_outlined),
                selectedIcon: Icon(Icons.restaurant),
                label: Text('Restaurants'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.shopping_cart_outlined),
                selectedIcon: Icon(Icons.shopping_cart),
                label: Text('Orders'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outlined),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.local_offer_outlined),
                selectedIcon: Icon(Icons.local_offer),
                label: Text('Coupons'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Analytics'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  title: Text(
                    'Admin Panel',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: _handleLogout,
                      tooltip: 'Logout',
                    ),
                  ],
                ),
                Expanded(child: screens[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AdminColors.textSecondary,
                  ),
                ),
                Icon(icon, color: color, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AdminColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

