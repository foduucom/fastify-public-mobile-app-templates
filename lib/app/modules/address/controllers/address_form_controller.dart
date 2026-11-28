import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/data/models/region_model.dart';
import '/app/data/services/region_service.dart';
import '/app/modules/auth/auth_details.dart';
import '/constants/helper_functions.dart';
import '/helpers/dialog_helper.dart';
import 'package:get/get.dart';
import 'address_list_controller.dart';

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
      debugPrint('Could not load default country: $e');
    }
  }

  var addressType = "Home".obs;
  var isDefault = false.obs;
  var isLoading = false.obs;

  var isEditMode = false;
  var editAddressId = '';

  @override
  void onInit() {
    super.onInit();
    name = TextEditingController();
    email = TextEditingController();
    mobile = TextEditingController();
    postal_code = TextEditingController();
    street = TextEditingController();
    landmark = TextEditingController();
    city = TextEditingController();

    try {
      _initFromArgs();
    } catch (e) {
      debugPrint('Failed to initialize address form: $e');
      Get.snackbar(
        "Error",
        "Failed to load address data. Please try again.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    _defaultCountry();
  }

  void _initFromArgs() {
    final arguments = Get.arguments;
    if (arguments is Map) {
      isEditMode = arguments['isEdit'] == true;

      if (isEditMode && arguments['address'] != null) {
        final addr = arguments['address'];

        // Debug print to see what we're getting

        // Make sure addr is a Map
        if (addr is Map) {
          editAddressId = (addr['_id'] ?? addr['id'] ?? '').toString();
          name.text = addr['name']?.toString() ?? '';
          email.text = addr['email']?.toString() ?? '';
          mobile.text = addr['mobile']?.toString() ?? '';
          postal_code.text = addr['postal_code']?.toString() ?? '';
          landmark.text = addr['landmark']?.toString() ?? '';
          street.text = addr['street']?.toString() ?? '';
          addressType.value = addr['address_type']?.toString() ?? 'Home';
          isDefault.value = const {true, 1, '1'}.contains(addr['is_default']);

          selectedCountry.value =
              addr['country'] is Map ? Map.from(addr['country']) : {};
          selectedState.value =
              addr['state'] is Map ? Map.from(addr['state']) : {};
          final rawCity = addr['city'] is Map
              ? (addr['city']['name'] ?? '').toString()
              : (addr['city'] ?? '').toString();
          if (RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(rawCity.trim())) {
            city.text = ''; // Clear legacy ObjectId so user types actual city
          } else {
            city.text = rawCity;
          }
        } else {
          // If addr is a String, try to parse it or handle the error
          Get.snackbar(
            "Error",
            "Invalid address data format",
            snackPosition: SnackPosition.BOTTOM,
          );
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

  Future<void> saveAddress() async {
    if (isLoading.value) return;
    if (formKey.currentState?.validate() != true) return;
    if ((selectedCountry['_id'] ?? '').toString().isEmpty ||
        (selectedState['_id'] ?? '').toString().isEmpty) {
      HelperFunctions().showSnackBarError("Please select country and state");
      return;
    }
    if (isEditMode && editAddressId.isEmpty) {
      HelperFunctions().showSnackBarError(
          'This address cannot be updated because its ID is missing.');
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
          : (user != null
              ? (user['mobile'] ?? user['phone'])?.toString() ?? ''
              : '');

      var body = {
        'name': addressName,
        'email': addressEmail,
        'mobile': addressMobile,
        'street': street.text.trim(),
        'landmark': landmark.text.trim(),
        'country': selectedCountry['_id'],
        'state': selectedState['_id'],
        'city': city.text.trim(),
        'postal_code': postal_code.text.trim(),
        'address_type': addressType.value,
        'is_default': isDefault.value ? 1 : 0
      };

      if (isEditMode) {
        final response =
            await BasicProvider('customer/addresses/$editAddressId')
                .patchRequest(body);
        if (_writeFailed(response))
          throw Exception('Address update was not confirmed by the server');
      } else {
        final response =
            await BasicProvider('customer/addresses/add').postRequest(body);
        if (_writeFailed(response))
          throw Exception('Address save was not confirmed by the server');
      }

      // Hide loader before dialog or route navigation
      HelperFunctions().hideOverlayLoader();

      if (Get.isRegistered<AddressListController>()) {
        await Get.find<AddressListController>().refreshAddresses();
      }

      DialogHelper.showSuccessDialog(
        title: isEditMode
            ? "Address Updated Successfully"
            : "Address Saved Successfully",
        description: isEditMode
            ? "Your address details have been successfully updated."
            : "Your delivery address has been saved and added to your address list.",
        imagePath: "assets/images/Illustration.png",
        buttonText: "Continue",
        onPressed: () {
          if (Get.isDialogOpen == true) Get.back();
          Get.back(result: true);
        },
      );
    } catch (e) {
      HelperFunctions().hideOverlayLoader();
      isLoading.value = false;
      debugPrint('Address save failed: $e');
      HelperFunctions()
          .showSnackBarError("Failed to save address. Please try again.");
    } finally {
      HelperFunctions().hideOverlayLoader();
      isLoading.value = false;
    }
  }

  bool _writeFailed(dynamic response) {
    if (response == null) return true;
    if (response is! Map) return false;
    final status = response['status']?.toString().toLowerCase();
    return response['success'] == false ||
        status == 'false' ||
        status == 'error' ||
        status == 'failed' ||
        status == 'failure' ||
        status == '409';
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
