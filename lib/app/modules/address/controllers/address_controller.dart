import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class AddressController extends GetxController with BaseController {
  var selectAddress = 0.obs;
  var isClicked = false.obs;
  var isCountryLoading = false.obs;
  var isStateLoading = false.obs;
  var isCityLoading = false.obs;
  var isLoading = false.obs;
  var firstloading = 0.obs;
  var addressLoading = false.obs;
  var isCountryChange = false.obs;
  // var guestUserAddress = [];
  var guestUserAddress = {};

  var box = GetStorage();

  var isUpdateAddress = false;
  var updateAddressId = '';

  var userAddressList = [].obs;

  var selectAddressType = "".obs;
  var selectDefaultAdd = false.obs;

  var countryDataList = [].obs;
  var selectedCountry = ''.obs;

  RxString selectedState = ''.obs;
  var stateList = [].obs;

  var selectedCity = ''.obs;
  var cityList = [].obs;

  var shippingDetails = {}.obs;
  var pickup_postcode;

  late TextEditingController country,
      name,
      email,
      mobileNumber,
      pinCode,
      flat,
      area,
      landmark;
  var check = true.obs;
  var updateApi = false.obs;
  var selectedValue = 1.obs;
  var addressType = ''.obs;
  var address = {};
  var isEdit = false.obs;
  late GlobalKey<FormState> formkey;

  void selectedaddressstype(var address) {
    selectAddressType.value = address;
  }

  @override
  void onInit() async {
    country = TextEditingController();
    name = TextEditingController();
    mobileNumber = TextEditingController();
    email = TextEditingController();
    pinCode = TextEditingController();
    flat = TextEditingController();
    area = TextEditingController();
    landmark = TextEditingController();
    check.value = false;
    addressType.value = 'Home';
    formkey = GlobalKey<FormState>();
    getCountry();
    await getAddress().then((value) => firstloading.value = 2);
    if (userAddressList.isNotEmpty) {
      checkShipping();
    }
    // checkShipping();
    // countryList.removeDuplicates();
    super.onInit();
  }

  Future<void> checkShipping({String? pincode}) async {
    addressLoading.value = true;
    HelperFunctions().showOverlayLoader();
    try {
      shippingDetails.value = {"is_shipping": true};
      var response = await BasicProvider("public/shipping-detail")
          .getRequest()
          .catchError(handleError);

      if (response == null) return;
      pickup_postcode = response['value']['pincode'];
      var form = FormData({
        "pickup_postcode": '452014', //change
        "delivery_postcode":
            pincode ?? userAddressList[selectAddress.value]['pincode'],
        "weight": Get.find<CartController>().otherCartDetails['weight'],
        "cod": 0
      });

      print('<<<><><>< ${userAddressList[selectAddress.value]['pincode']}');

      var response2 = await BasicProvider("public/orders/serviceability")
          .postRequest(form)
          .catchError(handleError);

      if (response == null) return;
      shippingDetails.value = response2;
      addressLoading.value = false;
      firstloading.value = 1;
      Get.until((route) => !Get.isDialogOpen!);
      // checkShipping.value = response;
    } catch (e) {
      print('shipping details error in address controller $e');
    }
  }

  String getCityId(String cityname) {
    String id = '';
    for (var i = 0; i < cityList.length; i++) {
      if (cityname.toString().trim() == cityList[i]['name'].toString().trim()) {
        id = cityList[i]['_id'];
        break;
      }
    }
    // getCity(id: id);
    return id;
  }

  String getStateId(String stateName) {
    String id = '';
    for (var i = 0; i < stateList.length; i++) {
      if (stateName.toString().trim() ==
          stateList[i]['name'].toString().trim()) {
        id = stateList[i]['_id'];
        break;
      }
    }
    // getState(id: id);
    return id;
  }

  String getCountryId(String countryName) {
    String id = '';
    for (var i = 0; i < countryDataList.length; i++) {
      if (countryName.toString().trim() ==
          countryDataList[i]['name'].toString().trim()) {
        id = countryDataList[i]['_id'];
        break;
      }
    }
    // getState(id: id);
    return id;
  }

  void getCity({required String id}) async {
    isCityLoading.value = true;
    try {
      var response = await BasicProvider("frontend/region/get-city/$id")
          .getRequest()
          .catchError(handleError);

      if (response == null) return;
      cityList.clear();
      cityList.addAll(response['data']);
      cityList.assignAll(cityList.toSet().toList());
      selectedCity.value = cityList[0]['name'];

      isCityLoading.value = false;
    } catch (e) {
      isCityLoading.value = false;
      print('address city error $e');
    }
  }

  void getState({required String id}) async {
    try {
      isStateLoading.value = true;

      var response = await BasicProvider("frontend/region/get-state/$id")
          .getRequest()
          .catchError(handleError);

      if (response == null) return;
      stateList.clear();
      stateList.addAll(response['data']);
      stateList.assignAll(stateList.toSet().toList());
      print('state list ${stateList}');

      if (isUpdateAddress) {
        if (isCountryChange.value && stateList.isNotEmpty) {
          selectedState.value = stateList[0]['name'];
          getCity(id: stateList[0]['_id']);
        }
      } else {
        if (stateList.isNotEmpty) {
          print(stateList.length);
          selectedState.value = stateList[0]['name'];
          getCity(id: stateList[0]['_id']);
        }
      }

      isStateLoading.value = false;
    } catch (e) {
      isStateLoading.value = false;

      print('address state error $e');
    }
  }

  Future<dynamic> getCountry() async {
    try {
      isCountryLoading.value = true;
      var response = await BasicProvider("frontend/region/get-country")
          .getRequest()
          .catchError(handleError);

      if (response == null) return;

      countryDataList.clear();
      countryDataList.addAll(response['data']);
      countryDataList.assignAll(countryDataList.toSet().toList());
      cityList.value = [];

      if (!isUpdateAddress) {
        selectedCountry.value = countryDataList[0]['name'];
        getState(id: countryDataList[0]['_id']);
      }
      isCountryLoading.value = false;
    } catch (e) {
      print('address countryerror $e');
    }
  }

  Future<void> getAddress() async {
    try {
      isLoading.value = true;
      addressLoading.value = true;
      if (AuthDetails.isUserLogin()) {
        var response = await BasicProvider("public/customer/address")
            .getRequest()
            .catchError(handleError);
        print('adress $response');
        addressLoading.value = false;
        isLoading.value = false;
        if (response == null) return;

        userAddressList.clear();
        userAddressList.addAll(response['data']);
        isLoading.value = false;
        addressLoading.value = false;

        selectAddress.value = 0;
        for (var i = 0; i < userAddressList.length; i++) {
          if (1 == userAddressList[i]['is_default']) {
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

      print('get addreess error $e');
    }
  }

  void removeAddress({required String id, required int index}) async {
    try {
      var form = {
        'ids': [id]
      };

      if (AuthDetails.isUserLogin()) {
        var response =
            await BasicProvider("public/customer/address/multi/delete")
                .postRequest(form)
                .catchError(handleError);
        if (response == null) return;

        userAddressList.removeAt(index);
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
            'house_no': flat.text,
            'address': area.text,
            'landmark': landmark.text,
            // 'customer_id': Get.find<BottomNavigationBarController>().authDetails['id'],
            'country': getCountryId(selectedCountry.value),
            'state': getStateId(selectedState.value),
            'city': getCityId(selectedCity.value),
            'pincode': pinCode.text,
            'address_type': selectAddressType.value,
            'is_default': selectDefaultAdd.value == true ? 1 : 0
          };
          var response = await BasicProvider("public/customer/address/create")
              .postRequest(form)
              .catchError(handleError);
          isLoading.value = false;
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
          //   // 'country': getCountryId(selectedCountry.value),

          //   'country': {
          //     '_id': getCountryId(selectedCountry.value),
          //     'name': selectedCountry.value
          //   },

          //   'state': {
          //     '_id': getStateId(selectedState.value),
          //     'name': selectedState.value
          //   },

          //   'city': {
          //     '_id': getCityId(selectedCity.value),
          //     'name': selectedCity.value
          //   },
          //   // 'state': getStateId(selectedState.value),
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
        'house_no': flat.text,
        'address': area.text,
        'landmark': landmark.text,
        'country': getCountryId(selectedCountry.value),
        'state': getStateId(selectedState.value),
        'city': getCityId(selectedCity.value),
        'pincode': pinCode.text,
        'address_type': selectAddressType.value,
        'is_default': selectDefaultAdd.value == true ? 1 : 0
      };

      if (AuthDetails.isUserLogin()) {
        var response = await BasicProvider("public/customer/address/update/$id")
            .patchRequest(form)
            .catchError(handleError);
        addressLoading.value = false;
        if (response == null) return;
        isLoading.value = false;
        getAddress();
        isUpdateAddress = false;
        addressLoading.value = false;

        Get.back();
        checkShipping();
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
      print('update addreess error $e');
    }
  }

  Future<void> getAddressbyId({required String id}) async {
    try {
      var response = await BasicProvider("public/customer/address/show/$id")
          .getRequest()
          .catchError(handleError);
      if (response == null) return;
      name.text = response['name'];
      email.text = response['email'];
      mobileNumber.text = response['mobile'];
      landmark.text = response['landmark'];
      // address.text = response['address'];
      flat.text = response['house_no'];
      pinCode.text = response['pincode'];
      selectedCountry = response['country']['name'];
      selectedState = response['state']['name'];
      selectedCity = response['city']['name'];
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

