import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/data/models/region_model.dart';
import '/app/data/services/region_service.dart';
import '/app/modules/auth/auth_details.dart';
import '/constants/helper_functions.dart';
import '/core/services/cartServcie.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class AddressListController extends GetxController with BaseController {
  var userAddressList = [].obs;
  var isLoading = false.obs;
  var addressLoading = false.obs;
  var selectAddress = 0.obs;
  var shippingDetails = {}.obs;

  List<Region>? _allCountriesCache;
  final Map<String, List<Region>> _statesByCountrySlug = {};

  final _cartService = CartService.to;

  RxList<Map<String, dynamic>> get cartItems => _cartService.cartItems;
  RxDouble get subTotal => _cartService.subTotal;
  RxDouble get total => _cartService.total;

  @override
  void onInit() {
    refreshAddresses();
    super.onInit();
  }

  Future<void> resolveAddressesNames(List<dynamic> addresses) async {
    try {
      for (var address in addresses) {
        if (address is! Map) continue;

        String countryId = '';
        String countrySlug = '';
        final countryVal = address['country'];
        if (countryVal is Map) {
          countryId = countryVal['_id']?.toString() ?? '';
          countrySlug = countryVal['slug']?.toString() ?? '';
        } else if (countryVal is String && countryVal.isNotEmpty) {
          countryId = countryVal;
          _allCountriesCache ??= await RegionService.fetchAll(
              (p) => RegionService.fetchCountries(page: p));
          final match =
              _allCountriesCache!.firstWhereOrNull((r) => r.id == countryId);
          if (match != null) {
            countrySlug = match.slug;
            address['country'] = {
              '_id': match.id,
              'name': match.name,
              'slug': match.slug
            };
          }
        }

        final stateVal = address['state'];
        if (stateVal is String && stateVal.isNotEmpty && countrySlug.isNotEmpty) {
          final states = _statesByCountrySlug[countrySlug] ??=
              await RegionService.fetchAll((p) => RegionService.fetchStates(
                  countrySlug: countrySlug, page: p));
          final match = states.firstWhereOrNull((r) => r.id == stateVal);
          if (match != null) {
            address['state'] = {'_id': match.id, 'name': match.name};
          }
        }
      }
    } catch (e) {
      debugPrint('Error resolving address names: $e');
    }
  }

  Future<void> refreshAddresses() async {
    try {
      print(
          'refreshAddresses started. Current selection index: ${selectAddress.value}');

      // Store current selected ID to restore it after refresh
      String? currentSelectedId;
      if (userAddressList.isNotEmpty &&
          selectAddress.value < userAddressList.length) {
        currentSelectedId =
            userAddressList[selectAddress.value]['_id']?.toString();
      }

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
        List<dynamic> fetchedList = [];
        if (response is List) {
          fetchedList = response;
        } else if (response is Map && response['data'] is List) {
          fetchedList = response['data'];
        }

        await resolveAddressesNames(fetchedList);
        userAddressList.assignAll(fetchedList);
        print('refreshAddresses: Loaded ${userAddressList.length} addresses');

        // ✅ Restore selection by ID
        bool selectionStillValid = false;
        if (currentSelectedId != null) {
          for (var i = 0; i < userAddressList.length; i++) {
            if (userAddressList[i]['_id']?.toString() == currentSelectedId) {
              selectAddress.value = i;
              selectionStillValid = true;
              print(
                  'refreshAddresses: selectionStillValid = true, Keeping existing selection ID: $currentSelectedId');
              break;
            }
          }
        }

        // If selection not found (e.g. deleted or first time), find default
        if (!selectionStillValid) {
          selectAddress.value = 0;
          for (var i = 0; i < userAddressList.length; i++) {
            if (userAddressList[i]['is_default'] == true ||
                userAddressList[i]['is_default'] == 1) {
              selectAddress.value = i;
              print('refreshAddresses: Found default address at index $i');
              break;
            }
          }
        }

        // Force UI refresh just in case
        userAddressList.refresh();
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
