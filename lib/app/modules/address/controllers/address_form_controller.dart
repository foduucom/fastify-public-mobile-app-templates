import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/data/models/region_model.dart';
import 'package:foduu_ecommerce/app/data/services/region_service.dart';
import 'package:foduu_ecommerce/app/modules/address/controllers/address_list_controller.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';

class AddressFormController extends GetxController with BaseController {
  AddressFormController();

  // Controllers
  late TextEditingController name;
  late TextEditingController email;
  late TextEditingController mobile;
  late TextEditingController postal_code;
  late TextEditingController street;
  late TextEditingController landmark;
  late TextEditingController city;

  /// Country / state the user picked, as `{_id, name, slug}` (state has no slug).
  var selectedCountry = {}.obs;
  var selectedState = {}.obs;

  Map _regionMap(Region r) => {'_id': r.id, 'name': r.name, 'slug': r.slug};

  void onCountryChanged(Region value) {
    if (selectedCountry['_id'] != value.id) selectedState.value = {};
    selectedCountry.value = _regionMap(value);
  }

  void onStateChanged(Region value) {
    selectedState.value = _regionMap(value);
  }

  Future<RegionPage> loadCountries(int page, String search) =>
      RegionService.fetchCountries(page: page, search: search);

  Future<RegionPage> loadStates(int page, String search) async {
    await _ensureCountrySlug();
    return RegionService.fetchStates(
        countrySlug: (selectedCountry['slug'] ?? '').toString(),
        page: page,
        search: search);
  }

  /// The states API is keyed by country slug; saved addresses only carry
  /// `{_id, name}`, so look the slug up when it is missing.
  Future<void> _ensureCountrySlug() async {
    if ((selectedCountry['slug'] ?? '').toString().isNotEmpty) return;
    final name = (selectedCountry['name'] ?? '').toString();
    if (name.isEmpty) return;
    final page = await RegionService.fetchCountries(search: name);
    final id = selectedCountry['_id']?.toString();
    final match = page.items.firstWhereOrNull((r) => r.id == id) ??
        page.items.firstWhereOrNull(
            (r) => r.name.toLowerCase() == name.toLowerCase());
    if (match != null) selectedCountry['slug'] = match.slug;
  }

  /// Defaults a new address to India, like the website.
  Future<void> _defaultCountry() async {
    if (isEditMode || selectedCountry.isNotEmpty) return;
    try {
      final page = await RegionService.fetchCountries(search: 'india');
      final india = page.items.firstWhereOrNull((r) => r.slug == 'india');
      if (india != null && selectedCountry.isEmpty) onCountryChanged(india);
    } catch (e) {
      print('Error defaulting country: $e');
    }
  }

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
    city = TextEditingController();

    _initFromArgs();
    _defaultCountry();
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

        selectedCountry.value = (addr['country'] is Map)
            ? Map.from(addr['country'])
            : {};
        selectedState.value =
            (addr['state'] is Map) ? Map.from(addr['state']) : {};
        city.text = addr['city'] is Map
            ? (addr['city']['name'] ?? '').toString()
            : (addr['city'] ?? '').toString();
      }
    }
  }

  Future<void> saveAddress(GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedCountry.isEmpty || selectedState.isEmpty) {
      HelperFunctions().showSnackBarError("Please select country and state");
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
        'city': city.text.trim(),
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
    city.dispose();
    super.onClose();
  }
}
