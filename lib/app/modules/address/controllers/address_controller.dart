import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/data/models/region_model.dart';
import 'package:zouhi/app/data/services/region_service.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';
import 'package:zouhi/constants/helper_functions.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AddressController extends GetxController with BaseController {
  var selectAddress = 0.obs;
  var isFormValid = false.obs;

  void validateForm() {
    final nameVal = name.text.trim();
    final mobileVal = mobileNumber.text.replaceAll(RegExp(r'\D'), '');
    final emailVal = email.text.trim();
    final pinVal = pinCode.text.replaceAll(RegExp(r'\D'), '');
    final areaVal = area.text.trim();
    final countryVal = selectedCountry.value?.trim() ?? '';
    final stateVal = selectedState.value?.trim() ?? '';
    final cityVal = city.text.trim();

    final isNameValid = nameVal.isNotEmpty;
    final isMobileValid = mobileVal.length >= 10 && mobileVal.length <= 15;
    final isEmailValid = emailVal.isNotEmpty && GetUtils.isEmail(emailVal);
    final isPinValid = pinVal.isEmpty || pinVal.length <= 8;
    final isAreaValid = areaVal.isNotEmpty;
    final isCountryValid = countryVal.isNotEmpty;
    final isStateValid = stateVal.isNotEmpty;
    final isCityValid = cityVal.isNotEmpty;

    isFormValid.value = isNameValid &&
        isMobileValid &&
        isEmailValid &&
        isPinValid &&
        isAreaValid &&
        isCountryValid &&
        isStateValid &&
        isCityValid;
  }

  var isClicked = false.obs;
  var isCountryLoading = false.obs;
  var isStateLoading = false.obs;
  var isCityLoading = false.obs;
  var isLoading = false.obs;
  var firstloading = 0.obs;
  var addressLoading = false.obs;
  var isCountryChange = false.obs;
  var isStateChange = false.obs;

  // var guestUserAddress = [];
  var guestUserAddress = {};

  var box = GetStorage();

  var isUpdateAddress = false;
  var updateAddressId = '';

  var userAddressList = [].obs;

  var selectAddressType = "Home".obs;
  var selectDefaultAdd = false.obs;

  // Names drive the UI/validation; ids (and the country slug, which the
  // states API is keyed by) are what the backend needs.
  RxnString selectedCountry = RxnString();
  var selectedCountryId = ''.obs;
  var selectedCountrySlug = ''.obs;

  RxnString selectedState = RxnString();
  var selectedStateId = ''.obs;

  RxnString selectedCity = RxnString();
  var cityList = [].obs;

  var shippingDetails = {}.obs;
  var isShippingAvailable = false.obs;

  var pickup_postcode;

  late TextEditingController country,
      name,
      email,
      mobileNumber,
      pinCode,
      flat,
      area,
      landmark,
      city;
  var check = true.obs;
  var updateApi = false.obs;
  var selectedValue = 1.obs;
  var addressType = ''.obs;
  var address = {};
  var isEdit = false.obs;
  late GlobalKey<FormState> formkey;
  CartController cartController = Get.find<CartController>();

  void selectedaddressstype(var address) {
    selectAddressType.value = address;
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onInit() async {
    getCountry();
    country = TextEditingController();
    name = TextEditingController();
    mobileNumber = TextEditingController();
    email = TextEditingController();
    pinCode = TextEditingController();
    flat = TextEditingController();
    area = TextEditingController();
    landmark = TextEditingController();
    city = TextEditingController();

    name.addListener(validateForm);
    mobileNumber.addListener(validateForm);
    email.addListener(validateForm);
    pinCode.addListener(validateForm);
    area.addListener(validateForm);
    landmark.addListener(validateForm);
    city.addListener(validateForm);

    ever(selectedCountry, (_) => validateForm());
    ever(selectedState, (_) => validateForm());
    ever(selectedCity, (_) => validateForm());

    setDefaultUserData();
    check.value = false;
    addressType.value = 'Home';
    formkey = GlobalKey<FormState>();

    await getAddress().then((value) => firstloading.value = 2);

    isShippingAvailable.value = true;
    selectAddress.value = 0;
    super.onInit();
    validateForm();
  }

  var shippingCharges = 0.0;

  Future<void> shippinglogin() async {
    // Deprecated: public/settings/all endpoint is no longer supported by the backend.
    // Shipping availability is enabled by default.
  }

  /// Prefill user details in the address form
  void setDefaultUserData() {
    try {
      var authDetails = AuthDetails.getUserDetails();

      if (authDetails != null) {
        if (authDetails['name'] != null &&
            authDetails['name'].toString().isNotEmpty) {
          name.text = authDetails['name'];
        }

        if (authDetails['email'] != null &&
            authDetails['email'].toString().isNotEmpty) {
          email.text = authDetails['email'];
        }

        if (authDetails['mobile'] != null &&
            authDetails['mobile'].toString().isNotEmpty) {
          mobileNumber.text = authDetails['mobile'];
        }
      }
    } catch (e) {
      print('Error setting default user data: $e');
    }
  }

  void getweight() {
    // print(cartController.otherCartDetails);
  }

  // Future<void> checkShipping({String? pincode}) async {
  //   addressLoading.value = true;
  //   HelperFunctions().showOverlayLoader();

  //   try {
  //     var shippingform = {
  //       'pickup_postcode': shippingDetails['postal_code'],
  //       'delivery_postcode': userAddressList[selectAddress.value]['postal_code'],
  //       // 'weight': cartController.otherCartDetails['weight'],
  //       'weight': 0.5,
  //       'cod': 0,
  //     };

  //     var response2 = await BasicProvider("public/orders/serviceability")
  //         .postRequest(shippingform)
  //         .catchError(handleError);

  //     Get.until((route) => !Get.isDialogOpen!);
  //     firstloading.value = 1;

  //     print(response2);
  //     if (response2 == null) {
  //       isShippingAvailable.value = false;
  //       return;
  //     }

  //     isShippingAvailable.value = response2['is_shipping'];

  //     shippingCharges = double.parse(response2['shipping_charge'].toString());
  //   } catch (e) {
  //     print('shipping details error in address controller $e');
  //   }
  // }

  // ---- Country / state selection (paginated + searchable pickers) ----

  void selectCountry(Region r) {
    if (selectedCountryId.value != r.id) {
      clearState();
    }
    selectedCountry.value = r.name;
    selectedCountryId.value = r.id;
    selectedCountrySlug.value = r.slug;
    isCountryChange.value = true;
  }

  void selectState(Region r) {
    selectedState.value = r.name;
    selectedStateId.value = r.id;
    isStateChange.value = true;
  }

  void clearState() {
    selectedState.value = null;
    selectedStateId.value = '';
    cityList.clear();
    selectedCity.value = null;
  }

  void clearRegions() {
    selectedCountry.value = null;
    selectedCountryId.value = '';
    selectedCountrySlug.value = '';
    clearState();
  }

  /// Prefill from a saved address (`country`/`state` are `{_id, name}` maps).
  void setRegionsFromAddress(Map address) {
    clearRegions();
    final c = address['country'];
    if (c is Map) {
      selectedCountry.value = Region.cleanName(c['name']);
      selectedCountryId.value = (c['_id'] ?? c['id'] ?? '').toString();
      selectedCountrySlug.value = (c['slug'] ?? '').toString();
    }
    final st = address['state'];
    if (st is Map) {
      selectedState.value = Region.cleanName(st['name']);
      selectedStateId.value = (st['_id'] ?? st['id'] ?? '').toString();
    }
  }

  Future<RegionPage> loadCountries(int page, String search) =>
      RegionService.fetchCountries(page: page, search: search);

  Future<RegionPage> loadStates(int page, String search) async {
    await ensureCountrySlug();
    return RegionService.fetchStates(
        countrySlug: selectedCountrySlug.value, page: page, search: search);
  }

  /// The states API is keyed by country slug; saved addresses only carry
  /// `{_id, name}`, so look the slug up by name when it is missing.
  Future<void> ensureCountrySlug() async {
    if (selectedCountrySlug.value.isNotEmpty) return;
    final name = selectedCountry.value;
    if (name == null || name.isEmpty) return;
    final page = await RegionService.fetchCountries(search: name);
    final match = page.items.firstWhereOrNull(
            (r) => r.id == selectedCountryId.value) ??
        page.items.firstWhereOrNull(
            (r) => r.name.toLowerCase() == name.toLowerCase());
    if (match != null) selectedCountrySlug.value = match.slug;
  }

  Future<void> getCity({required String id}) async {
    isCityLoading.value = true;
    try {
      // Disabled: Cities API calls commented out
      /*
      var response = await BasicProvider("cities/$id")
          .getRequest()
          .catchError(handleError);

      if (response == null) return;
      cityList.clear();
      if (response['data'] is List) {
        final uniqueItems = <String, dynamic>{};
        for (var item in response['data']) {
          final name = item['name']?.toString().trim();
          if (name != null && name.isNotEmpty) {
            uniqueItems[name] = item;
          }
        }
        cityList.assignAll(sortByName(uniqueItems.values.toList()));
      }
      */
      cityList.clear();

      if (isUpdateAddress) {
        if (isStateChange.value && cityList.isNotEmpty) {
          selectedCity.value = cityList[0]['name']?.toString();
        }
      } else {
        // Don't auto-select first city for new addresses — show placeholder
        selectedCity.value = null;
      }

      isCityLoading.value = false;
    } catch (e) {
      isCityLoading.value = false;
      print('address city error $e');
    }
  }

  /// Defaults a new address to India, like the website. Safe to call
  /// repeatedly: it never overrides an existing or edited selection.
  Future<void> getCountry() async {
    if (isUpdateAddress || selectedCountryId.value.isNotEmpty) return;
    try {
      isCountryLoading.value = true;
      final page = await RegionService.fetchCountries(search: 'india');
      final india = page.items.firstWhereOrNull((r) => r.slug == 'india');
      if (india != null &&
          !isUpdateAddress &&
          selectedCountryId.value.isEmpty) {
        selectCountry(india);
        isCountryChange.value = false;
      }
    } catch (e) {
      print('address default country error $e');
    } finally {
      isCountryLoading.value = false;
    }
  }

  List<Region>? _allCountriesCache;
  final Map<String, List<Region>> _statesByCountrySlug = {};

  /// Fills in `{_id, name}` for addresses whose country/state came back as a
  /// bare id. The lookups only run when such an address exists.
  Future<void> resolveAddressesNames(List<dynamic> addresses) async {
    try {
      for (var address in addresses) {
        if (address is! Map) continue;

        String countryId = '';
        String countrySlug = '';
        final countryVal = address['country'];
        if (countryVal is Map) {
          countryId = countryVal['_id']?.toString() ?? '';
          countrySlug = countryVal['slug']?.toString() ?? '';
        } else if (countryVal is String && countryVal.isNotEmpty) {
          countryId = countryVal;
          _allCountriesCache ??= await RegionService.fetchAll(
              (p) => RegionService.fetchCountries(page: p));
          final match =
              _allCountriesCache!.firstWhereOrNull((r) => r.id == countryId);
          if (match != null) {
            countrySlug = match.slug;
            address['country'] = {
              '_id': match.id,
              'name': match.name,
              'slug': match.slug
            };
          }
        }

        final stateVal = address['state'];
        if (stateVal is String && stateVal.isNotEmpty && countrySlug.isNotEmpty) {
          final states = _statesByCountrySlug[countrySlug] ??=
              await RegionService.fetchAll((p) => RegionService.fetchStates(
                  countrySlug: countrySlug, page: p));
          final match = states.firstWhereOrNull((r) => r.id == stateVal);
          if (match != null) {
            address['state'] = {'_id': match.id, 'name': match.name};
          }
        }
      }
    } catch (e) {
      print('Error resolving address names: $e');
    }
  }

  /// The backend sends `is_default` as true, 1 or "1" depending on the route.
  static bool isDefaultFlag(dynamic value) =>
      value == true || value == 1 || value == '1' || value == 'true';

  Future<void> getAddress() async {
    try {
      isLoading.value = true;
      addressLoading.value = true;
      if (AuthDetails.isUserLogin()) {
        var response = await BasicProvider("customer/addresses")
            .getRequest()
            .catchError(handleError);
        print('adress $response');
        if (response == null) {
          addressLoading.value = false;
          isLoading.value = false;
          return;
        }

        if (response is List) {
          await resolveAddressesNames(response);
        }

        userAddressList.clear();
        userAddressList.addAll(response);
        isLoading.value = false;
        addressLoading.value = false;

        selectAddress.value = 0;
        for (var i = 0; i < userAddressList.length; i++) {
          if (isDefaultFlag(userAddressList[i]['is_default'])) {
            selectAddress.value = i;
            update();
            return;
          }
        }
        update();
      } else {
        // guestUserAddress = box.read('guestUserAddress') ?? [];
        // print(guestUserAddress);
        // userAddressList.clear();
        // userAddressList.addAll(guestUserAddress);
        // update();
        // isLoading.value = false;
      }
    } catch (e) {
      isLoading.value = false;
      addressLoading.value = false;
      print('get addreess error $e');
    }
  }

  void removeAddress({required String id, required int index}) async {
    try {
      if (AuthDetails.isUserLogin()) {
        // Backend contract (as used by the template app): POST with empty body.
        var response = await BasicProvider("customer/addresses/$id")
            .postRequest({}).catchError(handleError);
        if (response == null) return;

        userAddressList.removeAt(index);
        // Keep the selection on the same address (or clamp it into range).
        if (index < selectAddress.value) {
          selectAddress.value -= 1;
        } else if (selectAddress.value >= userAddressList.length) {
          selectAddress.value = 0;
        }
        update();
      } else {
        // guestUserAddress.removeAt(index);
        // userAddressList.removeAt(index);
      }
    } catch (e) {
      print('remvoe addreess error $e');
    }
  }

  Future<void> addAddress() async {
    try {
      if (formkey.currentState!.validate()) {
        isLoading.value = true;
        if (AuthDetails.isUserLogin()) {
          var form = {
            'name': name.text,
            'email': email.text,
            'mobile': mobileNumber.text,
            'street': area.text,
            'landmark': landmark.text,
            // 'customer_id': Get.find<BottomNavigationBarController>().authDetails['id'],
            'country': selectedCountryId.value,
            'state': selectedStateId.value,
            'city': city.text,
            'postal_code': pinCode.text,
            'address_type': selectAddressType.value,
            'is_default': selectDefaultAdd.value == true ? 1 : 0
          };

          print("Address form data output: $form");

          var response = await BasicProvider("customer/addresses/add")
              .postRequest(form)
              .catchError(handleError);
          isLoading.value = false;
          if (response == null) return; // keep the form open on failure
          getAddress();
          // HelperFunctions().showSnackBarSuccess("Address added successfully!");

          // await Future.delayed(const Duration(seconds: 1), () {
          //   // print('go back');
          //   Get.back();
          //   Get.back();
          // });
          Get.back();
          // Get.back();
        } else {
          // var form = {
          //   'name': name.text,
          //   'email': email.text,
          //   'mobile': mobileNumber.text,
          //   'house_no': flat.text,
          //   'address': area.text,
          //   'landmark': landmark.text,
          //   // 'customer_id': Get.find<BottomNavigationBarController>().authDetails['id'],
          //   // 'country': selectedCountryId.value,

          //   'country': {
          //     '_id': selectedCountryId.value,
          //     'name': selectedCountry.value
          //   },

          //   'state': {
          //     '_id': selectedStateId.value,
          //     'name': selectedState.value
          //   },

          //   'city': {
          //     '_id': getCityId(selectedCity.value),
          //     'name': selectedCity.value
          //   },
          //   // 'state': selectedStateId.value,
          //   // 'city': getCityId(selectedCity.value),
          //   'pincode': pinCode.text,
          //   'address_type': selectAddressType.value,
          //   'is_default': 1
          // };
          // guestUserAddress = box.read('guestUserAddress') ?? [];
          // guestUserAddress.addIf(!guestUserAddress.contains(form), form);
          // box.write('guestUserAddress', guestUserAddress);
          // getAddress();
        }
      }
    } catch (e) {
      isLoading.value = false;
      print('add address $e');
    }
  }

  Future updateAddress({required String id}) async {
    try {
      isLoading.value = true;
      addressLoading.value = true;
      var form = {
        'name': name.text,
        'email': email.text,
        'mobile': mobileNumber.text,
        'street': area.text,
        'landmark': landmark.text,
        'country': selectedCountryId.value,
        'state': selectedStateId.value,
        'city': city.text,
        'postal_code': pinCode.text,
        'address_type': selectAddressType.value,
        'is_default': selectDefaultAdd.value == true ? 1 : 0
      };

      if (AuthDetails.isUserLogin()) {
        var response = await BasicProvider("customer/addresses/$id")
            .patchRequest(form)
            .catchError(handleError);
        addressLoading.value = false;
        if (response == null) {
          isLoading.value = false;
          return; // keep the form open on failure
        }
        isLoading.value = false;
        getAddress();
        isUpdateAddress = false;
        addressLoading.value = false;

        Get.back();
        //checkShipping();
      } else {
        // var index = guestUserAddress.indexWhere((item) => item['id'] == id);
        // if (index != -1) {
        //   guestUserAddress[index] = form;
        // } else {
        //   guestUserAddress.add(form);
        //   getAddress();
        // }
      }
      // Get.back();
    } catch (e) {
      isLoading.value = false;
      addressLoading.value = false;
      print('update addreess error $e');
    }
  }

  Future<void> getAddressbyId({required String id}) async {
    try {
      var response = await BasicProvider("customer/addresses/$id")
          .getRequest()
          .catchError(handleError);
      if (response == null) return;

      printInfo(info: 'response f------ $response');

      name.text = response['name']?.toString() ?? '';
      email.text = response['email']?.toString() ?? '';
      mobileNumber.text = response['mobile']?.toString() ?? '';
      landmark.text = response['landmark']?.toString() ?? '';
      area.text = response['street']?.toString() ??
          response['address']?.toString() ??
          area.text;
      flat.text = response['house_no']?.toString() ?? '';
      pinCode.text = response['pincode']?.toString() ??
          response['postal_code']?.toString() ??
          '';
      setRegionsFromAddress(response);
      selectAddressType.value = response['address_type']?.toString() ?? 'Home';
      city.text = response['city'] is Map
          ? (response['city']['name']?.toString() ?? '')
          : (response['city']?.toString() ?? '');
      selectedCity.value = response['city']?['name']?.toString();
    } catch (e) {
      print('get addreess by id error $e');
    }
  }
}


  // var dropdownvalue = 'New Zealand'.obs;
  // var country = [
  //   'New Zealand',
  //   'Australia',
  //   'England',
  // ].obs;

  // var dropdoForState = 'Select State'.obs;
  // var statelist = [
  //   'Select State',
  //   'Madhya Pradesh',
  //   'Uttar Pradesh',
  // ];

