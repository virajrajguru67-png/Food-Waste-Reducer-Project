import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../core/theme/admin_colors.dart';
import '../../services/admin_api_service.dart';

class RestaurantListScreen extends StatefulWidget {
  final AdminApiService apiService;

  const RestaurantListScreen({super.key, required this.apiService});

  @override
  State<RestaurantListScreen> createState() => _RestaurantListScreenState();
}

class _RestaurantListScreenState extends State<RestaurantListScreen> {
  List<dynamic> _restaurants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() => _isLoading = true);
    final result = await widget.apiService.getRestaurants();
    if (result['success'] == true) {
      setState(() {
        _restaurants = result['data'] ?? [];
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Restaurants',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add),
                label: const Text('Add Restaurant'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Card(
              child: DataTable2(
                columns: [
                  DataColumn2(label: Text('Name')),
                  DataColumn2(label: Text('Category')),
                  DataColumn2(label: Text('Status')),
                  DataColumn2(label: Text('Verified')),
                  DataColumn2(label: Text('Rating')),
                  DataColumn2(label: Text('Actions')),
                ],
                rows: _restaurants.map((restaurant) {
                  return DataRow2(
                    cells: [
                      DataCell(Text(restaurant['name'] ?? '')),
                      DataCell(Text(restaurant['category'] ?? '')),
                      DataCell(Chip(
                        label: Text(restaurant['status'] ?? ''),
                        backgroundColor: AdminColors.info,
                      )),
                      DataCell(
                        Icon(
                          restaurant['verified'] == true
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: restaurant['verified'] == true
                              ? AdminColors.success
                              : AdminColors.error,
                        ),
                      ),
                      DataCell(Text('${restaurant['rating'] ?? 0.0}')),
                      DataCell(
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {},
                            ),
                            IconButton(
                              icon: Icon(
                                restaurant['verified'] == true
                                    ? Icons.verified
                                    : Icons.verified_user,
                              ),
                              onPressed: () async {
                                await widget.apiService.verifyRestaurant(
                                  restaurant['id'],
                                  !(restaurant['verified'] == true),
                                );
                                _loadRestaurants();
                              },
                            ),
                          ],
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

