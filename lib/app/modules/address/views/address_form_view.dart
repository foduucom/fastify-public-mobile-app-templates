import 'package:flutter/material.dart';
import '../../../../components/app_bar.dart';
import '/app/modules/auth/auth_details.dart';
import 'package:get/get.dart';
import '../controllers/address_form_controller.dart';
import '/components/foduuformtextfield.dart';
import '/constants/constants.dart';
import '/constants/theme.dart';

class AddressFormView extends GetView<AddressFormController> {
  const AddressFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // controller.fetchCountries();
            print(AuthDetails.getToken());
          },
        ),
        appBar:  CustomAppBar(title: 'Addresses',),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: pageSurroundingPadding,
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDropdownSection(
                      context,
                      title: "Country",
                      items: controller.countryList,
                      selectedValue: controller.selectedCountry,
                      onChanged: controller.onCountryChanged,
                      hint: "Select Country",
                    ),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "Full Name",
                      fieldHintText: "Enter full name",
                      controller: controller.name,
                      validationmsg: "Name is required",
                      validCheck: (v) => v!.isEmpty ? "Enter Name" : null,
                    ),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "Mobile Number",
                      fieldHintText: "Enter 10 digit mobile number",
                      controller: controller.mobile,
                      keyType: TextInputType.phone,
                      validationmsg: "Valid mobile number is required",
                      validCheck: (v) => (v!.isEmpty || v.length != 10)
                          ? "Enter Valid Mobile Number"
                          : null,
                    ),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "Email Address",
                      fieldHintText: "Enter email",
                      controller: controller.email,
                      keyType: TextInputType.emailAddress,
                      validationmsg: "Valid email is required",
                      validCheck: (v) =>
                          !v!.isEmail ? "Enter Valid Email" : null,
                    ),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "Pin Code",
                      fieldHintText: "Enter 6 digit pin code",
                      controller: controller.postal_code,
                      keyType: TextInputType.number,
                      validationmsg: "Pin code is required",
                      validCheck: (v) => (v!.isEmpty || v.length != 6)
                          ? "Enter Valid Pin Code"
                          : null,
                    ),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "Area / Colony / Street",
                      fieldHintText: "Enter area",
                      controller: controller.street,
                      validationmsg: "Required",
                      validCheck: (v) =>
                          v!.isEmpty ? "Enter Area/Colony/Street" : null,
                    ),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "Landmark",
                      fieldHintText: "Enter landmark",
                      controller: controller.landmark,
                      validationmsg: "Required",
                      validCheck: (v) => v!.isEmpty ? "Enter Landmark" : null,
                    ),
                    const SizedBox(height: 15),
                    _buildDropdownSection(
                      context,
                      title: "State",
                      items: controller.stateList,
                      selectedValue: controller.selectedState,
                      onChanged: controller.onStateChanged,
                      hint: "Select State",
                      enabled: controller.selectedCountry.isNotEmpty,
                    ),
                    const SizedBox(height: 15),
                    _buildDropdownSection(
                      context,
                      title: "City",
                      items: controller.cityList,
                      selectedValue: controller.selectedCity,
                      onChanged: controller.onCityChanged,
                      hint: "Select City",
                      enabled: controller.selectedState.isNotEmpty,
                    ),
                    const SizedBox(height: 25),
                    Text(
                      'Address Type',
                      style: txtTheme()
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Obx(() => Row(
                          children: [
                            _buildTypeRadio("Home"),
                            _buildTypeRadio("Office"),
                            _buildTypeRadio("Others"),
                          ],
                        )),
                    const SizedBox(height: 15),
                    Obx(() => CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Make default address"),
                          value: controller.isDefault.value,
                          onChanged: (v) => controller.isDefault.value = v!,
                          controlAffinity: ListTileControlAffinity.leading,
                        )),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: controller.saveAddress,
                style: ElevatedButton.styleFrom(
                  // backgroundColor: themeRedColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  controller.isEditMode ? 'Update Address' : 'Save Address',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownSection(
    BuildContext context, {
    required String title,
    required RxList items,
    required RxMap selectedValue,
    required Function(dynamic) onChanged,
    required String hint,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
                child: DropdownButton<dynamic>(
                  isExpanded: true,
                  hint: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(hint),
                  ),
                  value: selectedValue.isEmpty
                      ? null
                      : items.firstWhereOrNull(
                          (e) => e['_id'] == selectedValue['_id']),
                  items: items.map((e) {
                    return DropdownMenuItem<dynamic>(
                      value: e,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(e['name'] ?? ''),
                      ),
                    );
                  }).toList(),
                  onChanged: enabled ? onChanged : null,
                ),
              )),
        ),
      ],
    );
  }

  Widget _buildTypeRadio(String value) {
    return Expanded(
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: controller.addressType.value,
            onChanged: (v) => controller.addressType.value = v!,
          ),
          Text(value),
        ],
      ),
    );
  }
}
