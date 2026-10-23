import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zouhi/app/modules/address/controllers/address_controller.dart';
import 'package:zouhi/app/modules/address/views/addupdateAddress_view.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/buttons/bottombutton.dart';
import 'package:zouhi/components/buttons/outlinebutton.dart';
import 'package:zouhi/components/deliveryproduct.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';

import 'package:get/get.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';

class DeliveryDetialView extends GetView<AddressController> {
  DeliveryDetialView({Key? key}) : super(key: key);

  final _addressController =
      Get.lazyPut<AddressController>(() => AddressController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery Details',
                  style: txtTheme().headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                      color: context.themeTextColor)),
              Text('Step 2 of 3',
                  style: txtTheme().headlineSmall!.copyWith(
                      fontSize: 12,
                      color: context.themeSecondrytext))
            ],
          ),
          iconTheme: IconThemeData(
            color: context.themeTextColor,
          ),
          // backgroundColor: Colors.red,
          elevation: 0,
        ),
        body: Obx(
          () {
            return controller.isLoading.value
                ? HelperFunctions().loadingIndicator()
                : Stack(
                    children: [
                      Positioned(
                        top: 0,
                        bottom: 0,
                        right: 0,
                        left: 0,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ManageAddress(controller: controller),
                              Divider(
                                thickness: 10,
                                color: context.themegreyColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Obx(
                        () {
                          var cartController = Get.find<CartController>();
                          String symbol = currency;
                          if (Get.isRegistered<CurrencyController>()) {
                            symbol = Get.find<CurrencyController>()
                                    .selectedCurrency['symbol']
                                    ?.toString() ??
                                currency;
                          }
                          bool isBtnDisabled =
                              controller.userAddressList.isEmpty ||
                                  !controller.isShippingAvailable.value;
                          return bottomButton(
                            // totalAmount: cartController.viewTotalAmount.value,
                            totalAmount: ((double.tryParse(cartController
                                        .viewTotalAmount.value
                                        .toString()
                                        .trim()) ??
                                    0.0))
                                .toString(),
                            //deliveryAmount: 'Calculated On Checkout',
                            opacity: isBtnDisabled ? 0.5 : 1,
                            buttonText: 'payment',
                            priceText: ((double.tryParse(cartController
                                        .viewTotalAmount.value
                                        .toString()
                                        .trim()) ??
                                    0.0))
                                .toString(),
                            currencySymbol: symbol,
                            keypressEvent: isBtnDisabled
                                ? null
                                : () {
                                    Get.toNamed(Routes.PAYMENT, arguments: {
                                      'shippingCharge':
                                          controller.shippingCharges
                                    });
                                  },
                            otherText: 'View details',
                          );
                        },
                      )
                    ],
                  );
          },
        ),
      ),
    );
  }
}

class ManageAddress extends StatelessWidget {
  const ManageAddress({
    Key? key,
    required this.controller,
  }) : super(key: key);

  final AddressController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: pageSurroundingPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GetBuilder<AddressController>(builder: (controller) {
            return ListView.separated(
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 15),
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.userAddressList.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  var userAddress = controller.userAddressList[index];
                  return Obx(() {
                    return GestureDetector(
                      onTap: () {
                        print('click on addresss');
                        controller.isShippingAvailable.value = true;
                        // HelperFunctions().showOverlayLoader();
                        controller.selectAddress.value = index;
                        // controller.checkShipping().then((value) =>
                        //     Get.until((route) => !Get.isDialogOpen!));
                      },
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                color: controller.selectAddress.value == index
                                    ? context.themeRedColor.withOpacity(0.05)
                                    : context.themegreyColor.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                    color:
                                        controller.selectAddress.value == index
                                            ? context.themeRedColor
                                            : context.themegreyColor,
                                    width: 0.9),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AbsorbPointer(
                                      absorbing: true,
                                      child: Radio(
                                          activeColor: context.themeRedColor,
                                          value: index,
                                          groupValue:
                                              controller.selectAddress.value,
                                          onChanged: (value) {
                                            // controller.selectAddress.value =
                                            //     int.parse(value.toString());
                                          }),
                                    ),
                                    // Container(

                                    // const SizedBox(width: 7.0),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            8, 10, 8, 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                      userAddress['name']
                                                          .toString()
                                                          .capitalizeFirst
                                                          .toString(),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 18)),
                                                ),
                                                // FIX 1: Wrap the address type in a Container with background color
                                                if (((userAddress['address_type'] ?? userAddress['type'])
                                                            ?.toString() ??
                                                        '')
                                                    .isNotEmpty)
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: context.themeRedColor
                                                          .withOpacity(
                                                              0.1), // Light red background
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                    ),
                                                    child: Text(
                                                      ((userAddress['address_type'] ?? userAddress['type'])
                                                                  ?.toString() ??
                                                              '')
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: context.themeRedColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                        letterSpacing: 1,
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                                [
                                                  if (userAddress['house_no'] !=
                                                          null &&
                                                      userAddress['house_no']
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty)
                                                    userAddress['house_no']
                                                        .toString()
                                                        .trim(),
                                                  if (userAddress['street'] !=
                                                          null &&
                                                      userAddress['street']
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty)
                                                    userAddress['street']
                                                        .toString()
                                                        .trim()
                                                  else if (userAddress[
                                                              'address'] !=
                                                          null &&
                                                      userAddress['address']
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty)
                                                    userAddress['address']
                                                        .toString()
                                                        .trim(),
                                                  if (userAddress['landmark'] !=
                                                          null &&
                                                      userAddress['landmark']
                                                          .toString()
                                                          .trim()
                                                          .isNotEmpty)
                                                    userAddress['landmark']
                                                        .toString()
                                                        .trim(),
                                                ].join(', '),
                                                style: TextStyle(
                                                    color: context.themeTextColor,
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14),
                                                maxLines: 3,
                                                overflow:
                                                    TextOverflow.ellipsis),

