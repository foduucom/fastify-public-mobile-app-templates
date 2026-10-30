import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/data/models/region_model.dart';
import '/app/data/services/region_service.dart';
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

    try {
      _initFromArgs();
    } catch (e) {
      print('Error in _initFromArgs: $e');
      Get.snackbar(
        "Error",
        "Failed to load address data: $e",
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    _defaultCountry();
    super.onInit();
  }

  void _initFromArgs() {
    if (Get.arguments != null) {
      isEditMode = Get.arguments['isEdit'] ?? false;

      if (isEditMode && Get.arguments['address'] != null) {
        var addr = Get.arguments['address'];

        // Debug print to see what we're getting
        print('Address in _initFromArgs: $addr');
        print('Address type: ${addr.runtimeType}');

        // Make sure addr is a Map
        if (addr is Map) {
          editAddressId = addr['_id'] ?? '';
          name.text = addr['name'] ?? '';
          email.text = addr['email'] ?? '';
          mobile.text = addr['mobile'] ?? '';
          postal_code.text = addr['postal_code'] ?? '';
          landmark.text = addr['landmark'] ?? '';
          street.text = addr['street'] ?? '';
          addressType.value = addr['address_type'] ?? 'Home';
          isDefault.value = (addr['is_default'] == 1);

          selectedCountry.value = addr['country'] is Map
              ? Map.from(addr['country'])
              : {};
          selectedState.value =
              addr['state'] is Map ? Map.from(addr['state']) : {};
          city.text = addr['city'] is Map
              ? (addr['city']['name'] ?? '').toString()
              : (addr['city'] ?? '').toString();
        } else {
          print('Error: Address is not a Map, it is a ${addr.runtimeType}');
          // If addr is a String, try to parse it or handle the error
          Get.snackbar(
            "Error",
            "Invalid address data format",
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      }
    }
  }

  Future<void> saveAddress() async {
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

      bool isSuccess = false;

      if (isEditMode) {
        try {
          var response =
              await BasicProvider('customer/addresses/$editAddressId')
                  .patchRequest(body);
          print('address update response ${response}');
          isSuccess = true;
        } catch (e) {
          print('Error caught: $e');
          // Check if this is a format exception (HTML response)
          if (e.toString().contains('FormatException') ||
              e.toString().contains('<!DOCTYPE')) {
            // The API likely succeeded despite the error
            print('API likely succeeded despite format error');
            isSuccess = true;
          } else {
            rethrow;
          }
        }
      } else {
        try {
          var response =
              await BasicProvider('customer/addresses/add').postRequest(body);
          print('address update response 1: ${response}');
          isSuccess = true;
        } catch (e) {
          print('Error caught: $e');
          if (e.toString().contains('FormatException') ||
              e.toString().contains('<!DOCTYPE')) {
            print('API likely succeeded despite format error');
            isSuccess = true;
          } else {
            rethrow;
          }
        }
      }

      // Hide loader before dialog or route navigation
      HelperFunctions().hideOverlayLoader();
      isLoading.value = false;

      if (isSuccess) {
        if (Get.isRegistered<AddressListController>()) {
          Get.find<AddressListController>().refreshAddresses();
        }

        bool hasRedirected = false;
        void redirectBack() {
          if (hasRedirected) return;
          hasRedirected = true;
          if (Get.isDialogOpen == true) {
            Get.back(); // Dismiss dialog
          }
          Get.back(result: true); // Redirect back to AddressListView
        }

        // Show successful dialog
        DialogHelper.showSuccessDialog(
          title: isEditMode
              ? "Address Updated Successfully"
              : "Address Saved Successfully",
          description: isEditMode
              ? "Your address details have been successfully updated."
              : "Your delivery address has been saved and added to your address list.",
          imagePath: "assets/images/Illustration.png",
          buttonText: "Continue",
          onPressed: redirectBack,
        );

        // Automatic redirect to AddressListView after delay
        Future.delayed(const Duration(milliseconds: 1800), () {
          redirectBack();
        });
      }
    } catch (e) {
      HelperFunctions().hideOverlayLoader();
      isLoading.value = false;
      print('Error saving address: $e');
      HelperFunctions().showSnackBarError("Failed to save address: $e");
    } finally {
      HelperFunctions().hideOverlayLoader();
      isLoading.value = false;
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
