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
  var firstloading = 0.obs;

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
        userAddressList.addAll(response);

        // Find default address
        selectAddress.value = 0;
        for (var i = 0; i < userAddressList.length; i++) {
          if (1 == userAddressList[i]['is_default']) {
            selectAddress.value = i;
            break;
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
