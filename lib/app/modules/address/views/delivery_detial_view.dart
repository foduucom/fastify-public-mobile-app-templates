import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/address/controllers/address_controller.dart';
import 'package:foduu_ecommerce/app/modules/address/views/addupdateAddress_view.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/bottombutton.dart';
import 'package:foduu_ecommerce/components/buttons/outlinebutton.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';

import 'package:get/get.dart';

class DeliveryDetialView extends GetView<AddressController> {
  DeliveryDetialView({Key? key}) : super(key: key);

  final _addressController =
      Get.lazyPut<AddressController>(() => AddressController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delivery Details',
                  style: txtTheme().headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold, fontFamily: "Lato")),
              Text('Step 2 of 3',
                  style: txtTheme().titleLarge!.copyWith(fontSize: 12))
            ],
          ),
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          // backgroundColor: Colors.red,
          elevation: 0,
        ),
        body: Obx(
          () {
            print(
                '<<<<<<<<<<<<<<<<<<<<<<<${controller.isLoading.value} , ${controller.addressLoading.value}>>>>>>>>>>>>>>>>>>>>>>>');
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
                              const Divider(
                                thickness: 10,
                                // color: themegreyColor,
                              ),
                              // Padding(
                              //   padding: pageSurroundingPadding,
                              //   child: Column(
                              //     crossAxisAlignment: CrossAxisAlignment.start,
                              //     children: [
                              //       const SizedBox(height: 10),
                              //       const Text(
                              //         'Expected Delivery',
                              //         style: TextStyle(
                              //             fontFamily: 'Lato',
                              //             fontSize: 16,
                              //             fontWeight: FontWeight.w600),
                              //       ),
                              //       const SizedBox(height: 10),
                              //       ListView.builder(
                              //           physics: const NeverScrollableScrollPhysics(),
                              //           itemCount: 2,
                              //           shrinkWrap: true,
                              //           itemBuilder: ((context, index) {
                              //             return Padding(
                              //             padding: const EdgeInsets.only(bottom: 8),
                              //               child: deliveryCartProducts(
                              //                 assetImage: 'assets/images/shopkart2.png',
                              //                 productName: 'Straight Kurta',
                              //                 deliveryDate: '25',
                              //               ),
                              //             );
                              //           })),
                              //       const SizedBox(height: 80),
                              //     ],
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      ),
                      Obx(
                        () {
                          var cartController = Get.find<CartController>();
                          return bottomButton(
                            totalAmount: cartController.viewTotalAmount.value,
                            deliveryAmount: 'Calculated On Checkout',
                            opacity: controller.userAddressList.isEmpty ||
                                    !controller.shippingDetails['is_shipping']
                                ? 0.5
                                : 1,
                            buttonText: controller.userAddressList.isEmpty
                                ? 'Please Select Address'
                                : 'payment',
                            priceText: AuthDetails.isUserLogin()
                                ? (cartController.otherCartDetails['total'] -
                                        (cartController
                                                .otherCartDetails['total'] -
                                            cartController
                                                .otherCartDetails['subtotal']) -
                                        (cartController.couponDetails
                                                .containsKey('discount_amount')
                                            ? cartController.couponDetails[
                                                'discount_amount']
                                            : 0))
                                    .toString()
                                : cartController.totalAmount.toString(),
                            keypressEvent: () {
                              controller.userAddressList.isEmpty ||
                                      !controller.shippingDetails['is_shipping']
                                  ? HelperFunctions().showSnackBarError(
                                      'Please select or add Address')
                                  : Get.toNamed(Routes.PAYMENT);
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
                        HelperFunctions().showOverlayLoader();
                        controller.selectAddress.value = index;
                        controller.checkShipping().then((value) =>
                            Get.until((route) => !Get.isDialogOpen!));
                      },
                      child: Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                color: controller.selectAddress.value == index
                                    ? const Color(0xFFFF4C3B).withOpacity(0.05)
                                    : const Color(0xFFEDEFF4).withOpacity(0.25),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(
                                    // color:
                                    //     controller.selectAddress.value == index
                                    //         ? themeRedColor
                                    //         : themegreyColor,
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
                                          // activeColor: themeRedColor,
                                          value: index,
                                          groupValue:
                                              controller.selectAddress.value,
                                          onChanged: (value) {
                                            // controller.selectAddress.value =
                                            //     int.parse(value.toString());
                                          }),
                                    ),
                                    // Container(
                                    //   width: 25,
                                    //   height: 30,
                                    //   decoration: BoxDecoration(
                                    //       color: themeWhiteColor,
                                    //       borderRadius:
                                    //           BorderRadiusDirectional.circular(50),
                                    //       border: Border.all(
                                    //           width: 2, color: themeBorderColor)),
                                    //   child: Padding(
                                    //     padding: const EdgeInsets.all(6.0),
                                    //     child: Container(
                                    //       height: 7.0,
                                    //       width: 7.0,
                                    //       decoration: BoxDecoration(
                                    //           borderRadius: BorderRadius.circular(5),
                                    //           color: controller.selectAddress.value ==
                                    //                   index
                                    //               ? themeRedColor
                                    //               : themeWhiteColor),
                                    //     ),
                                    //   ),
                                    // ),
                                    // const SizedBox(width: 7.0),
                                    Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Text(
                                          //     userAddress['city']['name'] ?? '',
                                          //     style: const TextStyle(
                                          //         fontFamily: 'lato',
                                          //         fontWeight: FontWeight.w600)),
                                          // SizedBox(
                                          //     width: Get.width * 0.50,
                                          //     child: Text(
                                          //         '${userAddress['house_no'] + ' , ' + userAddress['landmark'] + ' , ' + userAddress['address']}',
                                          //         style: const TextStyle(
                                          //             fontFamily: 'lato',
                                          //             color:
                                          //                 themeSecondrytext))),
                                          // Text(userAddress['mobile'] ?? '',
                                          //     style: const TextStyle(
                                          //         fontFamily: 'lato',
                                          //         color: themeTextColor)),

                                          SizedBox(
                                            width: 200,
                                            child: Text(
                                                userAddress['name']
                                                    .toString()
                                                    .capitalizeFirst
                                                    .toString(),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                softWrap: true,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 18)),
                                          ),

                                          Text(
                                              userAddress['house_no'] +
                                                  ' ' +
                                                  userAddress['address']
                                                      .toString()
                                                      .capitalizeFirst,
                                              style: const TextStyle(
                                                  // color: themeTextColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text(userAddress['city']['name'],
                                              style: const TextStyle(
                                                  // color: themeTextColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text(
                                              userAddress['state']['name'] +
                                                  ' ' +
                                                  userAddress['pincode']
                                                      .toString(),
                                              style: const TextStyle(
                                                  // color: themeTextColor,
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text(
                                              'Phone No:'.tr +
                                                  '${userAddress['mobile']}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 15)),
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
                                                              .copyWith(top: 0),
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
                                                                .headlineSmall,
                                                          ),
                                                          const Text(
                                                            "Are you sure you want to remove Address",
                                                            // style: txtTheme()
                                                            //     .titleLarge!
                                                            //     .copyWith(
                                                            //         color:
                                                            //             themeSecondrytext),
                                                          ),
                                                        ],
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            // Add logic for going back
                                                            Get.back();
                                                          },
                                                          child: const Text(
                                                            'Back',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            controller
                                                                .removeAddress(
                                                                    id: userAddress[
                                                                        '_id'],
                                                                    index:
                                                                        index);
                                                            Get.back();
                                                          },
                                                          child: const Text(
                                                            'Remove',
                                                            style: TextStyle(
                                                                // color:
                                                                //     themeRedColor
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      // color: themeWhiteColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Text(
                                                        'Remove'.toUpperCase(),
                                                        style: const TextStyle(
                                                          fontFamily: 'lato',
                                                          // color:
                                                          //     themeTextColor
                                                        )),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              GestureDetector(
                                                onTap: () async {
                                                  controller.isUpdateAddress =
                                                      true;
                                                  // controller.getAddressbyId(id: userAddress['_id']).then((value) => Get.to(AddressView()));
                                                  controller.name.text =
                                                      userAddress['name'] ?? '';
                                                  controller.email.text =
                                                      userAddress['email'] ??
                                                          '';
                                                  controller.mobileNumber.text =
                                                      userAddress['mobile'] ??
                                                          '';
                                                  controller.landmark.text =
                                                      userAddress['landmark'] ??
                                                          '';
                                                  // address.text = response['address'];
                                                  controller.area.text =
                                                      userAddress['address'] ??
                                                          '';
                                                  controller.flat.text =
                                                      userAddress['house_no'] ??
                                                          '';
                                                  controller.pinCode.text =
                                                      userAddress['pincode'] ??
                                                          '';
                                                  controller.selectedCountry
                                                          .value =
                                                      userAddress['country']
                                                              ['name'] ??
                                                          '';
                                                  controller
                                                          .selectedState.value =
                                                      userAddress['state']
                                                              ['name'] ??
                                                          '';
                                                  controller
                                                          .selectedCity.value =
                                                      userAddress['city']
                                                          ['name'];
                                                  controller.isUpdateAddress =
                                                      true;
                                                  controller.updateAddressId =
                                                      userAddress['_id'];

                                                  controller.getCountry();
                                                  controller.getState(
                                                      id: userAddress['country']
                                                          ['_id']);
                                                  controller.getCity(
                                                      id: userAddress['state']
                                                          ['_id']);
                                                  controller.selectAddressType
                                                          .value =
                                                      userAddress[
                                                          'address_type'];
                                                  controller.selectDefaultAdd
                                                      .value = userAddress[
                                                              'is_default'] ==
                                                          1
                                                      ? true
                                                      : false;
                                                  Get.to(AddUpdateAddress());

                                                  // Get.to(AddressView());
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      // color: themeWhiteColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5)),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            6.0),
                                                    child: Text(
                                                        'Edit'.toUpperCase(),
                                                        style: const TextStyle(
                                                          fontFamily: 'lato',
                                                          // color:
                                                          //     themeTextColor
                                                        )),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          if (!controller.shippingDetails[
                                                  'is_shipping'] &&
                                              index ==
                                                  controller
                                                      .selectAddress.value)
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
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              top: 22,
                              right: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                    // color: themeRedColor,
                                    borderRadius: BorderRadius.circular(3)),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 5),
                                  child: Text(
                                      userAddress['address_type'].toUpperCase(),
                                      style: txtTheme().titleLarge!.copyWith(
                                          // color: themeWhiteColor,
                                          fontSize: 12)),
                                ),
                              ))
                        ],
                      ),
                    );
                  });
                });
          }),
          outLineButton(
            backgroundColor: Colors.white,
            pressEvent: () {
              controller.isUpdateAddress = false;

              controller.name.text = '';
              controller.mobileNumber.text = '';
              controller.pinCode.text = '';
              controller.flat.text = '';
              controller.email.text = '';
              controller.area.text = '';
              controller.landmark.text = '';
              controller.selectedCity.value = '';
              controller.selectedCountry.value = '';
              controller.selectedState.value = '';
              controller.countryDataList.value = [];
              controller.stateList.value = [];
              controller.cityList.value = [];

              controller
                  .getCountry()
                  .then((value) => Get.toNamed(Routes.ADD_UPDATE_ADDRESS));
              // Get.toNamed(Routes.ADDRESS);
            },
            buttonText: 'add New address',
          ),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
