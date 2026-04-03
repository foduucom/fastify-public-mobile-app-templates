import 'package:get/get.dart';

import '../controller/address_controlle.dart';


class AddressBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddressController>(
          () => AddressController(),
    );
  }
}