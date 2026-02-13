import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/address/controllers/address_controller.dart';
import 'package:foduu_ecommerce/app/modules/address/views/delivery_detial_view.dart';
import 'package:get/get.dart';

class AccountManageAddressView extends GetView<AddressController> {
  AccountManageAddressView({Key? key}) : super(key: key);

  // var controller = Get.put(AddressController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
              title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Manage Address'.tr),
                    SizedBox(height: 5),
                  ]),
              elevation: 0.0),
          body: RefreshIndicator(
            onRefresh: () async {
              // await controller.onPullToRefresh();
            },
            child: Stack(
              children: [
                Positioned(
                    top: 0,
                    right: 10,
                    left: 10,
                    bottom: 0,
                    child: ListView(
                      children: [
                        ManageAddress(controller: controller),
                        // Obx(() => controller.showData.isTrue
                        //     ? const ExpectedDelivery()
                        //     : Container())
                      ],
                    )),
              ],
            ),
          )),
    );
  }
}
