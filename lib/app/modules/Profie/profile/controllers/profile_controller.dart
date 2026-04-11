import 'package:flutter/material.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/modules/auth/auth_details.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

class ProfileController extends GetxController with BaseController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> changePasswordFormKey = GlobalKey<FormState>();
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
  var selectedGender = 'Male'.obs;
  final addressController = TextEditingController();
  var selectNotification = 0.obs;
  var selectedDob = Rx<DateTime?>(null);

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
      initialDate: currentDate,
      firstDate: currentDate.subtract(const Duration(days: 365)),
      lastDate: currentDate.add(const Duration(days: 365)),
    );

    if (selectDate != null) {
      selectedDate = selectDate;
      dobController.text = DateFormat('dd-MM-yyyy').format(selectDate);
      // print('selected date ${selectedDate}');
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
      var response = await BasicProvider("public/customer/profile")
          .getRequest()
          .catchError(handleError);

      if (response != null) {
        profiledata.clear();
        profiledata
            .addAll(response); // response here should be the profile object

        nameController.text = response["name"]?.toString() ?? "";
        emailController.text = response["email"]?.toString() ?? "";
        phoneController.text = response["mobile"]?.toString() ?? "";

        print("profile data From Fetch Data From Server: $response");
        print("Name: ${response["name"]}");
        print("Email: ${response["email"]}");

        // ✅ DOB — populate both controller + observable
        final DateTime? dob =
            response['dob'] != null ? DateTime.tryParse(response['dob']) : null;
        if (dob != null) {
          selectedDob.value = dob;
          dobController.text = DateFormat('dd-MM-yyyy').format(dob);
        } else {
          selectedDob.value = null;
          dobController.text = '';
        }

        // ✅ Gender — sync both controller + observable pill selector
        final String rawGender =
            response["gender"]?.toString().toLowerCase() ?? 'male';
        genderController.text = rawGender;
        selectedGender.value = rawGender == 'female' ? 'Female' : 'Male';
        gender.value = rawGender;
      } else {
        print("profile data From Fetch Data From Server Response is null");
        // Add more debugging here
        print(
            "Headers being sent: ${BasicProvider("public/customer/profile").headerType()}");
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

  Future<void> sendFormData() async {
    if (dobController.text == "") {
      HelperFunctions().showSnackBarError("Please select your Date Of Birth");
      return;
    }
    if (formKey.currentState!.validate()) {
      isLoading(true);

      var form = FormData({
        'name': nameController.text,
        'mobile': phoneController.text,
        'dob': selectedDob.value,
        'gender': gender.value,
        'email': emailController.text,
        'featured_image':
            !imagePath.value.contains("http") && imagePath.value != ""
                ? MultipartFile(imagePath.value,
                    filename: imagePath.value
                        .split("/")[imagePath.value.split("/").length - 1])
                : imagePath.value != ""
                    ? null
                    : "",
      });

      try {
        var response = await BasicProvider("public/customer/profile/update")
            .postRequest(form)
            .catchError(handleError);
        Get.until((route) => !Get.isDialogOpen!);

        if (response == null) return;
        fetchDataFromServer();
        isLoading(false);

        Get.until((route) => !Get.isDialogOpen!);
        var updatedprofile = AuthDetails().updateUserDetailsFromServer();
        //Get.find<BottombarController>().authDetails.value = updatedprofile;
        // HelperFunctions().showSnackBarSuccess(response["status"]);
        Get.until((route) => !Get.isDialogOpen!);
        // Get.back();
        // Get.back();

        HelperFunctions().showSnackBarSuccess('Profile update successfully');
      } catch (e) {
        print('profile update error $e');
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
      "icon": "assets/icon/profilecall.svg",
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
