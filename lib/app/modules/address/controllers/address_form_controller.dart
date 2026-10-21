import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/data/models/region_model.dart';
import 'package:foduu_ecommerce/app/data/services/region_service.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
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

  var isCountryLoading = false.obs;

  static final RegExp _objectId = RegExp(r'^[0-9a-fA-F]{24}$');

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
      isCountryLoading.value = true;
      final page = await RegionService.fetchCountries(search: 'india');
      final india = page.items.firstWhereOrNull((r) => r.slug == 'india');
      if (india != null && selectedCountry.isEmpty) onCountryChanged(india);
    } catch (e) {
      print('Error defaulting country: $e');
    } finally {
      isCountryLoading.value = false;
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
        postal_code.text =
            (addr['postal_code'] ?? addr['pincode'] ?? '').toString();

        landmark.text = (addr['landmark'] ?? '').toString();
        street.text = (addr['street'] ?? addr['address'] ?? '').toString();
        addressType.value = (addr['address_type'] ?? 'Home').toString();
        isDefault.value = (addr['is_default'] == 1 ||
            addr['is_default'] == true ||
            addr['is_default'] == '1');

        selectedCountry.value = (addr['country'] is Map)
            ? Map.from(addr['country'])
            : {};
        selectedState.value =
            (addr['state'] is Map) ? Map.from(addr['state']) : {};
        final cityValue = addr['city'] is Map
            ? (addr['city']['name'] ?? '').toString()
            : (addr['city'] ?? '').toString();
        // A bare ObjectId means the city was never resolved to a name.
        city.text = _objectId.hasMatch(cityValue.trim()) ? '' : cityValue;
      }
    }
    if (!isEditMode) _prefillFromProfile();
  }

  /// Prefills a new address with the logged-in user's profile details.
  void _prefillFromProfile() {
    final user = AuthDetails.getUserDetails();
    if (user == null) return;
    name.text = user['name']?.toString() ?? '';
    email.text = user['email']?.toString() ?? '';
    mobile.text = (user['mobile'] ?? user['phone'])?.toString() ?? '';
  }

  String _orProfile(TextEditingController c, List<String> profileKeys) {
    if (c.text.trim().isNotEmpty) return c.text.trim();
    final user = AuthDetails.getUserDetails();
    if (user == null) return '';
    for (final k in profileKeys) {
      final v = user[k]?.toString();
      if (v != null && v.isNotEmpty) return v;
    }
    return '';
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
        'name': _orProfile(name, ['name']),
        'email': _orProfile(email, ['email']),
        'mobile': _orProfile(mobile, ['mobile', 'phone']),
        'street': street.text.trim(),
        'landmark': landmark.text.trim(),
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
