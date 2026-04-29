import 'package:cached_network_image/cached_network_image.dart';
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
  var addresses = <dynamic>[].obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    getBoxData();

    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
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

        // Seed imagePath from cached featured_image so EditProfileView
        // shows the current image immediately before the API call returns
        final featuredImage = userData['featured_image'];
        if (featuredImage != null) {
          final imgUrl = HelperFunctions().getImage(featuredImage);
          if (imgUrl.isNotEmpty) {
            imagePath.value = imgUrl;
          }
        }
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

  void getImageFromGalleryOrCamera(imageSource) {
    HelperFunctions().getImageFromGalleryOrCamera(imageSource).then((value) {
      imagePath.value = value;
    });
  }

  Future<void> fetchDataFromServer() async {
    try {
      isLoading(true);
      // Switched from "public/customer/profile" to "auth/customer/profile" as requested
      var response = await BasicProvider("auth/customer/profile")
          .getRequest()
          .catchError(handleError);

      if (response != null) {
        profiledata.clear();
        profiledata.addAll(response);

        // Basic Profile Data
        nameController.text = response["name"]?.toString() ?? "";
        emailController.text = response["email"]?.toString() ?? "";
        phoneController.text = response["mobile"]?.toString() ?? "";

        // Gender syncing
        final String rawGender =
            response["gender"]?.toString().toLowerCase() ?? 'male';
        genderController.text = rawGender;
        selectedGender.value = rawGender == 'female' ? 'Female' : 'Male';
        gender.value = rawGender;

        // Addresses parsing
        if (response['addresses'] != null && response['addresses'] is List) {
          addresses.assignAll(response['addresses']);
        } else {
          addresses.clear();
        }

        // Profile Image — use HelperFunctions().getImage() same as ProfileView
        if (response['featured_image'] != null) {
          final imgUrl = HelperFunctions().getImage(response['featured_image']);
          if (imgUrl.isNotEmpty) {
            imagePath.value = imgUrl;
          }
        }

        debugPrint("Profile data successfully fetched and parsed: $response");
      } else {
        debugPrint("Profile data response was null.");
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
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

  Future<void> sendFormData() async {
    if (formKey.currentState!.validate()) {
      isLoading(true);

      var form = FormData({
        'name': nameController.text,
        'mobile': phoneController.text,
        'email': emailController.text,
        'gender': selectedGender.value.toLowerCase(),
        'featured_image':
            !imagePath.value.contains("http") && imagePath.value != ""
                ? MultipartFile(imagePath.value,
                    filename: imagePath.value
                        .split("/")[imagePath.value.split("/").length - 1])
                : null,
      });

      try {
        var response = await BasicProvider("auth/customer/profile/update")
            .postRequest(form)
            .catchError(handleError);
        Get.until((route) => !Get.isDialogOpen!);

        if (response == null) return;
        // Evict old cached image so the updated one loads fresh
        if (imagePath.value.contains("http")) {
          await CachedNetworkImage.evictFromCache(imagePath.value);
        }
        await fetchDataFromServer();
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
        rethrow;
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
