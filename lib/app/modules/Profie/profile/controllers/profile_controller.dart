import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ProfileController extends GetxController with BaseController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  var box = GetStorage();
  var profiledata = {}.obs;
  DateTime? selectedDate;
  late TextEditingController nameController,
      lastNameController,
      genderController,
      passwordController,
      emailController,
      phoneController,
      dobController,
      oldPasswordController,
      newPasswordController,
      comfirmPasswordController;
  final isLoading = false.obs;
  var imagePath = "".obs;

  var obsecureValue = true.obs;
  var newPasswordObsecureValue = true.obs;
  var oldPasswordObsecureValue = true.obs;
  var comfirmPasswordObsecureValue = true.obs;

  var selectNotification = 0.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    getBoxData();

    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    dobController = TextEditingController();
    lastNameController = TextEditingController();
    genderController = TextEditingController();
    passwordController = TextEditingController();
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    comfirmPasswordController = TextEditingController();

    await fetchDataFromServer();
  }

  void getBoxData() {
    if (AuthDetails.isUserLogin()) {
      var userData = box.read('userData');
      if (userData != null) {
        profiledata.clear();
        profiledata.addAll(userData);
      }
    }
  }

  Future<void> changePassword() async {
    try {
      if (newPasswordController.text != comfirmPasswordController.text) {
        HelperFunctions()
            .showSnackBarError("New password and Confirm password not match");
        return;
      }
      var form = {
        "current_password": oldPasswordController.text,
        "new_password": newPasswordController.text,
        "confirm_password": comfirmPasswordController.text
      };
      print(form);
      var response = await BasicProvider("public/customer/change/password")
          .postRequest(form)
          .catchError(handleError);
      if (response == null) return;
      print('passowrd 111 $response');
      Get.back();
      newPasswordController.text = '';
      oldPasswordController.text = '';
      comfirmPasswordController.text = '';
      newPasswordObsecureValue.value = true;
      oldPasswordObsecureValue.value = true;
      comfirmPasswordObsecureValue.value = true;
      HelperFunctions().showSnackBarSuccess('Password Change successfully');
    } catch (e) {
      print('profile update error $e');
    }
  }

  Future<void> selectDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? selectDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: currentDate,
    );

    if (selectDate != null) {
      selectedDate = selectDate;
      dobController.text = DateFormat('dd-MM-yyyy').format(selectDate);
    }
  }

  void getImageFromGalleryOrCamera(imageSource) {
    HelperFunctions().getImageFromGalleryOrCamera(imageSource).then((value) {
      imagePath.value = value;
    });
  }

  Future<void> fetchDataFromServer() async {
    try {
      isLoading(true);
      var response = await BasicProvider("auth/customer/profile")
          .getRequest()
          .catchError(handleError);

      if (response != null) {
        profiledata.clear();
        profiledata.addAll(response);

        nameController.text = response["name"]?.toString() ?? "";
        emailController.text = response["email"]?.toString() ?? "";
        phoneController.text = response["mobile"]?.toString() ?? "";
        String? dobStr = response['date_of_birth']?.toString() ??
            response['dob']?.toString();
        DateTime? dob;
        if (dobStr != null && dobStr.isNotEmpty && dobStr != "null") {
          dob = DateTime.tryParse(dobStr);
          if (dob == null) {
            try {
              dob = DateFormat('dd-MM-yyyy').parse(dobStr);
            } catch (_) {
              try {
                dob = DateFormat('yyyy-MM-dd').parse(dobStr);
              } catch (_) {
                try {
                  dob = DateFormat('dd/MM/yyyy').parse(dobStr);
                } catch (_) {
                  try {
                    dob = DateFormat('dd MMM yyyy').parse(dobStr);
                  } catch (_) {}
                }
              }
            }
          }
        }
        if (dob != null) {
          selectedDate = dob;
          dobController.text = DateFormat('dd-MM-yyyy').format(dob);
        } else {
          selectedDate = null;
          dobController.text = "";
        }
        String genderVal =
            response["gender"]?.toString().toLowerCase() ?? 'female';
        gender.value = genderVal;
        genderController.text = genderVal;
      }
    } catch (e) {
      debugPrint('profile error $e');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    super.onClose();
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    lastNameController.dispose();
    genderController.dispose();
    passwordController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    comfirmPasswordController.dispose();
  }

  List notification = [
    {"name": "All"},
    {"name": "Order Info"},
    {"name": "Offers"},
    {"name": "Payment"},
  ];

  String dobFormatToStoreInDB(String dob) {
    DateTime dt = DateFormat('dd MMM yyyy').parse(dob);
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(dt);
    return formatted;
  }

  bool _hasFieldChanged(String key, String currentValue) {
    final originalValue = profiledata[key]?.toString() ?? "";
    return currentValue.trim() != originalValue.trim();
  }

  bool get _isDobChanged {
    final originalDobStr =
        (profiledata['date_of_birth'] ?? profiledata['dob'])?.toString();
    if (originalDobStr == null || originalDobStr.isEmpty) {
      return selectedDate != null;
    }
    final originalDob = DateTime.tryParse(originalDobStr);
    if (originalDob == null) {
      return selectedDate != null;
    }
    if (selectedDate == null) {
      return false;
    }
    return originalDob.year != selectedDate!.year ||
        originalDob.month != selectedDate!.month ||
        originalDob.day != selectedDate!.day;
  }

  bool get hasUnsavedChanges {
    if (profiledata.isEmpty) return false;
    return _hasFieldChanged('name', nameController.text) ||
        _hasFieldChanged('mobile', phoneController.text) ||
        _hasFieldChanged('email', emailController.text) ||
        _hasFieldChanged('gender', gender.value) ||
        _isDobChanged ||
        (imagePath.value.isNotEmpty && !imagePath.value.startsWith('http'));
  }

  Future<void> sendFormData() async {
    if (formKey.currentState!.validate()) {
      isLoading(true);

      // Build form fields first (no image yet)
      final Map<String, dynamic> formMap = {
        'name': nameController.text,
        'mobile': phoneController.text,
        'gender': gender.value
            .toLowerCase(), // Keep it lowercase to avoid server 500 enum error
        'email': emailController.text,
      };

      if (selectedDate != null) {
        formMap['date_of_birth'] =
            DateFormat('yyyy-MM-dd').format(selectedDate!);
      }

      // Only attach featured_image when user picked a NEW local file.
      // If imagePath is an existing http URL or empty, skip the field entirely
      // so the server keeps the existing image untouched.
      final bool isNewLocalFile =
          imagePath.value.isNotEmpty && !imagePath.value.contains("http");
      if (isNewLocalFile) {
        final path = imagePath.value;
        final name = path.split("/").last;
        final extension = name.split(".").last.toLowerCase();

        // Map common extensions to their MIME type
        String mimeType = 'image/jpeg';
        if (extension == 'png') {
          mimeType = 'image/png';
        } else if (extension == 'webp') {
          mimeType = 'image/webp';
        } else if (extension == 'gif') {
          mimeType = 'image/gif';
        }

        formMap['featured_image'] = MultipartFile(
          File(path),
          filename: name,
          contentType: mimeType,
        );
      }

      var form = FormData(formMap);
      print("Profile Data : $form");
      try {
        debugPrint("form To UPDATE Profile ${form.files}");
        var response = await BasicProvider("auth/customer/profile/update")
            .postRequest(form)
            .catchError(handleError);

        if (response == null) {
          HelperFunctions().hideOverlayLoader();
          return;
        }

        // Reset local imagePath on success so UI returns to fetching the server URL
        imagePath.value = "";

        await fetchDataFromServer();
        isLoading(false);

        var updatedprofile = await AuthDetails().updateUserDetailsFromServer();
        Get.find<BottombarController>().authDetails.value = updatedprofile;

        HelperFunctions().hideOverlayLoader();
        HelperFunctions().showSnackBarSuccess('Profile update successfully');
      } catch (e) {
        print('profile update error $e');
        HelperFunctions().hideOverlayLoader();
      } finally {
        isLoading(false);
      }
    }
  }

  List profileOptions = [
    {
      "icon": "assets/icon/profileoption1.svg",
      "title": "Orders",
      "subtitle": "Ongoing Orders, Recent Orders.."
    },
    {
      "icon": "assets/icon/profilelike.svg",
      "title": "Your Wishlist",
      "subtitle": "Your Save Products"
    },
    {
      "icon": "assets/icon/profilewallet.svg",
      "title": "Payment",
      "subtitle": "Saved Cards, Wallets"
    },
    {
      "icon": "assets/icon/profilelocation.svg",
      "title": "Saved Address",
      "subtitle": "Home, office.. "
    },
    {
      "icon": "assets/icon/profilenotification.svg",
      "title": "Notification",
      "subtitle": "Offers, Order tracking messages.."
    },
    {
      "icon": "assets/icon/user-key.png",
      "title": "Contact Us",
      "subtitle": "Customer Support, FAQs"
    },
    // {
    //   "icon": "assets/icon/profileoption1.svg",
    //   "title": "Profile setting",
    //   "subtitle": "Full Name, Password.."
    // },
    // {
    //   "icon": "assets/icon/profiletandc.svg",
    //   "title": "Terms & Conditions",
    //   "subtitle": "T&C for use of Platform"
    // },
    // {
    //   "icon": "assets/icon/profilecall.svg",
    //   "title": "Help/Customer Care",
    //   "subtitle": "Customer Support, FAQs"
    // },
  ];
  var gender = 'male'.obs;
  // var dropdownGender = 'Male'.obs;
  // var gender = [
  //   'Male',
  //   'Female',
  // ];
}
