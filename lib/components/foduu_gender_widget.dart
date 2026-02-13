import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:get/get.dart';

// ignore: must_be_immutable
class FoduuGenderWidget extends StatelessWidget {
  FoduuGenderWidget({required this.selectedGender, required this.onChange});

  String selectedGender;
  final ValueSetter<String> onChange;

  var gender = "male".obs;

  @override
  Widget build(BuildContext context) {
    ValueNotifier<String> gender = ValueNotifier<String>("female");

    gender.value = selectedGender;
    return Row(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'Gender'.tr,
            style: const TextStyle(
                // color: themeTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
          Radio(
            // activeColor: themeRedColor,
            value: "male".tr,
            groupValue: gender.value,
            onChanged: (String? value) {
              gender.value = value!;
              onChange(value);
            },
          ),
          GestureDetector(
            onTap: () {
              gender.value = "male";
              onChange("male");
            },
            child: Text(
              'Male'.tr,
              style: const TextStyle(
                  // color: themeTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
            ),
          ),
          // const SizedBox(width: 10),
          Radio(
            // activeColor: themeRedColor,
            value: "female",
            groupValue: gender.value,
            onChanged: (String? value) {
              gender.value = value!;
              onChange(value);
            },
          ),
          GestureDetector(
              onTap: () {
                gender.value = "female";
                onChange("female");
              },
              child: Text('Female'.tr,
                  style: const TextStyle(
                      // color: themeTextColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400))),
        ]);
  }
}
