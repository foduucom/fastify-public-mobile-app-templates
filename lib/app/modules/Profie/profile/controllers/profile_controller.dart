import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:zouhi/app/routes/app_pages.dart';

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
  bool _isFetchingProfile = false;

  @override
  void onInit() {
    super.onInit();

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

    getBoxData();

    if (AuthDetails.isUserLogin()) {
      fetchDataFromServer();
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (AuthDetails.isUserLogin()) {
      ensureDataLoaded();
    }
  }

  void getBoxData() {
    if (AuthDetails.isUserLogin()) {
      var userData = box.read('userData');
      if (userData != null && userData is Map) {
        populateFieldsFromResponse(userData);
      }
    }
  }

  Future<void> ensureDataLoaded({bool forceRefresh = false}) async {
    // If called during build/layout phase, defer until after frame to prevent setState() during build
    if (WidgetsBinding.instance.schedulerPhase ==
            SchedulerPhase.persistentCallbacks ||
        WidgetsBinding.instance.schedulerPhase ==
            SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ensureDataLoaded(forceRefresh: forceRefresh);
      });
      return;
    }

    if (!AuthDetails.isUserLogin()) return;
    if (isLoading.value || _isFetchingProfile) return;

    if (profiledata.isEmpty || nameController.text.isEmpty) {
      getBoxData();
    }
    if (forceRefresh || profiledata.isEmpty || nameController.text.isEmpty) {
      await fetchDataFromServer(forceRefresh: forceRefresh);
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
    DateTime initial = selectedDate ?? currentDate;

    // Ensure initialDate falls within firstDate and lastDate bounds
    DateTime firstLimit = DateTime(1900);
    DateTime lastLimit = currentDate;
    if (initial.isBefore(firstLimit)) {
      initial = firstLimit;
    } else if (initial.isAfter(lastLimit)) {
      initial = lastLimit;
    }

    DateTime? selectDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstLimit,
      lastDate: lastLimit,
    );

    if (selectDate != null) {
      selectedDate = selectDate;
      dobController.text = DateFormat('dd/MM/yyyy').format(selectDate);
      // print('selected date ${selectedDate}');
    }
  }

  void getImageFromGalleryOrCamera(imageSource) {
    HelperFunctions().getImageFromGalleryOrCamera(imageSource).then((value) {
      imagePath.value = value;
    });
  }

  void populateFieldsFromResponse(Map<dynamic, dynamic> response) {
    Map<dynamic, dynamic> data = response;
    if (data.containsKey('data') && data['data'] is Map) {
      data = data['data'];
    } else if (data.containsKey('user') && data['user'] is Map) {
      data = data['user'];
    } else if (data.containsKey('customer') && data['customer'] is Map) {
      data = data['customer'];
    }

    profiledata.clear();
    profiledata.addAll(data);

    String name = data["name"]?.toString() ??
        data["full_name"]?.toString() ??
        ((data["first_name"] != null || data["last_name"] != null)
            ? "${data["first_name"] ?? ''} ${data["last_name"] ?? ''}".trim()
            : "");
    nameController.text = name;

    String email = data["email"]?.toString() ?? "";
    emailController.text = email;

    String mobile = data["mobile"]?.toString() ??
        data["phone"]?.toString() ??
        data["mobile_number"]?.toString() ??
        data["phone_number"]?.toString() ??
        "";
    phoneController.text = mobile;

    String? dobStr = data['date_of_birth']?.toString() ??
        data['dob']?.toString() ??
        data['birth_date']?.toString();
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
      dobController.text = DateFormat('dd/MM/yyyy').format(dob);
    } else {
      selectedDate = null;
      dobController.text = "";
    }
    String? rawGender =
        (data["gender"] ?? data["sex"])?.toString().trim().toLowerCase();
    String genderVal =
        (rawGender != null && rawGender.isNotEmpty && rawGender != 'null')
            ? rawGender
            : '';
    gender.value = genderVal;
    genderController.text = genderVal;

    if (!profiledata.containsKey('name') ||
        profiledata['name'] == null ||
        profiledata['name'].toString().isEmpty) {
      profiledata['name'] = name;
    }
    if (!profiledata.containsKey('email') || profiledata['email'] == null) {
      profiledata['email'] = email;
    }

    profiledata.refresh();
  }

  Future<void> fetchDataFromServer({bool forceRefresh = false}) async {
    if (_isFetchingProfile) return;
    _isFetchingProfile = true;
    try {
      isLoading(true);

      if (!forceRefresh) {
        final lastFetchStr = box.read('lastProfileFetch');
        final cachedData = box.read('userData');
        if (lastFetchStr != null && cachedData != null && cachedData is Map) {
          final lastFetch = DateTime.tryParse(lastFetchStr);
          if (lastFetch != null &&
              DateTime.now().difference(lastFetch).inMinutes < 5) {
            populateFieldsFromResponse(cachedData);
            return;
          }
        }
      }

      var response = await BasicProvider("auth/customer/profile")
          .getRequest()
          .catchError(handleError);

      if (response != null && response is Map) {
        populateFieldsFromResponse(response);
        box.write('userData', response);
        box.write('lastProfileFetch', DateTime.now().toIso8601String());
      } else if (response == null) {
        getBoxData();
      }
    } catch (e) {
      debugPrint('profile error $e');
      getBoxData();
    } finally {
      isLoading(false);
      _isFetchingProfile = false;
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
    // if (dobController.text == "") {
    //   HelperFunctions().showSnackBarError("Please select your Date Of Birth");
    //   return;
    // }
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
      } else if (dobController.text.isNotEmpty) {
        try {
          DateTime parsed =
              DateFormat('dd/MM/yyyy').parse(dobController.text);
          formMap['date_of_birth'] = DateFormat('yyyy-MM-dd').format(parsed);
        } catch (_) {
          try {
            DateTime parsed =
                DateFormat('dd-MM-yyyy').parse(dobController.text);
            formMap['date_of_birth'] =
                DateFormat('yyyy-MM-dd').format(parsed);
          } catch (_) {}
        }
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

        await fetchDataFromServer(forceRefresh: true);
        isLoading(false);

        var updatedprofile = await AuthDetails().updateUserDetailsFromServer();
        Get.find<BottombarController>().authDetails.value = updatedprofile;

        HelperFunctions().hideOverlayLoader();
        HelperFunctions().showSnackBarSuccess('Profile update successfully');
        Get.back();
      } catch (e) {
        print('profile update error $e');
        HelperFunctions().hideOverlayLoader();
        Get.snackbar('Error', 'Failed to update profile. Please try again.');
      } finally {
        isLoading(false);
      }
    }
  }

  List profileOptions = [
    {
      "icon": "assets/icon/profileoption1.svg",
      "title": "Orders",
      "subtitle": "Ongoing Orders, Recent Orders..",
      "route": Routes.ORDERS,
    },
    {
      "icon": "assets/icon/profilelike.svg",
      "title": "Your Wishlist",
      "subtitle": "Keep Your Favorites Close",
    },
    {
      "icon": "assets/icon/profilelocation.svg",
      "title": "Saved Address",
      "subtitle": "Home, office.. ",
      "route": Routes.MANAGEADDRESS,
    },
    {
      "icon": "assets/icon/cupon.svg",
      "title": "Coupons",
      "subtitle": "Available Discounts & Vouchers",
      "route": Routes.COUPONS,
    },
    {
      "icon": "assets/icon/drawerSupportticket.svg",
      "title": "Support ticket",
      "subtitle": "Customer Support, Quries..",
      "route": Routes.SUPPORTTICKET,
    },
    {
      "icon": "assets/icon/my_reviews.svg",
      "title": "My Reviews",
      "subtitle": "Manage your product reviews",
      "route": Routes.MY_REVIEWS,
    },
    {
      "icon": "assets/icon/profilecall.svg",
      "title": "Help/Customer Care",
      "subtitle": "Customer Support, FAQs",
      "route": Routes.HELPANDSUPPORT,
    },
  ];
  var gender = ''.obs;
  // var dropdownGender = 'Male'.obs;
  // var gender = [
  //   'Male',
  //   'Female',
  // ];
}
