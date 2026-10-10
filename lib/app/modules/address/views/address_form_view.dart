import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:get/get.dart';
import '../widgets/region_picker_sheet.dart';
import '../controllers/address_form_controller.dart';
import 'package:foduu_ecommerce/components/foduuformtextfield.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/theme.dart';

class AddressFormView extends StatefulWidget {
  const AddressFormView({Key? key}) : super(key: key);

  @override
  State<AddressFormView> createState() => _AddressFormViewState();
}

class _AddressFormViewState extends State<AddressFormView> {
  final _formKey = GlobalKey<FormState>();
  AddressFormController get controller => Get.find<AddressFormController>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        // floatingActionButton: FloatingActionButton(
        //   heroTag: 'address_form_fab',
        //   onPressed: () {
        //     // controller.fetchCountries();
        //     print(AuthDetails.getToken());
        //   },
        // ),
        appBar: AppBar(
          title: Text(
            controller.isEditMode ? 'Edit Address' : 'Add New Address',
            style: txtTheme().headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Lato",
                ),
          ),
          elevation: 0,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: pageSurroundingPadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => _buildRegionField(
                      context,
                      title: "Country",
                      selected: controller.selectedCountry,
                      hint: "Select Country",
                      onTap: () async {
                        final r = await showRegionPicker(context,
                            title: 'Select Country',
                            searchHint: 'Search country',
                            loader: controller.loadCountries,
                            selectedId:
                                controller.selectedCountry['_id']?.toString());
                        if (r != null) controller.onCountryChanged(r);
                      },
                    )),
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
                      fieldHintText: "Enter landmark (optional)",
                      controller: controller.landmark,
                      validationmsg: "",
                      isRequired: false,
                      validCheck: (v) => null, // Landmark is optional
                    ),
                    const SizedBox(height: 15),
                    Obx(() => _buildRegionField(
                      context,
                      title: "State",
                      selected: controller.selectedState,
                      hint: controller.selectedCountry.isEmpty
                          ? "Select Country first"
                          : "Select State",
                      enabled: controller.selectedCountry.isNotEmpty,
                      onTap: () async {
                        final r = await showRegionPicker(context,
                            title: 'Select State',
                            searchHint: 'Search state',
                            loader: controller.loadStates,
                            selectedId:
                                controller.selectedState['_id']?.toString());
                        if (r != null) controller.onStateChanged(r);
                      },
                    )),
                    const SizedBox(height: 15),
                    FoduuFormTextField(
                      title: "City",
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
                onPressed: () => controller.saveAddress(_formKey),
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

  Widget _buildRegionField(
    BuildContext context, {
    required String title,
    required Map selected,
    required String hint,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = (selected['name'] ?? '').toString();
    final hasValue = name.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: RichText(
            text: TextSpan(
              text: title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              children: [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: colorScheme.error, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: enabled
                  ? colorScheme.surfaceContainerHighest
                  : colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colorScheme.outline, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    hasValue ? name : hint,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: hasValue
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: enabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.outline,
                ),
              ],
            ),
          ),
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
