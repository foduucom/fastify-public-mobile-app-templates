import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../components/app_bar.dart';
import '/components/buttons/appbutton.dart';
import '/components/buttons/bottombutton.dart';
import 'package:get/get.dart';
import '../controllers/address_list_controller.dart';
import '/app/routes/app_pages.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';

class AddressListView extends GetView<AddressListController> {
  const AddressListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // ✅ REMOVED debug FAB — was causing Hero tag conflict
        // appBar: AppBar(
        //   title: const Text(
        //     'Addresses',
        //     style: TextStyle(fontWeight: FontWeight.bold),
        //   ),
        //   elevation: 0,
        //   actions: [
        //     IconButton(
        //       icon: const Icon(Icons.refresh),
        //       onPressed: controller.refreshAddresses,
        //     ),
        //   ],
        // ),
        appBar:  CustomAppBar(title: 'Addresses',),
        body: Obx(() {
          if (controller.isLoading.value &&
              controller.userAddressList.isEmpty) {
            return HelperFunctions().loadingIndicator();
          }

          return Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  padding: pageSurroundingPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (controller.userAddressList.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 50),
                            child: Text(
                                "No addresses found. Please add a new one."),
                          ),
                        )
                      else
                      // ✅ FIXED: Obx wraps each item so selectAddress
                      //    change actually rebuilds the radio + border
                        ListView.separated(
                          separatorBuilder: (_, __) =>
                          const SizedBox(height: 15),
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.userAddressList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final userAddress =
                            controller.userAddressList[index];
                            // ✅ Wrap each card in Obx so selection reacts
                            return Obx(() {
                              final isSelected =
                                  controller.selectAddress.value == index;
                              return GestureDetector(
                                onTap: () =>
                                    controller.selectNewAddress(index),
                                child: Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.05)
                                            : Theme.of(context)
                                            .colorScheme
                                            .surfaceVariant
                                            .withValues(alpha: 0.25),
                                        borderRadius:
                                        BorderRadius.circular(3),
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                              : Theme.of(context)
                                              .colorScheme
                                              .outline,
                                          width: 0.9,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Radio(
                                            value: index,
                                            groupValue:
                                            controller.selectAddress.value,
                                            activeColor: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            onChanged: (_) =>
                                                controller
                                                    .selectNewAddress(index),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                                children: [
                                                  // ── Name ──────────
                                                  if (userAddress['name'] !=
                                                      null)
                                                    Text(
                                                      userAddress['name']
                                                          .toString()
                                                          .capitalizeFirst ??
                                                          '',
                                                      style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),
                                                  if (userAddress['name'] !=
                                                      null)
                                                    const SizedBox(height: 4),

                                                  // ── Street ────────
                                                  Text(
                                                    [
                                                      if (userAddress[
                                                      'street'] !=
                                                          null &&
                                                          userAddress['street']
                                                              .toString()
                                                              .isNotEmpty)
                                                        userAddress['street'],
                                                      if (userAddress[
                                                      'landmark'] !=
                                                          null &&
                                                          userAddress[
                                                          'landmark']
                                                              .toString()
                                                              .isNotEmpty)
                                                        userAddress['landmark'],
                                                    ].join(', '),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurface,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),

                                                  // ── City/State ────
                                                  Text(
                                                    [
                                                      if (userAddress[
                                                      'city'] !=
                                                          null)
                                                        (userAddress[
                                                        'city']
                                                        is Map
                                                            ? userAddress[
                                                        'city']
                                                        ['name']
                                                            : userAddress[
                                                        'city']),
                                                      if (userAddress[
                                                      'state']
                                                      ?['name'] !=
                                                          null)
                                                        userAddress['state']
                                                        ['name'],
                                                      if (userAddress[
                                                      'country']
                                                      ?['name'] !=
                                                          null)
                                                        userAddress[
                                                        'country']
                                                        ['name'],
                                                    ]
                                                        .where(
                                                            (e) => e != null)
                                                        .join(', ') +
                                                        (userAddress[
                                                        'postal_code'] !=
                                                            null
                                                            ? ' - ${userAddress['postal_code']}'
                                                            : (userAddress[
                                                        'pincode'] !=
                                                            null
                                                            ? ' - ${userAddress['pincode']}'
                                                            : '')),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onSurfaceVariant,
                                                    ),
                                                  ),

                                                  // ── Phone ─────────
                                                  if (userAddress['mobile'] !=
                                                      null) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Phone: ${userAddress['mobile']}',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface,
                                                      ),
                                                    ),
                                                  ],
                                                  const SizedBox(height: 12),

                                                  // ── Edit / Remove ─
                                                  Row(
                                                    children: [
                                                      _buildActionButton(
                                                        context,
                                                        "Edit",
                                                            () => Get.toNamed(
                                                          Routes.ADDRESS_FORM,
                                                          arguments: {
                                                            'isEdit': true,
                                                            'address':
                                                            userAddress,
                                                          },
                                                        ),
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      const SizedBox(width: 15),
                                                      _buildActionButton(
                                                        context,
                                                        "Remove",
                                                            () => _showDeleteDialog(
                                                          context,
                                                          userAddress['_id']
                                                              .toString(),
                                                          index,
                                                        ),
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .error,
                                                      ),
                                                    ],
                                                  ),

                                                  // ── Shipping warning
                                                  if (controller.shippingDetails[
                                                  'is_shipping'] ==
                                                      false &&
                                                      isSelected)
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                          top: 10),
                                                      child: Row(
                                                        children: [
                                                          SvgPicture.asset(
                                                            "assets/images/trucknew.svg",
                                                            height: 16,
                                                            colorFilter:
                                                            ColorFilter.mode(
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .error,
                                                              BlendMode.srcIn,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 10),
                                                          Text(
                                                            "Shipping not available at this address!",
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Theme.of(
                                                                  context)
                                                                  .colorScheme
                                                                  .error,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // ── DEFAULT / TYPE badges ──────────
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Row(
                                        children: [
                                          if (userAddress['is_default'] == true)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  right: 8),
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                    .withValues(alpha: 0.1),
                                                borderRadius:
                                                BorderRadius.circular(3),
                                                border: Border.all(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  width: 0.5,
                                                ),
                                              ),
                                              child: Text(
                                                'DEFAULT',
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          if ((userAddress['type'] ??
                                              userAddress[
                                              'address_type']) !=
                                              null)
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                borderRadius:
                                                BorderRadius.circular(3),
                                              ),
                                              child: Text(
                                                (userAddress['type'] ??
                                                    userAddress[
                                                    'address_type'])
                                                    .toString()
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                          },
                        ),
                      const SizedBox(height: 20),
                      AppButton(
                        keypressEvent: () => Get.toNamed(Routes.ADDRESS_FORM),
                        itemText: 'Add New Address',
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // ── Bottom Continue Button ────────────────────────────
              Obx(() => bottomButton(
                buttonText: 'Continue',
                priceText: controller.total.value.toStringAsFixed(2),
                keypressEvent: controller.userAddressList.isEmpty
                    ? null
                    : () => Get.toNamed(Routes.PAYMENT),
                otherText: 'Details',
                opacity: controller.userAddressList.isEmpty ? 0.5 : 1,
                deliveryAmount: '0',
              )),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, VoidCallback onTap,
      {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color ?? Theme.of(context).colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id, int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Address'),
        content:
        const Text("Are you sure you want to remove this address?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeAddress(id, index);
            },
            child: Text('Remove',
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }
}
