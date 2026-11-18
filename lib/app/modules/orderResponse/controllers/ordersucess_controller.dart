import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/data/models/region_model.dart';
import '/app/data/services/region_service.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import '/app/modules/cart/controllers/cart_controller.dart';

class OrderSuccessController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  final orderNo = ''.obs;
  var totalAmount = ''.obs;
  var address = {}.obs;
  var isLoading = true.obs;
  List<Region>? _countriesCache;
  final Map<String, List<Region>> _statesByCountrySlug = {};

  bool _isObjectId(String value) =>
      RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(value);

  Future<void> _resolveAddressNames(Map addressData) async {
    try {
      final countryValue = addressData['country'];
      final countryId = countryValue is Map
          ? (countryValue['_id'] ?? countryValue['id'] ?? '').toString()
          : (countryValue ?? '').toString();
      var countrySlug =
          countryValue is Map ? (countryValue['slug'] ?? '').toString() : '';

      final hasCountryName = countryValue is Map &&
          (countryValue['name'] ?? '').toString().trim().isNotEmpty;
      if (_isObjectId(countryId) && (!hasCountryName || countrySlug.isEmpty)) {
        _countriesCache ??= await RegionService.fetchAll(
          (page) => RegionService.fetchCountries(page: page),
        );
        Region? match;
        for (final region in _countriesCache!) {
          if (region.id == countryId) {
            match = region;
            break;
          }
        }
        if (match != null) {
          countrySlug = match.slug;
          addressData['country'] = {
            '_id': match.id,
            'name': match.name,
            'slug': match.slug,
          };
        }
      }

      final stateValue = addressData['state'];
      final stateId = stateValue is Map
          ? (stateValue['_id'] ?? stateValue['id'] ?? '').toString()
          : (stateValue ?? '').toString();
      final hasStateName = stateValue is Map &&
          (stateValue['name'] ?? '').toString().trim().isNotEmpty;
      if (_isObjectId(stateId) && !hasStateName && countrySlug.isNotEmpty) {
        final states =
            _statesByCountrySlug[countrySlug] ??= await RegionService.fetchAll(
          (page) => RegionService.fetchStates(
            countrySlug: countrySlug,
            page: page,
          ),
        );
        for (final region in states) {
          if (region.id == stateId) {
            addressData['state'] = {'_id': region.id, 'name': region.name};
            break;
          }
        }
      }
    } catch (e) {
      print('Error resolving order address names: $e');
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoading.value = true;
    final args = Get.arguments;
    if (args is Map) {
      if (args['id'] != null) id.value = args['id'].toString();
      if (args['order_no'] != null) orderNo.value = args['order_no'].toString();
    } else if (args is String) {
      id.value = args;
    }
    try {
      await OrderDetail();
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onReady() {
    super.onReady();
    _refreshCartAfterOrder();
  }

  /// Drop stale local cart copy and applied coupons so the cart tab reflects order placement
  void _refreshCartAfterOrder() {
    try {
      if (Get.isRegistered<CartController>()) {
        final cart = Get.find<CartController>();
        cart.couponDetails.clear();
        cart.isCouponApply.value = false;
      }
      if (Get.isRegistered<CartService>()) {
        CartService.to.fetchCart();
      }
    } catch (e) {
      print('Error refreshing cart after order: $e');
    }
  }

  Future<void> OrderDetail() async {
    if (id.value == '0' || id.value.isEmpty) {
      isLoading.value = false;
      return;
    }
    try {
      isLoading.value = true;
      var response = await BasicProvider("order/${id.value}")
          .getRequest()
          .catchError(handleError);

      printInfo(info: 'OrderDetail response: $response');

      if (response == null) return;

      var orderData = response.containsKey('data') && response['data'] is Map
          ? response['data']
          : response;

      final rawAddress = orderData != null ? orderData['address'] : null;
      final addressData =
          rawAddress is Map ? Map.of(rawAddress) : <dynamic, dynamic>{};
      await _resolveAddressNames(addressData);
      if (orderData is Map && rawAddress is Map) {
        orderData['address'] = addressData;
      }

      item.value = response;
      if (orderData != null &&
          orderData['order_no'] != null &&
          orderNo.value.isEmpty) {
        orderNo.value = orderData['order_no'].toString();
      }
      address.value = addressData;

      item.refresh();
      address.refresh();
    } catch (e) {
      print('Error in OrderDetail $e');
    } finally {
      isLoading.value = false;
    }
  }
}
