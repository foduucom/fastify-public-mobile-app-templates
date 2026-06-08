import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/address/controllers/address_list_controller.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

class AddressFormController extends GetxController with BaseController {
  AddressFormController();

  final formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController mobile;
  late TextEditingController postal_code;
  late TextEditingController street;
  late TextEditingController landmark;

  // Selection Data
  var countryList = [].obs;
  var stateList = [].obs;
  var cityList = [].obs;

  var selectedCountry = {}.obs;
  var selectedState = {}.obs;
  var selectedCity = {}.obs;

  var addressType = "Home".obs;
  var isDefault = false.obs;
  var isLoading = false.obs;

  var isEditMode = false;
  var editAddressId = '';

  @override
  void onInit() {
    name = TextEditingController();
    email = TextEditingController();
    mobile = TextEditingController();
    postal_code = TextEditingController();
    street = TextEditingController();
    landmark = TextEditingController();

    _initFromArgs();
    fetchCountries();
    super.onInit();
  }

  void _initFromArgs() {
    if (Get.arguments != null) {
      isEditMode = Get.arguments['isEdit'] ?? false;
      if (isEditMode && Get.arguments['address'] != null) {
        var addr = Get.arguments['address'];
        editAddressId = addr['_id'];
        name.text = (addr['name'] ?? '').toString();
        email.text = (addr['email'] ?? '').toString();
        mobile.text = (addr['mobile'] ?? '').toString();
        postal_code.text = (addr['postal_code'] ?? '').toString();

        landmark.text = (addr['landmark'] ?? '').toString();
        street.text = (addr['street'] ?? '').toString();
        addressType.value = (addr['address_type'] ?? 'Home').toString();
        isDefault.value = (addr['is_default'] == 1 ||
            addr['is_default'] == true ||
            addr['is_default'] == '1');

        // Initial values for dropdowns (will be populated fully when lists load)
        selectedCountry.value = (addr['country'] is Map) ? addr['country'] : {};
        selectedState.value = (addr['state'] is Map) ? addr['state'] : {};
        selectedCity.value = (addr['city'] is Map) ? addr['city'] : {};

        if (selectedCountry.isNotEmpty) _fetchStates(selectedCountry['_id']);
        if (selectedState.isNotEmpty) _fetchCities(selectedState['_id']);
      }
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

  Future<void> fetchCountries() async {
    try {
      var response = await BasicProvider('countries?search=indi')
          .getRequest()
          .catchError(handleError);
      print('address response  ${response}');
      if (response != null) {
        countryList.assignAll(_extractDataList(response));
      }
    } catch (e) {
      print('Error fetching countries: $e');
    }
  }

  Future<void> _fetchStates(String countryId) async {
    try {
      stateList.clear();
      var response = await BasicProvider('states/$countryId')
          .getRequest()
          .catchError(handleError);
      print('state response  ${response}');
      if (response != null) {
        stateList.assignAll(_extractDataList(response));
      }
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  Future<void> _fetchCities(String stateId) async {
    try {
      cityList.clear();
      var response = await BasicProvider('cities/$stateId')
          .getRequest()
          .catchError(handleError);
      if (response != null) {
        print('city response ${response}');
        cityList.assignAll(_extractDataList(response));
      }
    } catch (e) {
      print('Error fetching cities: $e');
    }
  }

  void onCountryChanged(dynamic value) {
    selectedCountry.value = value;
    selectedState.value = {};
    selectedCity.value = {};
    stateList.clear();
    cityList.clear();
    _fetchStates(value['_id']);
  }

  void onStateChanged(dynamic value) {
    selectedState.value = value;
    selectedCity.value = {};
    cityList.clear();
    _fetchCities(value['_id']);
  }

  void onCityChanged(dynamic value) {
    selectedCity.value = value;
  }

  Future<void> saveAddress() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedCountry.isEmpty ||
        selectedState.isEmpty ||
        selectedCity.isEmpty) {
      HelperFunctions()
          .showSnackBarError("Please select country, state, and city");
      return;
    }

    try {
      isLoading.value = true;
      HelperFunctions().showOverlayLoader();

      var body = {
        'name': name.text,
        'email': email.text,
        'mobile': mobile.text,
        'street': street.text,
        'landmark': landmark.text,
        'country': selectedCountry['_id'],
        'state': selectedState['_id'],
        'city': selectedCity['_id'],
        'postal_code': postal_code.text,
        'address_type': addressType.value,
        'is_default': isDefault.value ? 1 : 0
      };

      print('postman body ${body}');

      dynamic response;
      if (isEditMode) {
        print("Here We are In Edit Mode");
        response = await BasicProvider('customer/addresses/$editAddressId')
            .patchRequest(body)
            .catchError(handleError);
      } else {
        response = await BasicProvider('customer/addresses/add')
            .postRequest(body)
            .catchError(handleError);
      }

      print('response fro add address ${response}');

      Get.until((route) => !Get.isDialogOpen!); // Close loader
      isLoading.value = false;

      if (response != null) {
        // ✅ Proactively trigger refresh in AddressListController if it exists
        if (Get.isRegistered<AddressListController>()) {
          Get.find<AddressListController>().refreshAddresses();
        }
        Get.back(result: true); // Return true to indicate success for refresh
      }
    } catch (e) {
      Get.until((route) => !Get.isDialogOpen!);
      isLoading.value = false;
      print('Error saving address: $e');
    }
  }

  @override
  void onClose() {
    name.dispose();
    email.dispose();
    mobile.dispose();
    postal_code.dispose();
    street.dispose();
    landmark.dispose();
    super.onClose();
  }
}
