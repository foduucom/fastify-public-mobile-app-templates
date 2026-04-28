import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:get/get.dart';

class AddressListController extends GetxController with BaseController {
  var userAddressList = [].obs;
  var isLoading = false.obs;
  var addressLoading = false.obs;

  // ✅ Use ID instead of index for more reliable selection
  var selectAddressId = "".obs;
  var shippingDetails = {}.obs;

  dynamic get selectedAddress {
    if (userAddressList.isEmpty) return null;
    return userAddressList.firstWhere(
      (addr) => _getAddressId(addr, 0) == selectAddressId.value,
      orElse: () => userAddressList[0],
    );
  }

  final _cartService = CartService.to;

  RxList<Map<String, dynamic>> get cartItems => _cartService.cartItems;
  RxDouble get subTotal => _cartService.subTotal;
  RxDouble get total => _cartService.total;

  // ✅ Helper to always get a unique ID for an address
  String _getAddressId(dynamic addr, int index) {
    final id = (addr['_id'] ?? addr['id'] ?? addr['temp_id'] ?? "addr_$index")
        .toString();
    return id;
  }

  @override
  void onInit() {
    print("AddressListController onInit called");
    refreshAddresses();
    super.onInit();
  }

  Future<void> refreshAddresses() async {
    try {
      print(
          "refreshAddresses started. Current selectAddressId: ${selectAddressId.value}");
      isLoading.value = true;
      addressLoading.value = true;

      if (AuthDetails.isUserLogin()) {
        var response = await BasicProvider('customer/addresses')
            .getRequest()
            .catchError(handleError);

        isLoading.value = false;
        addressLoading.value = false;

        if (response == null) {
          print("refreshAddresses: Response is null");
          return;
        }

        userAddressList.clear();

        // ✅ Handle both List and Map response formats
        List rawList = [];
        if (response is List) {
          rawList = response;
        } else if (response is Map && response['data'] is List) {
          rawList = response['data'];
        }

        // ✅ Ensure each address has a unique temp_id if real ID is missing
        for (int i = 0; i < rawList.length; i++) {
          var addr = rawList[i];
          if (addr is Map) {
            if (addr['_id'] == null && addr['id'] == null) {
              addr['temp_id'] = "temp_$i";
            }
            userAddressList.add(addr);
          }
        }

        print("refreshAddresses: Loaded ${userAddressList.length} addresses");

        if (userAddressList.isNotEmpty) {
          // ✅ Maintain current selection if possible
          bool selectionStillValid = false;
          if (selectAddressId.value.isNotEmpty) {
            selectionStillValid = userAddressList.any((addr) =>
                _getAddressId(addr, 0) ==
                selectAddressId
                    .value); // index doesn't matter for .any search if ID is real
          }

          print("refreshAddresses: selectionStillValid = $selectionStillValid");

          if (!selectionStillValid) {
            // ✅ Find default address from list if no valid selection exists
            bool defaultFound = false;
            for (var i = 0; i < userAddressList.length; i++) {
              if (userAddressList[i]['is_default'] == true ||
                  userAddressList[i]['is_default'] == 1 ||
                  userAddressList[i]['is_default'] == "1") {
                selectAddressId.value = _getAddressId(userAddressList[i], i);
                defaultFound = true;
                print(
                    "refreshAddresses: Default address found at index $i, ID: ${selectAddressId.value}");
                break;
              }
            }

            // ✅ Fallback to first address if still nothing selected
            if (!defaultFound && userAddressList.isNotEmpty) {
              selectAddressId.value = _getAddressId(userAddressList[0], 0);
              print(
                  "refreshAddresses: No default found, falling back to first address ID: ${selectAddressId.value}");
            }
          } else {
            print(
                "refreshAddresses: Keeping existing selection ID: ${selectAddressId.value}");
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

        // ✅ Safely update selection if removed item was selected
        if (selectAddressId.value == id) {
          if (userAddressList.isNotEmpty) {
            selectAddressId.value = _getAddressId(userAddressList[0], 0);
          } else {
            selectAddressId.value = "";
          }
        }
      }
    } catch (e) {
      Get.until((route) => !Get.isDialogOpen!);
      print('Error removing address: $e');
    }
  }

  // ✅ FIXED: triggers reactive UI update
  void selectNewAddress(String id) {
    print("selectNewAddress called with ID: $id");
    selectAddressId.value = id;
    selectAddressId.refresh();
    print("selectAddressId.value is now: ${selectAddressId.value}");
  }
}
