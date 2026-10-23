import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/data/models/region_model.dart';
import '/app/data/services/region_service.dart';
import '/app/modules/auth/auth_details.dart';
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
  late TextEditingController city;

  // Region Selection Data
  RxnString selectedCountry = RxnString();
  var selectedCountryId = ''.obs;
  var selectedCountrySlug = ''.obs;

  RxnString selectedState = RxnString();
  var selectedStateId = ''.obs;

  var isCountryLoading = false.obs;

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
    initDefaultCountry();
    super.onInit();
  }

  void _initFromArgs() {
    if (Get.arguments != null) {
      isEditMode = Get.arguments['isEdit'] ?? false;
      if (isEditMode && Get.arguments['address'] != null) {
        var addr = Get.arguments['address'];
        editAddressId = addr['_id'] ?? '';
        name.text = addr['name']?.toString() ?? '';
        email.text = addr['email']?.toString() ?? '';
        mobile.text = addr['mobile']?.toString() ?? '';
        postal_code.text = (addr['postal_code'] ?? addr['pincode'])?.toString() ?? '';
        landmark.text = addr['landmark']?.toString() ?? '';
        street.text = (addr['street'] ?? addr['address'])?.toString() ?? '';
        addressType.value = addr['address_type']?.toString() ?? 'Home';
        isDefault.value = (addr['is_default'] == 1 || addr['is_default'] == true || addr['is_default'] == '1');

        // City handling (handle Map or String, and ignore raw 24-hex Mongo ObjectIds)
        final rawCity = addr['city'] is Map
            ? (addr['city']['name']?.toString() ?? '')
            : (addr['city']?.toString() ?? '');
        if (RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(rawCity.trim())) {
          city.text = ''; // Clear raw ObjectId so user enters their actual city
        } else {
          city.text = rawCity;
        }

        // Region values
        final c = addr['country'];
        if (c is Map) {
          selectedCountry.value = Region.cleanName(c['name']);
          selectedCountryId.value = (c['_id'] ?? c['id'] ?? '').toString();
          selectedCountrySlug.value = (c['slug'] ?? '').toString();
        } else if (c is String && c.isNotEmpty) {
          selectedCountryId.value = c;
        }

        final st = addr['state'];
        if (st is Map) {
          selectedState.value = Region.cleanName(st['name']);
          selectedStateId.value = (st['_id'] ?? st['id'] ?? '').toString();
        } else if (st is String && st.isNotEmpty) {
          selectedStateId.value = st;
        }
        return;
      }
    }

    // Prefill with logged-in user profile details for a new address
    final user = AuthDetails.getUserDetails();
    if (user != null) {
      name.text = user['name']?.toString() ?? '';
      email.text = user['email']?.toString() ?? '';
      mobile.text = (user['mobile'] ?? user['phone'])?.toString() ?? '';
    }
  }

  /// Default to India for new addresses
  Future<void> initDefaultCountry() async {
    if (isEditMode || selectedCountryId.value.isNotEmpty) return;
    try {
      isCountryLoading.value = true;
      final page = await RegionService.fetchCountries(search: 'india');
      final india = page.items.firstWhereOrNull((r) => r.slug == 'india');
      if (india != null && !isEditMode && selectedCountryId.value.isEmpty) {
        selectCountry(india);
      }
    } catch (e) {
      debugPrint('Error fetching default country: $e');
    } finally {
      isCountryLoading.value = false;
    }
  }

  void selectCountry(Region r) {
    if (selectedCountryId.value != r.id) {
      clearState();
    }
    selectedCountry.value = r.name;
    selectedCountryId.value = r.id;
    selectedCountrySlug.value = r.slug;
  }

  void selectState(Region r) {
    selectedState.value = r.name;
    selectedStateId.value = r.id;
  }

  void clearState() {
    selectedState.value = null;
    selectedStateId.value = '';
  }

  void clearRegions() {
    selectedCountry.value = null;
    selectedCountryId.value = '';
    selectedCountrySlug.value = '';
    clearState();
  }

  Future<RegionPage> loadCountries(int page, String search) =>
      RegionService.fetchCountries(page: page, search: search);

  Future<RegionPage> loadStates(int page, String search) async {
    await ensureCountrySlug();
    return RegionService.fetchStates(
        countrySlug: selectedCountrySlug.value, page: page, search: search);
  }

  Future<void> ensureCountrySlug() async {
    if (selectedCountrySlug.value.isNotEmpty) return;
    final cName = selectedCountry.value;
    if (cName == null || cName.isEmpty) return;
    final page = await RegionService.fetchCountries(search: cName);
    final match = page.items.firstWhereOrNull(
            (r) => r.id == selectedCountryId.value) ??
        page.items.firstWhereOrNull(
            (r) => r.name.toLowerCase() == cName.toLowerCase());
    if (match != null) selectedCountrySlug.value = match.slug;
  }

  Future<void> saveAddress() async {
    if (!formKey.currentState!.validate()) return;
    if (selectedCountryId.value.isEmpty || selectedStateId.value.isEmpty) {
      HelperFunctions()
          .showSnackBarError("Please select country and state");
      return;
    }

    try {
      isLoading.value = true;
      HelperFunctions().showOverlayLoader();

      final user = AuthDetails.getUserDetails();
      final addressName = name.text.trim().isNotEmpty
          ? name.text.trim()
          : (user != null ? (user['name']?.toString() ?? '') : '');
      final addressEmail = email.text.trim().isNotEmpty
          ? email.text.trim()
          : (user != null ? (user['email']?.toString() ?? '') : '');
      final addressMobile = mobile.text.trim().isNotEmpty
          ? mobile.text.trim()
          : (user != null ? (user['mobile'] ?? user['phone'])?.toString() ?? '' : '');

      var body = {
        'name': addressName,
        'email': addressEmail,
        'mobile': addressMobile,
        'street': street.text.trim(),
        'landmark': landmark.text.trim(),
        'country': selectedCountryId.value,
        'state': selectedStateId.value,
        'city': city.text.trim(),
        'postal_code': postal_code.text.trim(),
        'address_type': addressType.value,
        'is_default': isDefault.value ? 1 : 0
      };

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

      Get.until((route) => !Get.isDialogOpen!); // Close loader
      isLoading.value = false;

      if (response != null) {
        Get.back(result: true); // Return true to indicate success for refresh
      }
    } catch (e) {
      Get.until((route) => !Get.isDialogOpen!);
      isLoading.value = false;
      debugPrint('Error saving address: $e');
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
