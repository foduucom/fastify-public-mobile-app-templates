// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zouhi/app/modules/address/controllers/address_controller.dart';
import 'package:zouhi/app/modules/address/widgets/region_picker_sheet.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/cart/controllers/cart_controller.dart';

import 'package:zouhi/components/buttons/filterbutton.dart';
import 'package:zouhi/components/form_field.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';

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
              title: Text('Add a new address',
                  style: txtTheme().headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold, fontFamily: 'Poppins')),
              iconTheme: IconThemeData(
                color: context.themeTextColor,
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
                                AppFormTextField(
                                  fieldHintText: "Full Name",
                                  controller: controller.name,
                                  onsaved: (val) {},
                                  validationmsg: 'Enter name',
                                  validCheck: (p0) {
                                    if (p0!.isEmpty) {
                                      return 'Enter Name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                AppFormTextField(
                                  fieldHintText: "Mobile Number",
                                  controller: controller.mobileNumber,
                                  keyType: TextInputType.number,
                                  onsaved: (val) {},
                                  maxLength: 15,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  validationmsg: 'Enter Valid Mobile Number',
                                  validCheck: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Mobile number is required'.tr;
                                    }
                                    final digitsOnly =
                                        value.replaceAll(RegExp(r'\D'), '');
                                    if (digitsOnly.length < 10) {
                                      return 'Minimum 10 digits required'.tr;
                                    }
                                    if (digitsOnly.length > 15) {
                                      return 'Maximum 15 digits allowed'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                AppFormTextField(
                                  fieldHintText: "Email",
                                  controller: controller.email,
                                  keyType: TextInputType.emailAddress,
                                  onsaved: (val) {},
                                  validationmsg: 'Enter Valid Email',
                                  validCheck: (p0) {
                                    if (!p0!.isEmail) {
                                      return 'Enter Valid Email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                AppFormTextField(
                                  fieldHintText: "Pin Code (Optional)".tr,
                                  controller: controller.pinCode,
                                  keyType: TextInputType.number,
                                  maxLength: 8,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onsaved: (val) {},
                                  validationmsg: 'Enter valid Pin code',
                                  validCheck: (p0) {
                                    if (p0 == null || p0.trim().isEmpty) {
                                      return null;
                                    }
                                    final digitsOnly =
                                        p0.replaceAll(RegExp(r'\D'), '');
                                    if (digitsOnly.length > 8) {
                                      return 'Pin code cannot exceed 8 digits'.tr;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                // AppFormTextField(
                                //   fieldHintText: "Flat, House No",
                                //   controller: controller.flat,
                                //   onsaved: (val) {},
                                //   validationmsg: '',
                                //   validCheck: (p0) {
                                //     if (p0!.isEmpty) {
                                //       return 'Enter Flat, Hourse No';
                                //     }
                                //     return null;
                                //   },
                                // ),
                                // const SizedBox(height: 10),
                                AppFormTextField(
                                  fieldHintText: "Area, Colony, Street",
                                  controller: controller.area,
                                  onsaved: (val) {},
                                  validationmsg: '',
                                  validCheck: (p0) {
                                    if (p0!.isEmpty) {
                                      return 'Enter Area, Colony ,Street';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                AppFormTextField(
                                  fieldHintText: "Landmark (Optional)",
                                  controller: controller.landmark,
                                  onsaved: (val) {},
                                  validationmsg: '',
                                  validCheck: (p0) {
                                    // Landmark is optional — no validation needed
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                                Obx(() => _regionField(
                                      context,
                                      hint: 'Select Country',
                                      value: controller.selectedCountry.value,
                                      loading: controller.isCountryLoading.value,
                                      onTap: () async {
                                        final r = await showRegionPicker(context,
                                            title: 'Select Country',
                                            searchHint: 'Search country',
                                            loader: controller.loadCountries,
                                            selectedId: controller.selectedCountryId.value);
                                        if (r != null) controller.selectCountry(r);
                                      },
                                    )),
                                const SizedBox(height: 10),
                                Obx(() => _regionField(
                                      context,
                                      hint: 'Select State',
                                      value: controller.selectedState.value,
                                      loading: false,
                                      onTap: () async {
                                        if (controller.selectedCountryId.value.isEmpty) {
                                          Get.showSnackbar(GetSnackBar(
                                            message: 'select country first',
                                            duration: const Duration(seconds: 2),
                                          ));
                                          return;
                                        }
                                        final r = await showRegionPicker(context,
                                            title: 'Select State',
                                            searchHint: 'Search state',
                                            loader: controller.loadStates,
                                            selectedId: controller.selectedStateId.value);
                                        if (r != null) controller.selectState(r);
                                      },
                                    )),
                                const SizedBox(height: 15),
                                AppFormTextField(
                                  fieldHintText: "Enter your Town/City",
                                  controller: controller.city,
                                  onsaved: (val) {},
                                  validationmsg: 'Enter Town/City',
                                  validCheck: (p0) {
                                    if (p0!.isEmpty) {
                                      return 'Enter Town/City';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 15),
                              ],
                            ),
                          ),
                        ),
                        Divider(
                          thickness: 10,
                          color: context.themegreyColor,
                        ),
                        Padding(
                          padding: pageSurroundingPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 20),
                              Text('Type Of Address',
                                  style: txtTheme().headlineSmall!.copyWith(
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
                                          activeColor: context.themeRedColor,
                                        );
                                      }),
                                      Text('Home',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: context.themeTextColor,
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
                                          activeColor: context.themeRedColor,
                                        );
                                      }),
                                      Text('Office',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: context.themeTextColor,
                                              fontSize: 16))
                                    ],
                                  ),
                                  const SizedBox(width: 15),
                                  Row(
                                    children: [
                                      Obx(() {
                                        return Radio(
                                          value: "Others",
                                          groupValue: controller
                                              .selectAddressType.value,
                                          onChanged: (val) {
                                            controller
                                                .selectedaddressstype(val);
                                          },
                                          activeColor: context.themeRedColor,
                                        );
                                      }),
                                      Text('others',
                                          style: TextStyle(
                                              fontFamily: 'Poppins',
                                              color: context.themeTextColor,
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
                                      activeColor: context.themeRedColor,
                                      value: controller.selectDefaultAdd.value,
                                      onChanged: (value) {
                                        controller.selectDefaultAdd.value =
                                            !controller.selectDefaultAdd.value;
                                      },
                                      title: Text(
                                        'Make Default Address ',
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          color: context.themeTextColor,
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
                Obx(() => filterButton(
                      reset: 'RESET',
                      filter: controller.isUpdateAddress
                          ? 'Update Address'
                          : 'Add Address',
                      isEnabled: controller.isFormValid.value,
                      pressEvnetFilter: () async {
                        if (controller.formkey.currentState!.validate()) {
                          if (controller.selectedCountry.value == null ||
                              controller.selectedCountry.value!.isEmpty) {
                            Get.showSnackbar(
                              GetSnackBar(
                                message: 'Please select a country'.tr,
                                snackPosition: SnackPosition.TOP,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          if (controller.selectedState.value == null ||
                              controller.selectedState.value!.isEmpty) {
                            Get.showSnackbar(
                              GetSnackBar(
                                message: 'Please select a state'.tr,
                                snackPosition: SnackPosition.TOP,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }
                          if (controller.city.text.isEmpty) {
                            Get.showSnackbar(
                              GetSnackBar(
                                message: 'Please enter a town/city'.tr,
                                snackPosition: SnackPosition.TOP,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                            return;
                          }

                          if (AuthDetails.isUserLogin()) {
                            if (controller.isUpdateAddress) {
                              controller.updateAddress(
                                  id: controller.updateAddressId);
                            } else {
                              await controller.addAddress().then((value) {});
                            }
                          } else {
                            // Guest checkout is not supported by the backend.
                            HelperFunctions.showLoginDialog(
                                "Please login to save an address.");
                          }
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
                        controller.clearRegions();
                        controller.city.text = '';
                      },
                    ))
              ],
            )),
      ),
    );
  }

  /// Dropdown-looking field that opens the paginated picker sheet.
  Widget _regionField(
    BuildContext context, {
    required String hint,
    required String? value,
    required bool loading,
    required VoidCallback onTap,
  }) {
    final hasValue = value != null && value.isNotEmpty;
    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(3.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: context.themeBorderColor),
          borderRadius: BorderRadius.circular(3.0),
        ),
        child: loading
            ? HelperFunctions().loadingIndicator()
            : Row(
                children: [
                  Expanded(
                    child: Text(
                      hasValue ? value : hint,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: hasValue
                            ? context.themeTextColor
                            : context.themeTextColor.withOpacity(0.6),
                        fontSize: 15.0,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down_rounded),
                ],
              ),
      ),
    );
  }
}
