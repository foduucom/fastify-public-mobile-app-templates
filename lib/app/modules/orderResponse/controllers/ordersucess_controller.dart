import 'package:flutter/cupertino.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/app/modules/address/controllers/address_list_controller.dart';

class OrderSuccessController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  var totalAmount = ''.obs;
  var address = {}.obs;
  var isLoading = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    if (Get.arguments != null) {
      // If arguments is a String (order_no), use it directly. If it's a Map, look for 'id'.
      if (Get.arguments is String) {
        id.value = Get.arguments;
      } else if (Get.arguments['id'] != null) {
        id.value = Get.arguments['id'];
      }
    }
    await OrderDetail();
  }

  Future<void> OrderDetail() async {
    if (id.value == '0') return;
    isLoading.value = true;
    var response = await BasicProvider("order/${id.value}")
        .getRequest()
        .catchError(handleError);

    print('response $response');

    if (response == null) {
      isLoading.value = false;
      return;
    }

    if (response != null) {
      var data = response;
      item.clear();
      item.value = data;
      address.value = data['address'] != null ? Map<String, dynamic>.from(data['address']) : {};
      await _resolveAddressNames();
    }
    isLoading.value = false;
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
              (addr['_id']?.toString() == address['_id']?.toString() && address['_id'] != null),
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
      if (isHexId.hasMatch(countryVal)) {
        countryId = countryVal;
        var countryResponse = await BasicProvider('countries?search=indi')
            .getRequest()
            .catchError(handleError);
        if (countryResponse != null) {
          List countries = _extractDataList(countryResponse);
          var matched = countries.firstWhere(
            (e) => e['_id'] == countryId,
            orElse: () => null,
          );
          if (matched != null) {
            address['country'] = {
              '_id': countryId,
              'name': matched['name']?.toString() ?? '',
            };
          }
        }
      } else if (address['country'] is Map) {
        countryId = address['country']['_id']?.toString() ?? '';
      }

      // ── Resolve State ──
      String stateId = '';
      if (isHexId.hasMatch(stateVal) && countryId.isNotEmpty) {
        stateId = stateVal;
        var resp = await BasicProvider('states/$countryId')
            .getRequest()
            .catchError(handleError);
        if (resp != null) {
          List states = _extractDataList(resp);
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
