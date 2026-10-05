import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/components/commonWidgets/secondary_app_header.dart';
import '/components/foduuformtextfield.dart';
import '/constants/constants.dart';
import '../controllers/address_form_controller.dart';

class AddressFormView extends GetView<AddressFormController> {
  const AddressFormView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: SecondaryAppHeader(
          title: controller.isEditMode ? 'Edit Address' : 'Add New Address',
          showRight: false,
        ),
        body: SingleChildScrollView(
          padding: pageSurroundingPadding,
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Country Dropdown
                _buildDropdownSection(
                  context,
                  title: "Country",
                  items: controller.countryList,
                  selectedValue: controller.selectedCountry,
                  onChanged: controller.onCountryChanged,
                  hint: "Select Country",
                ),
                const SizedBox(height: 16),

                // Full Name
                FoduuFormTextField(
                  title: "Full Name",
                  fieldHintText: "Enter full name",
                  controller: controller.name,
                  validationmsg: "Name is required",
                  validCheck: (v) =>
                      (v == null || v.trim().isEmpty) ? "Enter Name" : null,
                ),
                const SizedBox(height: 16),

                // Mobile Number
                FoduuFormTextField(
                  title: "Mobile Number",
                  fieldHintText: "Enter 10 digit mobile number",
                  controller: controller.mobile,
                  keyType: TextInputType.phone,
                  validationmsg: "Valid mobile number is required",
                  validCheck: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Enter Mobile Number";
                    }
                    if (v.trim().length != 10) {
                      return "Enter 10 digit Mobile Number";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email Address
                FoduuFormTextField(
                  title: "Email Address",
                  fieldHintText: "Enter email address",
                  controller: controller.email,
                  keyType: TextInputType.emailAddress,
                  validationmsg: "Valid email is required",
                  validCheck: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Enter Email Address";
                    }
                    if (!v.isEmail) {
                      return "Enter Valid Email Address";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Pin Code
                FoduuFormTextField(
                  title: "Pin Code",
                  fieldHintText: "Enter 6 digit pin code",
                  controller: controller.postal_code,
                  keyType: TextInputType.number,
                  validationmsg: "Pin code is required",
                  validCheck: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Enter Pin Code";
                    }
                    if (v.trim().length != 6) {
                      return "Enter Valid 6 digit Pin Code";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Street
                FoduuFormTextField(
                  title: "Area / Colony / Street",
                  fieldHintText: "Enter area, colony or street",
                  controller: controller.street,
                  validationmsg: "Required",
                  validCheck: (v) => (v == null || v.trim().isEmpty)
                      ? "Enter Area/Colony/Street"
                      : null,
                ),
                const SizedBox(height: 16),

                // Landmark
                FoduuFormTextField(
                  title: "Landmark",
                  fieldHintText: "Enter nearby landmark",
                  controller: controller.landmark,
                  validationmsg: "Required",
                  validCheck: (v) => (v == null || v.trim().isEmpty)
                      ? "Enter Landmark"
                      : null,
                ),
                const SizedBox(height: 16),

                // State Dropdown
                Obx(() => _buildDropdownSection(
                      context,
                      title: "State",
                      items: controller.stateList,
                      selectedValue: controller.selectedState,
                      onChanged: controller.onStateChanged,
                      hint: controller.selectedCountry.isEmpty
                          ? "Select Country first"
                          : "Select State",
                      enabled: controller.selectedCountry.isNotEmpty,
                    )),
                const SizedBox(height: 16),

                // City Dropdown
                Obx(() => _buildDropdownSection(
                      context,
                      title: "City",
                      items: controller.cityList,
                      selectedValue: controller.selectedCity,
                      onChanged: controller.onCityChanged,
                      hint: controller.selectedState.isEmpty
                          ? "Select State first"
                          : "Select City",
                      enabled: controller.selectedState.isNotEmpty,
                    )),
                const SizedBox(height: 24),

                // Address Type Selection
                Text(
                  'Address Type',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Obx(() => Row(
                      children: [
                        _buildTypeChip(
                          context,
                          type: "Home",
                          icon: Icons.home_outlined,
                        ),
                        const SizedBox(width: 10),
                        _buildTypeChip(
                          context,
                          type: "Office",
                          icon: Icons.work_outline,
                        ),
                        const SizedBox(width: 10),
                        _buildTypeChip(
                          context,
                          type: "Others",
                          icon: Icons.location_on_outlined,
                        ),
                      ],
                    )),
                const SizedBox(height: 20),

                // Default Address Switch
                Obx(() => Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        child: SwitchListTile.adaptive(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 0),
                          title: Text(
                            "Set as default address",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          activeColor: colorScheme.primary,
                          value: controller.isDefault.value,
                          onChanged: (v) => controller.isDefault.value = v,
                        ),
                      ),
                    )),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom > 0
                ? MediaQuery.of(context).padding.bottom + 8
                : 16,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black.withOpacity(0.3)
                    : Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Obx(() => ElevatedButton(
                onPressed:
                    controller.isLoading.value ? null : controller.saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        controller.isEditMode
                            ? 'Update Address'
                            : 'Save Address',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              )),
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
    final colorScheme = Theme.of(context).colorScheme;

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
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: enabled
                ? colorScheme.surfaceVariant
                : colorScheme.surfaceVariant.withOpacity(0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: colorScheme.outline,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          child: Obx(() {
            final selectedItem = selectedValue.isEmpty
                ? null
                : items.firstWhereOrNull(
                    (e) => e['_id'] == selectedValue['_id']);

            return DropdownButtonHideUnderline(
              child: DropdownButton<dynamic>(
                isExpanded: true,
                dropdownColor: colorScheme.surface,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: enabled
                      ? colorScheme.onSurfaceVariant
                      : colorScheme.outline,
                ),
                hint: Text(
                  hint,
                  style: TextStyle(
                    fontSize: 15,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                value: selectedItem,
                items: items.map((e) {
                  return DropdownMenuItem<dynamic>(
                    value: e,
                    child: Text(
                      e['name'] ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: enabled ? onChanged : null,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildTypeChip(
    BuildContext context, {
    required String type,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected =
        controller.addressType.value.toLowerCase() == type.toLowerCase();

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.addressType.value = type,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withOpacity(0.12)
                : colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                type,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
