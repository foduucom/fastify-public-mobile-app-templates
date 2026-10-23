import 'package:flutter/material.dart';
import '../../../../components/app_bar.dart';
import 'package:get/get.dart';
import '../controllers/address_form_controller.dart';
import '../widgets/region_picker_sheet.dart';
import '/components/foduuformtextfield.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import '/constants/theme.dart';

class AddressFormView extends GetView<AddressFormController> {
  const AddressFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Addresses'),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: pageSurroundingPadding,
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => _buildRegionField(
                          context,
                          title: "Country",
                          hint: "Select Country",
                          value: controller.selectedCountry.value,
                          loading: controller.isCountryLoading.value,
                          onTap: () async {
                            final r = await showRegionPicker(
                              context,
                              title: "Select Country",
                              searchHint: "Search country",
                              loader: controller.loadCountries,
                              selectedId: controller.selectedCountryId.value,
                            );
                            if (r != null) controller.selectCountry(r);
                          },
                        )),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "Full Name",
                      fieldHintText: "Enter full name",
                      controller: controller.name,
                      validationmsg: "",
                      isRequired: false,
                      validCheck: null,
                    ),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "Mobile Number",
                      fieldHintText: "Enter 10 digit mobile number",
                      controller: controller.mobile,
                      keyType: TextInputType.phone,
                      validationmsg: "",
                      isRequired: false,
                      validCheck: (v) =>
                          (v != null && v.trim().isNotEmpty && v.trim().length != 10)
                              ? "Enter Valid Mobile Number"
                              : null,
                    ),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "Email Address",
                      fieldHintText: "Enter email",
                      controller: controller.email,
                      keyType: TextInputType.emailAddress,
                      validationmsg: "",
                      isRequired: false,
                      validCheck: (v) =>
                          (v != null && v.trim().isNotEmpty && !v.trim().isEmail)
                              ? "Enter Valid Email"
                              : null,
                    ),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "Pin Code",
                      fieldHintText: "Enter 6 digit pin code",
                      controller: controller.postal_code,
                      keyType: TextInputType.number,
                      validationmsg: "Pin code is required",
                      validCheck: (v) => (v == null || v.isEmpty || v.length != 6)
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
                          (v == null || v.isEmpty) ? "Enter Area/Colony/Street" : null,
                    ),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "Landmark",
                      fieldHintText: "Enter landmark",
                      controller: controller.landmark,
                      validationmsg: "Required",
                      validCheck: (v) =>
                          (v == null || v.isEmpty) ? "Enter Landmark" : null,
                    ),
                    const SizedBox(height: 15),
                    Obx(() => _buildRegionField(
                          context,
                          title: "State",
                          hint: "Select State",
                          value: controller.selectedState.value,
                          loading: false,
                          onTap: () async {
                            if (controller.selectedCountryId.value.isEmpty) {
                              HelperFunctions()
                                  .showSnackBarError("Please select country first");
                              return;
                            }
                            final r = await showRegionPicker(
                              context,
                              title: "Select State",
                              searchHint: "Search state",
                              loader: controller.loadStates,
                              selectedId: controller.selectedStateId.value,
                            );
                            if (r != null) controller.selectState(r);
                          },
                        )),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "City / Town",
                      fieldHintText: "Enter your Town/City",
                      controller: controller.city,
                      validationmsg: "City is required",
                      validCheck: (v) =>
                          (v == null || v.trim().isEmpty) ? "Enter Town/City" : null,
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
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  controller.isEditMode ? 'Update Address' : 'Save Address',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
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

  Widget _buildRegionField(
    BuildContext context, {
    required String title,
    required String hint,
    required String? value,
    required bool loading,
    required VoidCallback onTap,
  }) {
    final hasValue = value != null && value.trim().isNotEmpty;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: loading ? null : onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        height: 56,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasValue)
                    Text(
                      title,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  Text(
                    hasValue ? value : hint,
                    style: TextStyle(
                      color: hasValue
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (loading)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              Icon(
                Icons.arrow_drop_down,
                color: colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
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
