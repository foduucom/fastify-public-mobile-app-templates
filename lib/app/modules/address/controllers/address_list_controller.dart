import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/data/models/region_model.dart';
import '/app/data/services/region_service.dart';
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
  List<Region>? _countriesCache;
  final Map<String, List<Region>> _statesByCountrySlug = {};

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
      final selectedId = selectedAddress is Map
          ? (selectedAddress as Map)['_id']?.toString()
          : null;
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

        final addresses = response is List
            ? response
            : response is Map && response['data'] is List
                ? response['data'] as List
                : response is Map && response['addresses'] is List
                    ? response['addresses'] as List
                    : const <dynamic>[];
        userAddressList.assignAll(addresses.whereType<Map>());

        await _resolveRegionNames(userAddressList);

        // Keep the current selection through refreshes; otherwise prefer default.
        selectAddress.value = 0;
        for (var i = 0; i < userAddressList.length; i++) {
          final address = userAddressList[i];
          if (selectedId != null && address['_id']?.toString() == selectedId) {
            selectAddress.value = i;
            break;
          }
        }
        if (selectedId == null ||
            userAddressList[selectAddress.value]['_id']?.toString() !=
                selectedId) {
          for (var i = 0; i < userAddressList.length; i++) {
            final isDefault = userAddressList[i]['is_default'];
            if (isDefault == true || isDefault == 1 || isDefault == '1') {
              selectAddress.value = i;
              break;
            }
          }
        }

        // Prefetch any missing city names for unpopulated city ObjectIds
        _prefetchMissingCityNames();
      }
    } catch (e) {
      isLoading.value = false;
      addressLoading.value = false;
      print('Error fetching addresses: $e');
    }
  }

  Future<void> _resolveRegionNames(List<dynamic> addresses) async {
    for (final address in addresses) {
      if (address is! Map) continue;

      var country = address['country'];
      if (country is String && country.isNotEmpty) {
        try {
          _countriesCache ??= await RegionService.fetchAll(
              (page) => RegionService.fetchCountries(page: page));
          final match =
              _countriesCache!.firstWhereOrNull((r) => r.id == country);
          if (match != null) {
            country = {'_id': match.id, 'name': match.name, 'slug': match.slug};
            address['country'] = country;
          }
        } catch (e) {
          print('Could not resolve address country: $e');
        }
      }

      var state = address['state'];
      if (state is String && state.isNotEmpty && country is Map) {
        final countrySlug = country['slug']?.toString() ?? '';
        if (countrySlug.isNotEmpty) {
          try {
            final states = _statesByCountrySlug[countrySlug] ??=
                await RegionService.fetchAll((page) =>
                    RegionService.fetchStates(
                        countrySlug: countrySlug, page: page));
            final match = states.firstWhereOrNull((r) => r.id == state);
            if (match != null) {
              address['state'] = {'_id': match.id, 'name': match.name};
            }
          } catch (e) {
            print('Could not resolve address state: $e');
          }
        }
      }
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
