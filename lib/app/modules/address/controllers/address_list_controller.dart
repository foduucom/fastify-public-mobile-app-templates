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
  var isLoading = false.obs;
  var addressLoading = false.obs;
  var selectAddress = 0.obs;
  var shippingDetails = {}.obs;
  var firstloading = 0.obs;

  dynamic get selectedAddress {
    if (userAddressList.isEmpty) return null;
    if (selectAddress.value >= 0 && selectAddress.value < userAddressList.length) {
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
    refreshAddresses();
    super.onInit();
  }

  Future<void> refreshAddresses() async {
    try {
      String? currentSelectedId;
      if (userAddressList.isNotEmpty &&
          selectAddress.value < userAddressList.length) {
        currentSelectedId =
            userAddressList[selectAddress.value]['_id']?.toString();
      }

      isLoading.value = true;
      addressLoading.value = true;

      print('isLogin ${AuthDetails.isUserLogin()}');
      if (AuthDetails.isUserLogin()) {
        var response = await BasicProvider('customer/addresses')
            .getRequest()
            .catchError(handleError);
        addressLoading.value = false;
        isLoading.value = false;

        print('respsen addressssssssss--- --- -- - - -$response');

        if (response == null) return;

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
      }
    } catch (e) {
      isLoading.value = false;
      addressLoading.value = false;
      print('Error fetching addresses: $e');
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

  void removeAddress(String id, int index) async {
    try {
      HelperFunctions().showOverlayLoader();

      var response = await BasicProvider('customer/addresses/$id')
          .postRequest({}).catchError(handleError);
      HelperFunctions().hideOverlayLoader();
      print('remove address $response');

      if (response != null) {
        userAddressList.removeAt(index);
        if (selectAddress.value >= userAddressList.length) {
          selectAddress.value = 0;
        }

        update();
      }
    } catch (e) {
      HelperFunctions().hideOverlayLoader();
      print('Error removing address: $e');
    }
  }

  void selectNewAddress(int index) {
    selectAddress.value = index;
  }
}
