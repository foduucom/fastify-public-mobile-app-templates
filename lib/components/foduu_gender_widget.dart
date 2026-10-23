import 'package:flutter/material.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';

class FoduuGenderWidget extends StatelessWidget {
  const FoduuGenderWidget({
    Key? key,
    required this.selectedGender,
    required this.onChange,
  }) : super(key: key);

  final String selectedGender;
  final ValueSetter<String> onChange;

  static const List<Map<String, String>> genderOptions = [
    {'label': 'Male', 'value': 'male'},
    {'label': 'Female', 'value': 'female'},
    {'label': 'Other', 'value': 'other'},
    {'label': 'Prefer not to say', 'value': 'prefer not to say'},
  ];

  @override
  Widget build(BuildContext context) {
    final currentGender = selectedGender.toLowerCase().trim();
    final bool hasMatch =
        genderOptions.any((element) => element['value'] == currentGender);
    final String? dropdownValue = hasMatch ? currentGender : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender'.tr,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: context.themeTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: context.themeWhiteColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: dropdownValue,
                isExpanded: true,
                hint: Text(
                  'Select Gender'.tr,
                  style: TextStyle(
                    color: context.themeSecondrytext,
                    fontSize: 16,
                  ),
                ),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: context.themeSecondrytext,
                ),
                dropdownColor: context.themeWhiteColor,
                borderRadius: BorderRadius.circular(12),
                items: genderOptions.map((item) {
                  return DropdownMenuItem<String>(
                    value: item['value'],
                    child: Text(
                      item['label']!.tr,
                      style: TextStyle(
                        fontSize: 16,
                        color: context.themeTextColor,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    onChange(newValue);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
