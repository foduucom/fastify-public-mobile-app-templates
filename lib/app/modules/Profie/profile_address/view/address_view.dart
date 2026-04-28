import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/address_controlle.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

class AddressView extends GetView<AddressController> {
  const AddressView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Saved Addresses', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: HelperFunctions().loadingIndicator());
        }

        if (controller.addressList.isEmpty) {
          return _buildEmptyState(context, colorScheme, textTheme);
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAddresses,
          child: ListView.separated(
            padding: const EdgeInsets.all(16.0).copyWith(bottom: 100),
            itemCount: controller.addressList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final address = controller.addressList[index];
              return _AddressCard(
                address: address,
                controller: controller,
              );
            },
          ),
        );
      }),
      // Add New Address Button at the bottom
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: SafeArea(
          child: AppButton(
            itemText: '+ Add New Address',
            keypressEvent: () {
              // Navigate to your Add Address screen where you will
              // collect the form data and call controller.addAddress(formData)
              Get.toNamed(Routes.ADDRESS_FORM);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_outlined, size: 80, color: colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              'No Saved Addresses',
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Add a delivery address so you can checkout quickly next time.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final Map<String, dynamic> address;
  final AddressController controller;

  const _AddressCard({required this.address, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final isDefault = address['is_default'] == true;
    final name = address['name'] ?? 'Unknown';
    final mobile = address['mobile'] ?? '';
    final type = (address['type'] ?? 'Address').toString().toUpperCase();

    // Safely extract the ID
    final addressId = (address['_id'] ?? address['id'])?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
          width: isDefault ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header: Name & Badges ──
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (isDefault)
                Container(
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'DEFAULT',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  type,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── Address Text ──
          Text(
            controller.getFormattedAddress(address),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // ── Mobile Number ──
          if (mobile.isNotEmpty)
            Text(
              'Mobile: $mobile',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          // ── Action Buttons ──
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  // Edit Action - Optionally pass addressId to the edit screen
                },
                child: Text('Edit', style: TextStyle(color: colorScheme.primary)),
              ),
              TextButton(
                onPressed: () {
                  // Show confirmation dialog before deleting
                  Get.defaultDialog(
                    title: "Delete Address",
                    middleText: "Are you sure you want to remove this address?",
                    textConfirm: "Delete",
                    textCancel: "Cancel",
                    confirmTextColor: Colors.white,
                    buttonColor: colorScheme.error,
                    cancelTextColor: colorScheme.primary,
                    onConfirm: () {
                      Get.back(); // Close dialog
                      if (addressId.isNotEmpty) {
                        controller.removeAddress(addressId); // Trigger API
                      }
                    },
                  );
                },
                child: Text('Delete', style: TextStyle(color: colorScheme.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}