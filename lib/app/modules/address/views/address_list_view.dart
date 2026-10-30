import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '/components/buttons/bottombutton.dart';
import '/components/commonWidgets/secondary_app_header.dart';
import '/constants/helper_functions.dart';
import '/app/routes/app_pages.dart';
import '../controllers/address_list_controller.dart';

class AddressListView extends GetView<AddressListController> {
  const AddressListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isSelectMode = Get.arguments?['selectMode'] == true ||
        Get.previousRoute == Routes.CHECKOUT ||
        Get.previousRoute == Routes.CART;

    return SafeArea(
      child: Scaffold(
        appBar: SecondaryAppHeader(
          title: isSelectMode ? 'Select Address' : 'Saved Addresses',
          showRight: true,
          rightIcon: Icons.add,
          onRightIconTap: () async {
            await Get.toNamed(Routes.ADDRESS_FORM);
            controller.refreshAddresses();
          },
        ),
        body: Obx(() {
          if (controller.isLoading.value &&
              controller.userAddressList.isEmpty) {
            return HelperFunctions().loadingIndicator();
          }

          if (controller.userAddressList.isEmpty) {
            return _buildEmptyState(context);
          }

          return Stack(
            children: [
              Positioned.fill(
                child: RefreshIndicator(
                  onRefresh: () => controller.refreshAddresses(),
                  color: colorScheme.primary,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    children: [
                      ListView.separated(
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.userAddressList.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          var userAddress = controller.userAddressList[index];
                          return Obx(() {
                            final isSelected =
                                controller.selectAddress.value == index;

                            return GestureDetector(
                              onTap: () => controller.selectNewAddress(index),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colorScheme.primary.withOpacity(0.06)
                                      : (isDark
                                          ? colorScheme.surfaceVariant
                                              .withOpacity(0.4)
                                          : colorScheme.surface),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? colorScheme.primary
                                        : colorScheme.outline.withOpacity(0.6),
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Header: Radio / Name / Badges
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Radio indicator
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 2, right: 10),
                                          child: SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Radio<int>(
                                              value: index,
                                              groupValue: controller
                                                  .selectAddress.value,
                                              activeColor: colorScheme.primary,
                                              onChanged: (val) {
                                                if (val != null) {
                                                  controller
                                                      .selectNewAddress(val);
                                                }
                                              },
                                            ),
                                          ),
                                        ),

                                        // Recipient Name
                                        Expanded(
                                          child: Text(
                                            (userAddress['name'] ?? '')
                                                    .toString()
                                                    .capitalizeFirst ??
                                                '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                        ),

                                        // Badges: Default / Type
                                        Row(
                                          children: [
                                            if (userAddress['is_default'] ==
                                                    1 ||
                                                userAddress['is_default'] ==
                                                    true)
                                              Container(
                                                margin: const EdgeInsets.only(
                                                    right: 6),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.secondary
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: colorScheme.secondary
                                                        .withOpacity(0.4),
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Text(
                                                  'DEFAULT',
                                                  style: TextStyle(
                                                    color:
                                                        colorScheme.secondary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            if ((userAddress['address_type'] ??
                                                    userAddress['type']) !=
                                                null)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 3,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: colorScheme.primary
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                  border: Border.all(
                                                    color: colorScheme.primary
                                                        .withOpacity(0.4),
                                                    width: 0.8,
                                                  ),
                                                ),
                                                child: Text(
                                                  (userAddress[
                                                              'address_type'] ??
                                                          userAddress['type'])
                                                      .toString()
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    color: colorScheme.primary,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),

                                    // Address lines
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, top: 6),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            [
                                              if (userAddress['street'] !=
                                                      null &&
                                                  userAddress['street']
                                                      .toString()
                                                      .isNotEmpty)
                                                userAddress['street'],
                                              if (userAddress['landmark'] !=
                                                      null &&
                                                  userAddress['landmark']
                                                      .toString()
                                                      .isNotEmpty)
                                                userAddress['landmark'],
                                            ].join(', '),
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.35,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatAddressLocation(userAddress),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          if (userAddress['mobile'] != null &&
                                              userAddress['mobile']
                                                  .toString()
                                                  .isNotEmpty) ...[
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.phone_outlined,
                                                  size: 14,
                                                  color: colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '${userAddress['mobile']}',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],

                                          // Shipping not available warning
                                          if (controller.shippingDetails[
                                                      'is_shipping'] ==
                                                  false &&
                                              index ==
                                                  controller
                                                      .selectAddress.value)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(top: 8),
                                              child: Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/images/trucknew.svg",
                                                    color: colorScheme.error,
                                                    height: 16,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    "Shipping not available at this address!",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: colorScheme.error,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                          const SizedBox(height: 12),
                                          // Action Buttons: Edit / Remove
                                          Row(
                                            children: [
                                              _buildActionButton(
                                                label: "Edit",
                                                icon: Icons.edit_outlined,
                                                onTap: () async {
                                                  await Get.toNamed(
                                                    Routes.ADDRESS_FORM,
                                                    arguments: {
                                                      'isEdit': true,
                                                      'address': userAddress,
                                                    },
                                                  );
                                                  controller.refreshAddresses();
                                                },
                                                color: colorScheme.primary,
                                              ),
                                              const SizedBox(width: 16),
                                              _buildActionButton(
                                                label: "Remove",
                                                icon: Icons.delete_outline,
                                                onTap: () {
                                                  _showDeleteDialog(
                                                    context,
                                                    userAddress['_id'],
                                                    index,
                                                  );
                                                },
                                                color: colorScheme.error,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Outlined Add New Address Button in list
                      OutlinedButton.icon(
                        onPressed: () async {
                          await Get.toNamed(Routes.ADDRESS_FORM);
                          controller.refreshAddresses();
                        },
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          "Add New Address",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          side: BorderSide(
                            color: colorScheme.primary,
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          minimumSize: const Size(double.infinity, 46),
                        ),
                      ),
                      // Spacing for bottom button
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),

              // Bottom button
              bottomButton(
                buttonText: 'Continue',
                priceText: controller.total.toString(),
                keypressEvent: controller.userAddressList.isEmpty
                    ? null
                    : () {
                        // If we came from checkout, return with selection
                        if (Get.previousRoute == Routes.PAYMENT ||
                            Get.previousRoute == Routes.CHECKOUT ||
                            Get.arguments?['selectMode'] == true) {
                          Get.back();
                        } else {
                          Get.toNamed(Routes.PAYMENT);
                        }
                      },
                otherText: 'Details',
                opacity: controller.userAddressList.isEmpty ? 0.5 : 1,
                deliveryAmount: '0',
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.location_off_outlined,
                size: 48,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No Addresses Saved",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add your delivery address to proceed with your orders smoothly.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await Get.toNamed(Routes.ADDRESS_FORM);
                controller.refreshAddresses();
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text("Add New Address"),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAddressLocation(dynamic userAddress) {
    if (userAddress is! Map) return '';

    final parts = <String>[];

    // 1. City
    final city = userAddress['city'];
    if (city != null) {
      if (city is Map) {
        final name = city['name']?.toString().trim();
        if (name != null && name.isNotEmpty) {
          parts.add(name);
        }
      } else if (city is String && city.trim().isNotEmpty) {
        final cityStr = city.trim();
        final cached = controller.cityNamesCache[cityStr];
        if (cached != null && cached.isNotEmpty) {
          parts.add(cached);
        } else if (!RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(cityStr)) {
          // Non-hex string name
          parts.add(cityStr);
        }
      }
    }

    // 2. State
    final state = userAddress['state'];
    if (state != null) {
      if (state is Map) {
        final name = state['name']?.toString().trim();
        if (name != null && name.isNotEmpty) {
          parts.add(name);
        }
      } else if (state is String &&
          state.trim().isNotEmpty &&
          !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(state.trim())) {
        parts.add(state.trim());
      }
    }

    // 3. Country
    final country = userAddress['country'];
    if (country != null) {
      if (country is Map) {
        final name = country['name']?.toString().trim();
        if (name != null && name.isNotEmpty) {
          parts.add(name);
        }
      } else if (country is String &&
          country.trim().isNotEmpty &&
          !RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(country.trim())) {
        parts.add(country.trim());
      }
    }

    final locText = parts.join(', ');
    final postalCode = (userAddress['postal_code'] ?? userAddress['pincode'])
        ?.toString()
        .trim();
    if (postalCode != null && postalCode.isNotEmpty) {
      return locText.isNotEmpty ? '$locText - $postalCode' : postalCode;
    }
    return locText;
  }

  void _showDeleteDialog(BuildContext context, String id, int index) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog(
      AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: Text(
          'Remove Address',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: Text(
          "Are you sure you want to remove this address?",
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.removeAddress(id, index);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Remove',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
