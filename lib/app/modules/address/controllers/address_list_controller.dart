import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
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
  RxDouble get total => Get.isRegistered<CartController>()
      ? Get.find<CartController>().totalAmount
      : _cartService.total;

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

        if (response == null) {
          isLoading.value = false;
          addressLoading.value = false;
          print("refreshAddresses: Response is null");
          return;
        }

        // ✅ Handle both List and Map response formats
        List rawList = [];
        if (response is List) {
          rawList = response;
        } else if (response is Map && response['data'] is List) {
          rawList = response['data'];
        }

        List tempList = [];
        // ✅ Ensure each address has a unique temp_id if real ID is missing
        for (int i = 0; i < rawList.length; i++) {
          var addr = rawList[i];
          if (addr is Map) {
            if (addr['_id'] == null && addr['id'] == null) {
              addr['temp_id'] = "temp_$i";
            }
            tempList.add(addr);
          }
        }

        userAddressList.assignAll(tempList);
        print("refreshAddresses: Loaded ${userAddressList.length} addresses");

        // ✅ Resolve country/state/city IDs to names for display
        await _resolveAddressNames();

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
      isLoading.value = false;
      addressLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      addressLoading.value = false;
      print('Error fetching addresses: $e');
    }
  }

  /// Extracts the data array from API response, handling both
  /// `response['data']` (direct List) and `response['data']['data']` (nested).
  List _extractDataList(dynamic response) {
    if (response == null) return [];
    var data = response['data'];
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  /// Resolves raw string IDs for country/state/city to Map objects with names.
  /// e.g. converts `"city": "68f9cccc281ec9e0cd95e422"` to `"city": {"_id": "...", "name": "Indore"}`
  Future<void> _resolveAddressNames() async {
    try {
      // Cache fetched data to avoid duplicate API calls
      Map<String, List> countryStatesCache = {};
      Map<String, List> stateCitiesCache = {};

      // Fetch countries once
      List countryList = [];
      var countryResponse = await BasicProvider('countries?search=indi')
          .getRequest()
          .catchError(handleError);
      if (countryResponse != null) {
        countryList = _extractDataList(countryResponse);
      }

      for (var address in userAddressList) {
        if (address is! Map) continue;

        // ── Resolve Country ──
        var countryVal = address['country'];
        String countryId = '';
        if (countryVal is String && countryVal.isNotEmpty) {
          countryId = countryVal;
          var matched = countryList.firstWhere(
            (e) => e['_id'] == countryId,
            orElse: () => null,
          );
          if (matched != null) {
            address['country'] = {
              '_id': countryId,
              'name': matched['name']?.toString() ?? '',
            };
          }
        } else if (countryVal is Map) {
          countryId = countryVal['_id']?.toString() ?? '';
        }

        // ── Resolve State ──
        var stateVal = address['state'];
        String stateId = '';
        if (stateVal is String && stateVal.isNotEmpty && countryId.isNotEmpty) {
          stateId = stateVal;
          if (!countryStatesCache.containsKey(countryId)) {
            var resp = await BasicProvider('states/$countryId')
                .getRequest()
                .catchError(handleError);
            countryStatesCache[countryId] = _extractDataList(resp);
          }
          var states = countryStatesCache[countryId] ?? [];
          var matched = states.firstWhere(
            (e) => e['_id'] == stateId,
            orElse: () => null,
          );
          if (matched != null) {
            address['state'] = {
              '_id': stateId,
              'name': matched['name']?.toString() ?? '',
            };
          }
        } else if (stateVal is Map) {
          stateId = stateVal['_id']?.toString() ?? '';
        }

        // ── Resolve City ──
        var cityVal = address['city'];
        if (cityVal is String && cityVal.isNotEmpty && stateId.isNotEmpty) {
          String cityId = cityVal;
          if (!stateCitiesCache.containsKey(stateId)) {
            var resp = await BasicProvider('cities/$stateId')
                .getRequest()
                .catchError(handleError);
            stateCitiesCache[stateId] = _extractDataList(resp);
          }
          var cities = stateCitiesCache[stateId] ?? [];
          var matched = cities.firstWhere(
            (e) => e['_id'] == cityId,
            orElse: () => null,
          );
          if (matched != null) {
            address['city'] = {
              '_id': cityId,
              'name': matched['name']?.toString() ?? '',
            };
          }
        }
      }

      // Refresh the list to trigger UI update
      userAddressList.refresh();
    } catch (e) {
      print('Error resolving address names: $e');
    }
  }

  // ✅ FIXED: correct API endpoint DELETE /api/customer/addresses/:id
  void removeAddress(String id, int index) async {
    try {
      HelperFunctions().showOverlayLoader();

      // ✅ FIXED: using postRequest with empty body {} as required by backend
      var response = await BasicProvider('customer/addresses/$id')
          .postRequest({})
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