                                            // Only show City, State, Country if present
                                            if (userAddress['city'] is Map ||
                                                (userAddress['city'] != null &&
                                                    userAddress['city']
                                                        .toString()
                                                        .trim()
                                                        .isNotEmpty) ||
                                                userAddress['state'] is Map ||
                                                userAddress['country']
                                                    is Map) ...[
                                              const SizedBox(height: 2),
                                              Text(
                                                  [
                                                    if (userAddress['city'] !=
                                                            null &&
                                                        userAddress['city']
                                                            .toString()
                                                            .trim()
                                                            .isNotEmpty)
                                                      userAddress['city'] is Map
                                                          ? userAddress['city']
                                                                  ['name']
                                                              ?.toString()
                                                              .trim()
                                                          : userAddress['city']
                                                              .toString()
                                                              .trim(),
                                                    if (userAddress['state']
                                                        is Map)
                                                      userAddress['state']
                                                              ['name']
                                                          ?.toString()
                                                          .trim(),
                                                    if (userAddress['country']
                                                        is Map)
                                                      userAddress['country']
                                                              ['name']
                                                          ?.toString()
                                                          .trim(),
                                                  ]
                                                      .where((element) =>
                                                          element != null &&
                                                          element.isNotEmpty)
                                                      .join(', '),
                                                  style: TextStyle(
                                                      color: context.themeTextColor,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontSize: 14)),
                                            ],

