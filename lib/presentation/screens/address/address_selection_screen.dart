import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../widgets/clean_button.dart';
import '../../widgets/clean_search_bar.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedAddress;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Delivery Address'),
        backgroundColor: AppColors.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: CleanSearchBar(
              controller: _searchController,
              hintText: 'Street address or zip code',
            ),
          ),
          // Use Current Location
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () {
                // TODO: Get current location
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.my_location,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Use my current location',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          // Saved Addresses
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _AddressItem(
                  label: 'My Home',
                  address: '3000 Dublin Constitution Dr, Livermore, United States',
                  isSelected: _selectedAddress == 'home',
                  onTap: () {
                    setState(() => _selectedAddress = 'home');
                  },
                ),
                const SizedBox(height: 12),
                _AddressItem(
                  label: 'My Office',
                  address: '123 Main Street, San Francisco, CA 94102',
                  isSelected: _selectedAddress == 'office',
                  onTap: () {
                    setState(() => _selectedAddress = 'office');
                  },
                ),
                const SizedBox(height: 12),
                _AddNewAddressItem(
                  onTap: () {
                    // TODO: Navigate to add address screen
                  },
                ),
              ],
            ),
          ),
          // Confirm Button
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
              label: 'Confirm Location',
              onPressed: _selectedAddress != null
                  ? () {
                      Navigator.pop(context, _selectedAddress);
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressItem extends StatelessWidget {
  final String label;
  final String address;
  final bool isSelected;
  final VoidCallback onTap;

  const _AddressItem({
    required this.label,
    required this.address,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.home,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.subheading2.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: AppTextStyles.bodySmallWithColor(
                      AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}

class _AddNewAddressItem extends StatelessWidget {
  final VoidCallback onTap;

  const _AddNewAddressItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Text(
              'Add New Location',
              style: AppTextStyles.subheading2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

