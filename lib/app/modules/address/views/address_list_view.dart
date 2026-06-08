import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/buttons/bottombutton.dart';
import 'package:get/get.dart';
import '../controllers/address_list_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

class AddressListView extends GetView<AddressListController> {
  const AddressListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("AddressListView build called");
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Addresses',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: controller.refreshAddresses,
            ),
          ],
        ),
        body: Obx(() {
          // ✅ Ensure Obx tracks changes to the list content even if length stays same
          final _ = controller.userAddressList.length;

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
                        ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: controller.userAddressList.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            final userAddress =
                                controller.userAddressList[index];

                            // ✅ Consistent ID extraction matching controller logic
                            final addressId = (userAddress['_id'] ??
                                    userAddress['id'] ??
                                    userAddress['temp_id'] ??
                                    "addr_$index")
                                .toString();

                            return Obx(() {
                              final isSelected =
                                  controller.selectAddressId.value == addressId;

                              return Padding(
                                key: ValueKey("item_$addressId"),
                                padding: const EdgeInsets.only(bottom: 15),
                                child: GestureDetector(
                                  // ✅ Using GestureDetector with opaque behavior for maximum coverage
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    print(
                                        "Card gesture detected for ID: $addressId");
                                    controller.selectNewAddress(addressId);
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8.0),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                                  .withOpacity(0.05)
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceVariant
                                                  .withOpacity(0.25),
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
                                            width: isSelected ? 1.5 : 0.9,
                                          ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? Theme.of(context)
                                                            .colorScheme
                                                            .primary
                                                        : Theme.of(context)
                                                            .colorScheme
                                                            .outline,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: isSelected
                                                    ? Center(
                                                        child: Container(
                                                          width: 10,
                                                          height: 10,
                                                          decoration:
                                                              BoxDecoration(
                                                            shape:
                                                                BoxShape.circle,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                          ),
                                                        ),
                                                      )
                                                    : null,
                                              ),
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
                                                          color:
                                                              Theme.of(context)
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
                                                            userAddress[
                                                                    'street']
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
                                                          userAddress[
                                                              'landmark'],
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
                                                                    'state'] !=
                                                                null)
                                                              (userAddress[
                                                                          'state']
                                                                      is Map
                                                                  ? userAddress[
                                                                          'state']
                                                                      ['name']
                                                                  : userAddress[
                                                                      'state']),
                                                            if (userAddress[
                                                                    'country'] !=
                                                                null)
                                                              (userAddress[
                                                                          'country']
                                                                      is Map
                                                                  ? userAddress[
                                                                          'country']
                                                                      ['name']
                                                                  : userAddress[
                                                                      'country']),
                                                          ]
                                                              .where((e) =>
                                                                  e != null &&
                                                                  e
                                                                      .toString()
                                                                      .isNotEmpty)
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
                                                          color:
                                                              Theme.of(context)
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
                                                          "Edit",
                                                          () async {
                                                            var result =
                                                                await Get
                                                                    .toNamed(
                                                              Routes
                                                                  .ADDRESS_FORM,
                                                              arguments: {
                                                                'isEdit': true,
                                                                'address':
                                                                    userAddress,
                                                              },
                                                            );
                                                            if (result ==
                                                                true) {
                                                              controller
                                                                  .refreshAddresses();
                                                            }
                                                          },
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primary,
                                                        ),
                                                        const SizedBox(
                                                            width: 15),
                                                        _buildActionButton(
                                                          "Remove",
                                                          () =>
                                                              _showDeleteDialog(
                                                            context,
                                                            userAddress['_id']
                                                                .toString(),
                                                            index,
                                                          ),
                                                          color:
                                                              Theme.of(context)
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
                                                            const EdgeInsets
                                                                .only(top: 10),
                                                        child: Row(
                                                          children: [
                                                            SvgPicture.asset(
                                                              "assets/images/trucknew.svg",
                                                              height: 16,
                                                              colorFilter:
                                                                  ColorFilter
                                                                      .mode(
                                                                Theme.of(
                                                                        context)
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
                                      // Positioned badges are still there, they will receive taps if clicked
                                      // but they are small so it's fine.
                                    ],
                                  ),
                                ),
                              );
                            });
                          },
                        ),
                      const SizedBox(height: 20),
                      AppButton(
                        keypressEvent: () async {
                          var result = await Get.toNamed(Routes.ADDRESS_FORM);
                          if (result == true) {
                            controller.refreshAddresses();
                          }
                        },
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

  Widget _buildActionButton(String label, VoidCallback onTap, {Color? color}) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: color ?? Colors.black87,
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
        content: const Text("Are you sure you want to remove this address?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.removeAddress(id, index);
            },
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
