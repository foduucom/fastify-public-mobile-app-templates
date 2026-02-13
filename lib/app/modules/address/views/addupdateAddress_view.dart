// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/address/controllers/address_controller.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';

import 'package:foduu_ecommerce/components/buttons/filterbutton.dart';
import 'package:foduu_ecommerce/components/foduuformtextfield.dart';
import 'package:foduu_ecommerce/components/form_field.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';

import 'package:get/get.dart';

class AddUpdateAddress extends GetView<AddressController> {
  AddUpdateAddress({Key? key}) : super(key: key);

  // var controller = Get.find<AddressController>();
  var addess = Get.put(AddressController());

  @override
  Widget build(BuildContext context) {
    // controller.getCountry();
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: SafeArea(
        child: Scaffold(
            appBar: AppBar(
              title: Text('Add  a new address',
                  style: txtTheme().headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold, fontFamily: "Lato")),
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              // backgroundColor: Colors.transparent,
              elevation: 0,
            ),
            body: Stack(
              children: [
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: pageSurroundingPadding,
                          child: Form(
                            key: controller.formkey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Obx(() =>
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 0.0, 0.0, 0.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 1),
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(3.0),
                                  ),
                                  child: Obx(
                                    () => controller.isCountryLoading.value
                                        ? HelperFunctions().loadingIndicator()
                                        : DropdownButton<String>(
                                            underline: Container(),
                                            hint: const Text('Select Country'),
                                            isExpanded: true,
                                            elevation: 8,
                                            icon: const Icon(Icons
                                                .keyboard_arrow_down_rounded),
                                            // focusColor: themePrimaryColor,
                                            padding: EdgeInsets.only(left: 13),
                                            style: const TextStyle(
                                                // color: themeTextColor,
                                                fontSize: 15.0,
                                                // fontWeight: FontWeight.w500,
                                                fontFamily: 'lato'),
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(18.0)),
                                            items: controller.countryDataList
                                                .map((value) {
                                              return DropdownMenuItem<String>(
                                                value: value['name'],
                                                child: Text(value['name']),
                                              );
                                            }).toList(),
                                            onChanged: (values) {
                                              controller.isCountryChange.value =
                                                  true;
                                              // controller.stateli
                                              // controller.stateList.clear();

                                              controller.selectedCountry.value =
                                                  values.toString();

                                              controller.getState(
                                                  id: controller
                                                      .getCountryId(values!));
                                            },
                                            value: controller
                                                .selectedCountry.value,
                                          ),
                                  ),
                                  // ),
                                ),
                                const SizedBox(height: 10),
                                FoduuFormTextField(
                                  fieldHintText: "Full Name",
                                  controller: controller.name,
                                  validationmsg: 'Enter name',
                                  title: 'Full Name',
                                  validCheck: (p0) {
                                    if (p0!.isEmpty) {
                                      return 'Enter Name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                FoduuFormTextField(
                                  fieldHintText: "Mobile Number",
                                  controller: controller.mobileNumber,
                                  keyType: TextInputType.number,
                                  // textlength: 10,
                                  title: 'Mobile Number',
                                  validationmsg: 'Enter Valid Mobile Number',
                                  validCheck: (p0) {
                                    if (p0!.isEmpty || p0.length != 10) {
                                      return 'Enter Valid Mobile Number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                FoduuFormTextField(
                                  fieldHintText: "Email",
                                  controller: controller.email,
                                  keyType: TextInputType.emailAddress,
                                  title: 'Email',
                                  validationmsg: 'Enter Valid Email',
                                  validCheck: (p0) {
                                    if (!p0!.isEmail) {
                                      return 'Enter Valid Email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                FoduuFormTextField(
                                  title: 'Pin Code',
                                  fieldHintText: "Pin Code",
                                  controller: controller.pinCode,
                                  keyType: TextInputType.number,
                                  validationmsg: 'Enter valid Pin code',
                                  validCheck: (p0) {
                                    if (p0!.isEmpty || p0.length != 6) {
                                      return 'Enter Valid Pin Code';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                FoduuFormTextField(
                                  title: 'Flat, House No',
                                  fieldHintText: "Flat, House No",
                                  controller: controller.flat,
                                  validationmsg: '',
                                  validCheck: (p0) {
                                    if (p0!.isEmpty) {
                                      return 'Enter Flat, Hourse No';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                FoduuFormTextField(
                                  title: 'Area, Colony, Street',
                                  fieldHintText: "Area, Colony, Street",
                                  controller: controller.area,
                                  validationmsg: '',
                                  validCheck: (p0) {
                                    if (p0!.isEmpty) {
                                      return 'Enter Area, Colony ,Street';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                FoduuFormTextField(
                                  title: 'Landmark',
                                  fieldHintText: "Landmark",
                                  controller: controller.landmark,
                                  validationmsg: '',
                                  validCheck: (p0) {
                                    if (p0!.isEmpty) {
                                      return 'Enter Landmark';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),

                                //////////////////////////////////////////////

                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 0.0, 0.0, 0.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                    ),
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(3.0),
                                  ),
                                  child: Obx(() => controller
                                          .isStateLoading.value
                                      ? HelperFunctions().loadingIndicator()
                                      : DropdownButton<String>(
                                          underline: Container(),
                                          hint: const Text('Select State'),
                                          isExpanded: true,
                                          onTap: () {
                                            if (controller
                                                .selectedCountry!.isEmpty) {
                                              Get.showSnackbar(GetSnackBar(
                                                message: 'select country first',
                                              ));
                                            }
                                          },
                                          elevation: 8,
                                          icon: const Icon(Icons
                                              .keyboard_arrow_down_rounded),
                                          // focusColor: themePrimaryColor,
                                          padding: EdgeInsets.only(left: 13),
                                          style: const TextStyle(
                                              // color: themeTextColor,
                                              fontSize: 15.0,
                                              fontFamily: 'lato'),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(18.0)),
                                          items:
                                              controller.stateList.map((value) {
                                            return DropdownMenuItem<String>(
                                              value: value['name'],
                                              child: Text(value['name']),
                                            );
                                          }).toList(),
                                          value: controller.selectedState.value,
                                          onChanged: (values) {
                                            controller.selectedState.value =
                                                values.toString();
                                            controller.getCity(
                                                id: controller
                                                    .getStateId(values!));
                                          },
                                        )),
                                ),

                                const SizedBox(height: 15),

                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 0.0, 0.0, 0.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                    ),
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(3.0),
                                  ),
                                  child: Obx(() => controller
                                          .isCityLoading.value
                                      ? HelperFunctions().loadingIndicator()
                                      : DropdownButton<String>(
                                          underline: Container(),
                                          hint: const Text('Select Town/City'),
                                          isExpanded: true,
                                          onTap: () {
                                            if (controller
                                                .selectedCountry!.isEmpty) {
                                              Get.showSnackbar(GetSnackBar(
                                                message: 'select State first',
                                              ));
                                            }
                                          },
                                          elevation: 8,
                                          icon: const Icon(Icons
                                              .keyboard_arrow_down_rounded),
                                          // focusColor: themePrimaryColor,
                                          padding: EdgeInsets.only(left: 13),
                                          style: const TextStyle(
                                              // color: themeTextColor,
                                              fontSize: 15.0,
                                              fontFamily: 'lato'),
                                          borderRadius: const BorderRadius.all(
                                              Radius.circular(18.0)),
                                          items:
                                              controller.cityList.map((value) {
                                            return DropdownMenuItem<String>(
                                              value: value['name'],
                                              child: Text(value['name']),
                                            );
                                          }).toList(),
                                          onChanged: (values) {
                                            controller.selectedCity.value =
                                                values.toString();
                                            // controller.getCity(
                                            //   id: controller.getStateId(values!));
                                          },
                                          value: controller.selectedCity.value,
                                        )),
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 10,
                          // color: themegreyColor,
                        ),
                        Padding(
                          padding: pageSurroundingPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text('Type Of Address',
                                  style: txtTheme().titleLarge!.copyWith(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Obx(() {
                                        return Radio(
                                          value: "Home",
                                          groupValue: controller
                                              .selectAddressType.value,
                                          onChanged: (val) {
                                            controller
                                                .selectedaddressstype(val);
                                          },
                                          // activeColor: themeRedColor,
                                        );
                                      }),
                                      const Text('Home',
                                          style: TextStyle(
                                              fontFamily: 'lato',
                                              // color: themeTextColor,
                                              fontSize: 16))
                                    ],
                                  ),
                                  const SizedBox(width: 15),
                                  Row(
                                    children: [
                                      Obx(() {
                                        return Radio(
                                          value: "office",
                                          groupValue: controller
                                              .selectAddressType.value,
                                          onChanged: (val) {
                                            controller
                                                .selectedaddressstype(val);
                                          },
                                          // activeColor: themeRedColor,
                                        );
                                      }),
                                      const Text('office',
                                          style: TextStyle(
                                              fontFamily: 'lato',
                                              // color: themeTextColor,
                                              fontSize: 16))
                                    ],
                                  ),
                                  const SizedBox(width: 15),
                                  Row(
                                    children: [
                                      Obx(() {
                                        return Radio(
                                          value: "others",
                                          groupValue: controller
                                              .selectAddressType.value,
                                          onChanged: (val) {
                                            controller
                                                .selectedaddressstype(val);
                                          },
                                          // activeColor: themeRedColor,
                                        );
                                      }),
                                      const Text('others',
                                          style: TextStyle(
                                              fontFamily: 'lato',
                                              // color: themeTextColor,
                                              fontSize: 16))
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  child: Obx(() {
                                    return CheckboxListTile(
                                      // activeColor: themeRedColor,
                                      value: controller.selectDefaultAdd.value,
                                      onChanged: (value) {
                                        controller.selectDefaultAdd.value =
                                            !controller.selectDefaultAdd.value;
                                      },
                                      title: const Text(
                                        'Make Default Address ',
                                        style: TextStyle(
                                          fontFamily: 'lato',
                                          // color: themeTextColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  }))
                            ],
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
                filterButton(
                  reset: 'RESET',
                  filter: controller.isUpdateAddress
                      ? 'Update Address'
                      : 'Add Address',
                  pressEvnetFilter: () async {
                    if (controller.formkey.currentState!.validate() &&
                        controller.selectedCountry.isNotEmpty &&
                        controller.selectedState.isNotEmpty &&
                        controller.selectedCity.isNotEmpty) {
                      if (AuthDetails.isUserLogin()) {
                        if (controller.isUpdateAddress) {
                          controller.updateAddress(
                              id: controller.updateAddressId);
                        } else {
                          await controller.addAddress().then((value) {});
                        }
                      } else {
                        HelperFunctions().showOverlayLoader();
                        await controller
                            .checkShipping(pincode: controller.pinCode.text)
                            .then((value) =>
                                Get.until((route) => !Get.isDialogOpen!));
                        if (controller.shippingDetails['is_shipping']) {
                          var form = {
                            'name': controller.name.text,
                            'email': controller.email.text,
                            'mobile': controller.mobileNumber.text,
                            'house_no': controller.flat.text,
                            'address': controller.area.text,
                            'landmark': controller.landmark.text,
                            'country': controller
                                .getCountryId(controller.selectedCountry.value),
                            'state': controller
                                .getStateId(controller.selectedState.value),
                            'city': controller
                                .getCityId(controller.selectedCity.value),
                            'pincode': controller.pinCode.text,
                          };
                          Get.toNamed(Routes.PAYMENT,
                              arguments: {'guestUserAddress': form});
                        } else {
                          HelperFunctions().showSnackBarError(
                              'Shipping not availabe on this pincode code');
                        }
                      }
                    } else {
                      Get.showSnackbar(GetSnackBar(
                        message: 'Please Enter/Select all Filed',
                      ));
                    }
                  },
                  pressEvnetReset: () {
                    controller.name.text = '';
                    controller.mobileNumber.text = '';
                    controller.pinCode.text = '';
                    controller.flat.text = '';
                    controller.area.text = '';
                    controller.landmark.text = '';
                    controller.email.text = '';
                  },
                )
              ],
            )),
      ),
    );
  }
}
