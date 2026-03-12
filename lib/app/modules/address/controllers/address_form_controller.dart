import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/constants/helper_functions.dart';
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
        name.text = addr['name'] ?? '';
        email.text = addr['email'] ?? '';
        mobile.text = addr['mobile'] ?? '';
        postal_code.text = addr['postal_code'] ?? '';

        landmark.text = addr['landmark'] ?? '';
        street.text = addr['street'] ?? '';
        addressType.value = addr['address_type'] ?? 'Home';
        isDefault.value = (addr['is_default'] == 1);

        // Initial values for dropdowns (will be populated fully when lists load)
        selectedCountry.value = addr['country'] ?? {};
        selectedState.value = addr['state'] ?? {};
        selectedCity.value = addr['city'] ?? {};

        if (selectedCountry.isNotEmpty) _fetchStates(selectedCountry['_id']);
        if (selectedState.isNotEmpty) _fetchCities(selectedState['_id']);
      }
    }
  }

  Future<void> fetchCountries() async {
    try {
      var response = await BasicProvider('countries?search=indi')
          .getRequest()
          .catchError(handleError);
      print('address r esponse  ${response}');
      if (response != null) {
        countryList.assignAll(response['data']);
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
      print('state resonse  ${response}');
      if (response != null) {
        stateList.assignAll(response['data']);
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
        cityList.assignAll(response['data']);
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
        response =
            await BasicProvider('customer/addresses/update/$editAddressId')
                .postRequest(body)
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
