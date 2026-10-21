import 'package:flutter/cupertino.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/data/models/region_model.dart';
import 'package:foduu_ecommerce/app/data/services/region_service.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/app/modules/address/controllers/address_list_controller.dart';

class OrderSuccessController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  final orderNo = ''.obs;
  var totalAmount = ''.obs;
  var address = {}.obs;
  var isLoading = true.obs;
  var checkoutMethod = ''.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoading.value = true;
    final args = Get.arguments;
    // A String is the order id; a Map carries id / order_no / method.
    if (args is String) {
      id.value = args;
    } else if (args is Map) {
      if (args['id'] != null) id.value = args['id'].toString();
      if (args['order_no'] != null) orderNo.value = args['order_no'].toString();
      checkoutMethod.value = (args['method'] ?? '').toString();
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

  /// The backend empties the cart when the order is created; drop the stale
  /// local copy (and any applied coupon) so the cart tab doesn't still show
  /// the items that were just ordered.
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

      final orderData = response is Map &&
              response.containsKey('data') &&
              response['data'] is Map
          ? response['data']
          : response;

      item.clear();
      item.value = response;
      if (orderData['order_no'] != null && orderNo.value.isEmpty) {
        orderNo.value = orderData['order_no'].toString();
      }
      address.value = orderData['address'] is Map
          ? Map<String, dynamic>.from(orderData['address'])
          : {};
      await _resolveAddressNames();
    } catch (e) {
      print('Error in OrderDetail $e');
    } finally {
      isLoading.value = false;
    }
  }

  List _extractDataList(dynamic response) {
    if (response == null) return [];
    var data = response['data'];
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'];
    return [];
  }

  Future<void> _resolveAddressNames() async {
    if (address.isEmpty) return;

    final isHexId = RegExp(r'^[a-fA-F0-9]{24}$');
    var countryVal = address['country']?.toString() ?? '';
    var stateVal = address['state']?.toString() ?? '';
    var cityVal = address['city']?.toString() ?? '';

    // First, try matching with AddressListController's list
    try {
      if (Get.isRegistered<AddressListController>()) {
        final addressController = Get.find<AddressListController>();
        final matchedAddr = addressController.userAddressList.firstWhere(
          (addr) =>
              (addr['street']?.toString() == address['address']?.toString() &&
                  addr['name']?.toString() == address['name']?.toString()) ||
              (addr['_id']?.toString() == address['_id']?.toString() &&
                  address['_id'] != null),
          orElse: () => null,
        );
        if (matchedAddr != null) {
          address['city'] = matchedAddr['city'];
          address['state'] = matchedAddr['state'];
          address['country'] = matchedAddr['country'];
          address.refresh();
          return;
        }
      }
    } catch (e) {
      print('Error matching with AddressListController: $e');
    }

    // Fallback: Resolve via API calls if they are hexadecimal IDs
    try {
      // ── Resolve Country ──
      String countryId = '';
      String countrySlug = '';
      if (isHexId.hasMatch(countryVal)) {
        countryId = countryVal;
        final countries = await RegionService.fetchAll(
            (p) => RegionService.fetchCountries(page: p));
        final matched = countries.firstWhereOrNull((e) => e.id == countryId);
        if (matched != null) {
          countrySlug = matched.slug;
          address['country'] = {
            '_id': countryId,
            'name': matched.name,
            'slug': matched.slug,
          };
        }
      } else if (address['country'] is Map) {
        countryId = address['country']['_id']?.toString() ?? '';
        countrySlug = address['country']['slug']?.toString() ?? '';
      }

      // ── Resolve State ──
      String stateId = '';
      if (isHexId.hasMatch(stateVal) && countrySlug.isNotEmpty) {
        stateId = stateVal;
        final states = await RegionService.fetchAll((p) =>
            RegionService.fetchStates(countrySlug: countrySlug, page: p));
        final matched = states.firstWhereOrNull((e) => e.id == stateId);
        if (matched != null) {
          address['state'] = {'_id': stateId, 'name': matched.name};
        }
      } else if (address['state'] is Map) {
        stateId = address['state']['_id']?.toString() ?? '';
      }

      // ── Resolve City ──
      if (isHexId.hasMatch(cityVal) && stateId.isNotEmpty) {
        String cityId = cityVal;
        var resp = await BasicProvider('cities/$stateId')
            .getRequest()
            .catchError(handleError);
        if (resp != null) {
          List cities = _extractDataList(resp);
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
      address.refresh();
    } catch (e) {
      print('Error resolving address names in success controller: $e');
    }
  }
}
