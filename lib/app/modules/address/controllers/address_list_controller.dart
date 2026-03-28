import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/modules/auth/auth_details.dart';
import '/constants/helper_functions.dart';
import '/core/services/cartServcie.dart';
import 'package:get/get.dart';

class AddressListController extends GetxController with BaseController {
  var userAddressList = [].obs;
  var isLoading = false.obs;
  var addressLoading = false.obs;
  var selectAddress = 0.obs;
  var shippingDetails = {}.obs;

  final _cartService = CartService.to;

  RxList<Map<String, dynamic>> get cartItems => _cartService.cartItems;
  RxDouble get subTotal => _cartService.subTotal;
  RxDouble get total => _cartService.total;

  @override
  void onInit() {
    refreshAddresses();
    super.onInit();
  }

  Future<void> refreshAddresses() async {
    try {
      isLoading.value = true;
      addressLoading.value = true;

      if (AuthDetails.isUserLogin()) {
        var response = await BasicProvider('customer/addresses')
            .getRequest()
            .catchError(handleError);

        isLoading.value = false;
        addressLoading.value = false;

        if (response == null) return;

        userAddressList.clear();

        // ✅ Handle both List and Map response formats
        if (response is List) {
          userAddressList.addAll(response);
        } else if (response is Map && response['data'] is List) {
          userAddressList.addAll(response['data']);
        }

        // ✅ Find default address index
        selectAddress.value = 0;
        for (var i = 0; i < userAddressList.length; i++) {
          if (userAddressList[i]['is_default'] == true ||
              userAddressList[i]['is_default'] == 1) {
            selectAddress.value = i;
            break;
          }
        }
      }
    } catch (e) {
      isLoading.value = false;
      addressLoading.value = false;
      print('Error fetching addresses: $e');
    }
  }

  // ✅ FIXED: correct API endpoint DELETE /api/customer/addresses/:id
  void removeAddress(String id, int index) async {
    try {
      HelperFunctions().showOverlayLoader();

      var response = await BasicProvider('customer/addresses/$id')
          .deleteRequest()
          .catchError(handleError);

      Get.until((route) => !Get.isDialogOpen!);

      if (response != null) {
        userAddressList.removeAt(index);

        // ✅ Safely reset selectAddress if out of bounds
        if (userAddressList.isEmpty) {
          selectAddress.value = 0;
        } else if (selectAddress.value >= userAddressList.length) {
          selectAddress.value = userAddressList.length - 1;
        }
      }
    } catch (e) {
      Get.until((route) => !Get.isDialogOpen!);
      print('Error removing address: $e');
    }
  }

  // ✅ FIXED: triggers reactive UI update
  void selectNewAddress(int index) {
    selectAddress.value = index;
  }
}
