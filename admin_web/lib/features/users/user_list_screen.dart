import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:data_table_2/data_table_2.dart';
import '../../services/admin_api_service.dart';

class UserListScreen extends StatefulWidget {
  final AdminApiService apiService;

  const UserListScreen({super.key, required this.apiService});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final result = await widget.apiService.getUsers();
    if (result['success'] == true) {
      setState(() {
        _users = result['data'] ?? [];
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
          Text(
            'Users',
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
                  DataColumn2(label: Text('ID')),
                  DataColumn2(label: Text('Name')),
                  DataColumn2(label: Text('Email')),
                  DataColumn2(label: Text('Role')),
                  DataColumn2(label: Text('Actions')),
                ],
                rows: _users.map((user) {
                  return DataRow2(
                    cells: [
                      DataCell(Text('${user['id']}')),
                      DataCell(Text(user['name'] ?? '')),
                      DataCell(Text(user['email'] ?? '')),
                      DataCell(
                        DropdownButton<String>(
                          value: user['role'] ?? 'user',
                          items: const [
                            DropdownMenuItem(value: 'user', child: Text('User')),
                            DropdownMenuItem(value: 'admin', child: Text('Admin')),
                            DropdownMenuItem(value: 'restaurant_owner', child: Text('Restaurant Owner')),
                          ],
                          onChanged: (value) async {
                            if (value != null) {
                              await widget.apiService.updateUserRole(
                                user['id'],
                                value,
                              );
                              _loadUsers();
                            }
                          },
                        ),
                      ),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
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