                                            const SizedBox(height: 6),
                                            // Pincode row with icon
                                            if ((userAddress['postal_code'] ??
                                                    userAddress['pincode'] ??
                                                    '')
                                                .toString()
                                                .isNotEmpty)
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_pin,
                                                    size: 14,
                                                    color: context.themeSecondrytext,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      "${userAddress['postal_code'] ?? userAddress['pincode'] ?? ''}"
                                                          .trim(),
                                                      style: TextStyle(
                                                          color:
                                                              context.themeSecondrytext,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 13),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            const SizedBox(height: 4),
                                            // Phone row with icon
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.phone_outlined,
                                                  size: 14,
                                                  color: context.themeSecondrytext,
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    userAddress['mobile']
                                                            ?.toString() ??
                                                        '',
                                                    style: TextStyle(
                                                        color:
                                                            context.themeSecondrytext,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 13),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    // removeItemModel() {
                                                    Get.dialog(
                                                      barrierDismissible: false,
                                                      AlertDialog(
                                                        actionsPadding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                    vertical: 5,
                                                                    horizontal:
                                                                        10)
                                                                .copyWith(
                                                                    top: 0),
                                                        content: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Text(
                                                              'Remove Address',
                                                              style: txtTheme()
                                                                  .headlineMedium,
                                                            ),
                                                            Text(
                                                              "Are you sure you want to remove Address",
                                                              style: txtTheme()
                                                                  .headlineSmall!
                                                                  .copyWith(
                                                                      color:
                                                                          context.themeSecondrytext),
                                                            ),
                                                          ],
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () {
                                                              // Add logic for going back
                                                              Get.back();
                                                            },
                                                            child: Text(
                                                              'Back',
                                                              style: TextStyle(
                                                                  color: context
                                                                      .themeSecondrytext),
                                                            ),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              controller.removeAddress(
                                                                  id: userAddress[
                                                                      '_id'],
                                                                  index: index);
                                                              Get.back();
                                                            },
                                                            child: Text(
                                                              'Remove',
                                                              style: TextStyle(
                                                                  color:
                                                                      context.themeRedColor),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: context.themeWhiteColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          'Remove'
                                                              .toUpperCase(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'lato',
                                                              color:
                                                                  context.themeTextColor)),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                GestureDetector(
                                                  onTap: () async {
                                                    HelperFunctions()
                                                        .showOverlayLoader();
                                                    controller.isUpdateAddress =
                                                        true;

                                                    controller.isStateChange
                                                        .value = false;
                                                    controller.isCountryChange
                                                        .value = false;
                                                    // controller.getAddressbyId(id: userAddress['_id']).then((value) => Get.to(AddressView()));
                                                    controller.name.text =
                                                        userAddress['name']
                                                                ?.toString() ??
                                                            '';
                                                    controller.email.text =
                                                        userAddress['email']
                                                                ?.toString() ??
                                                            '';
                                                    controller
                                                            .mobileNumber.text =
                                                        userAddress['mobile']
                                                                ?.toString() ??
                                                            '';
                                                    controller.landmark.text =
                                                        userAddress['landmark']
                                                                ?.toString() ??
                                                            '';
                                                    controller.area
                                                        .text = (userAddress[
                                                                'street'] ??
                                                            userAddress[
                                                                'address'] ??
                                                            '')
                                                        .toString();
                                                    controller.flat.text =
                                                        userAddress['house_no']
                                                                ?.toString() ??
                                                            '';
                                                    controller.pinCode
                                                        .text = (userAddress[
                                                                'postal_code'] ??
                                                            userAddress[
                                                                'pincode'] ??
                                                            '')
                                                        .toString();

                                                    controller.setRegionsFromAddress(
                                                        userAddress);
                                                    controller.selectedCity
                                                        .value = userAddress[
                                                            'city'] is Map
                                                        ? userAddress['city']
                                                                ['name']
                                                            ?.toString()
                                                        : null;

                                                    controller.isUpdateAddress =
                                                        true;
                                                    controller.updateAddressId =
                                                        userAddress['_id'];

                                                    // String stateId = userAddress[
                                                    //         'state'] is Map
                                                    //     ? userAddress['state']
                                                    //                 ['_id']
                                                    //             ?.toString() ??
                                                    //         ''
                                                    //     : userAddress['state']
                                                    //             ?.toString() ??
                                                    //         '';

                                                    // Cities API call commented out
                                                    // if (stateId.isNotEmpty) {
                                                    //   await controller.getCity(
                                                    //       id: stateId);
                                                    // }

                                                    controller.city
                                                        .text = userAddress[
                                                            'city'] is Map
                                                        ? (userAddress['city']
                                                                    ['name']
                                                                ?.toString() ??
                                                            '')
                                                        : (userAddress['city']
                                                                ?.toString() ??
                                                            '');

                                                    controller.selectAddressType
                                                        .value = userAddress[
                                                                'address_type']
                                                            ?.toString() ??
                                                        'Home';
                                                    controller.selectDefaultAdd
                                                            .value =
                                                        AddressController
                                                            .isDefaultFlag(
                                                                userAddress[
                                                                    'is_default']);

                                                    Get.until((route) =>
                                                        !Get.isDialogOpen!);
                                                    Get.to(AddUpdateAddress());

                                                    // Get.to(AddressView());
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: context.themeWhiteColor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              6.0),
                                                      child: Text(
                                                          'Edit'.toUpperCase(),
                                                          style: TextStyle(
                                                              fontFamily:
                                                                  'lato',
                                                              color:
                                                                  context.themeTextColor)),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            if (!controller.isShippingAvailable
                                                    .value &&
                                                controller
                                                        .selectAddress.value ==
                                                    index)
                                              Row(
                                                children: [
                                                  SvgPicture.asset(
                                                    "assets/images/trucknew.svg",
                                                    color: Colors.red,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Column(
                                                    children: [
                                                      Text(
                                                        "Shipping not available at this address!"
                                                            .tr,
                                                        softWrap: true,
                                                        maxLines: 2,
                                                        style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.red),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  });
                });
          }),
          outLineButton(
            backgroundColor: context.themeRedColor,
            pressEvent: () {
              controller.isUpdateAddress = false;

              controller.name.text = '';
              controller.mobileNumber.text = '';
              controller.pinCode.text = '';
              controller.flat.text = '';
              controller.email.text = '';
              controller.area.text = '';
              controller.landmark.text = '';
              controller.city.text = '';
              controller.selectedCity.value = null;
              controller.clearRegions();
              controller.cityList.value = [];
              controller.selectAddressType.value = 'Home';
              controller.selectDefaultAdd.value = false;

              // Pre-populate fields from profile data
              controller.setDefaultUserData();

              controller
                  .getCountry()
                  .then((value) => Get.toNamed(Routes.ADD_UPDATE_ADDRESS));
              // Get.toNamed(Routes.ADD_UPDATE_ADDRESS);
            },
            buttonText: 'add New address',
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
