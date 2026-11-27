import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/data/models/region_model.dart';
import '/app/data/services/region_service.dart';
import '/app/modules/auth/auth_details.dart';
import 'package:flutter/foundation.dart';
import '/constants/helper_functions.dart';
import '/core/services/cartServcie.dart';
import 'package:get/get.dart';

class AddressListController extends GetxController with BaseController {
  var userAddressList = [].obs;
  List<Region>? _allCountriesCache;
  final Map<String, List<Region>> _statesByCountrySlug = {};

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
        if (stateVal is String &&
            stateVal.isNotEmpty &&
            countrySlug.isNotEmpty) {
          final states = _statesByCountrySlug[countrySlug] ??=
              await RegionService.fetchAll((p) =>
                  RegionService.fetchStates(countrySlug: countrySlug, page: p));
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

  var isLoading = false.obs;
  var addressLoading = false.obs;
  final loadError = false.obs;
  var selectAddress = 0.obs;
  var shippingDetails = {}.obs;
  var firstloading = 0.obs;

  dynamic get selectedAddress {
    if (userAddressList.isEmpty) return null;
    if (selectAddress.value >= 0 &&
        selectAddress.value < userAddressList.length) {
      return userAddressList[selectAddress.value];
    }
    return null;
  }

  final _cartService = CartService.to;

  RxList<Map<String, dynamic>> get cartItems => _cartService.cartItems;
  RxDouble get subTotal => _cartService.subTotal;
  RxDouble get total => _cartService.total;

  // Cache for city names mapped by cityId
  var cityNamesCache = <String, String>{}.obs;
  final Set<String> _prefetchedStates = {};

  void cacheCity(String id, String name) {
    if (id.isNotEmpty && name.isNotEmpty) {
      cityNamesCache[id] = name;
    }
  }

  String? getCityName(String id) {
    return cityNamesCache[id];
  }

  @override
  void onInit() {
    super.onInit();
    refreshAddresses();
  }

  Future<void> refreshAddresses({bool useCache = true}) async {
    try {
      String? currentSelectedId;
      if (userAddressList.isNotEmpty &&
          selectAddress.value >= 0 &&
          selectAddress.value < userAddressList.length) {
        currentSelectedId =
            userAddressList[selectAddress.value]['_id']?.toString();
      }

      isLoading.value = true;
      addressLoading.value = true;
      loadError.value = false;

      if (AuthDetails.isUserLogin()) {
        var response = await BasicProvider('customer/addresses')
            .getRequest(useCache: useCache)
            .catchError(handleError);
        addressLoading.value = false;
        isLoading.value = false;

        if (response == null) {
          loadError.value = true;
          return;
        }

        userAddressList.clear();

        List<dynamic> fetchedList = [];
        if (response is List) {
          fetchedList = response;
        } else if (response is Map && response['data'] is List) {
          fetchedList = response['data'];
        }

        await resolveAddressesNames(fetchedList);
        userAddressList.assignAll(fetchedList);

        bool selectionStillValid = false;
        if (currentSelectedId != null) {
          for (var i = 0; i < userAddressList.length; i++) {
            if (userAddressList[i]['_id']?.toString() == currentSelectedId) {
              selectAddress.value = i;
              selectionStillValid = true;
              break;
            }
          }
        }

        if (!selectionStillValid) {
          selectAddress.value = 0;
          for (var i = 0; i < userAddressList.length; i++) {
            if (userAddressList[i]['is_default'] == true ||
                userAddressList[i]['is_default'] == 1 ||
                userAddressList[i]['is_default'] == '1') {
              selectAddress.value = i;
              break;
            }
          }
        }

        userAddressList.refresh();
        _prefetchMissingCityNames();
      } else {
        userAddressList.clear();
        selectAddress.value = 0;
      }
    } catch (e) {
      loadError.value = true;
      debugPrint('Address refresh failed: $e');
    } finally {
      isLoading.value = false;
      addressLoading.value = false;
    }
  }

  void _prefetchMissingCityNames() {
    for (var addr in userAddressList) {
      if (addr is Map) {
        final city = addr['city'];
        final state = addr['state'];
        if (city is String && RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(city)) {
          if (!cityNamesCache.containsKey(city) &&
              state is Map &&
              state['_id'] != null) {
            _fetchAndCacheCities(state['_id'].toString());
          }
        }
      }
    }
  }

  Future<void> _fetchAndCacheCities(String stateId) async {
    if (_prefetchedStates.contains(stateId)) return;
    _prefetchedStates.add(stateId);
    try {
      var response = await BasicProvider('cities/$stateId').getRequest();
      if (response != null && response['data'] is List) {
        for (var c in response['data']) {
          if (c is Map && c['_id'] != null && c['name'] != null) {
            cityNamesCache[c['_id'].toString()] = c['name'].toString();
          }
        }
      }
    } catch (e) {
      print('Error prefetching cities for state $stateId: $e');
    }
  }

  Future<void> removeAddress(String id) async {
    try {
      HelperFunctions().showOverlayLoader();

      var response = await BasicProvider('customer/addresses/$id')
          .postRequest({}).catchError(handleError);
      if (response == null ||
          (response is Map &&
              (response['success'] == false ||
                  response['status'] == false ||
                  const {'error', 'failed', 'failure'}.contains(
                      response['status']?.toString().toLowerCase())))) {
        throw Exception('Address removal was not confirmed');
      }

      final actualIndex = userAddressList.indexWhere(
          (address) => address is Map && address['_id']?.toString() == id);
      if (actualIndex == -1) return;
      final selectedId =
          selectedAddress is Map ? selectedAddress['_id']?.toString() : null;
      userAddressList.removeAt(actualIndex);
      if (userAddressList.isEmpty) {
        selectAddress.value = 0;
      } else if (selectedId != id) {
        final preservedIndex = userAddressList.indexWhere((address) =>
            address is Map && address['_id']?.toString() == selectedId);
        selectAddress.value = preservedIndex >= 0 ? preservedIndex : 0;
      } else {
        selectAddress.value = actualIndex.clamp(0, userAddressList.length - 1);
      }
      HelperFunctions().showSnackBarSuccess('Address removed successfully');
    } catch (e) {
      debugPrint('Address removal failed: $e');
      HelperFunctions()
          .showSnackBarError('Failed to remove address. Please try again.');
    } finally {
      HelperFunctions().hideOverlayLoader();
    }
  }

  void selectNewAddress(int index) {
    selectAddress.value = index;
  }
}
