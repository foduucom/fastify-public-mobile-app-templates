import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '/core/services/wishlistService.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/app/modules/auth/auth_details.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

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

  // ── Innovative Daksh Store Metrics & State ──
  final ordersCount = 0.obs;
  final orderStatusLabel = 'No orders'.obs;
  final recentOrderNumber = ''.obs;
  final recentOrderStatus = ''.obs;
  final wishlistCount = 0.obs;
  final couponsCount = 0.obs;
  final featuredCouponCode = 'DAKSH15'.obs;
  final featuredCouponDiscount = '15% OFF'.obs;
  final walletBalance = 0.0.obs;

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
    await fetchExtraStats();
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
    // Guest profile screens use local guest content; never call the private
    // customer endpoint without an authenticated session.
    if (!AuthDetails.isUserLogin()) {
      profiledata.clear();
      addresses.clear();
      isLoading(false);
      return;
    }
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

        // Wallet Balance parsing
        if (response['wallet_balance'] != null) {
          walletBalance.value =
              double.tryParse(response['wallet_balance'].toString()) ?? 0.0;
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

  Future<void> fetchExtraStats() async {
    // 1. Wishlist Count
    try {
      if (Get.isRegistered<WishListService>()) {
        wishlistCount.value = WishListService.to.wishListItems.length;
      }
    } catch (_) {}

    // 2. Coupons Count & Featured Coupon. The coupons endpoint is private.
    if (AuthDetails.isUserLogin()) {
      try {
        final couponRes = await BasicProvider("coupons").getRequest();
        if (couponRes != null) {
          List? list;
          if (couponRes is List) {
            list = couponRes;
          } else if (couponRes is Map) {
            if (couponRes['data'] is List) {
              list = couponRes['data'] as List;
            } else if (couponRes['coupons'] is List) {
              list = couponRes['coupons'] as List;
            }
          }
          if (list != null) {
            couponsCount.value = list.length;
            if (list.isNotEmpty && list.first is Map) {
              final firstCpn = list.first as Map;
              if (firstCpn['code'] != null) {
                featuredCouponCode.value = firstCpn['code'].toString();
              }
              if (firstCpn['discount_value'] != null) {
                final val = firstCpn['discount_value'];
                final type =
                    (firstCpn['coupon_type'] ?? firstCpn['discount_type'] ?? '')
                        .toString()
                        .toLowerCase();
                featuredCouponDiscount.value =
                    type.contains('percent') ? '$val% OFF' : '\$$val OFF';
              }
            }
          }
        }
      } catch (_) {}
    }

    // 3. Orders Count & Recent Order
    if (AuthDetails.isUserLogin()) {
      try {
        final orderRes = await BasicProvider("order").getRequest();
        if (orderRes != null) {
          List? docs;
          if (orderRes is List) {
            docs = orderRes;
          } else if (orderRes is Map) {
            if (orderRes['docs'] is List) {
              docs = orderRes['docs'] as List;
            } else if (orderRes['data'] is List) {
              docs = orderRes['data'] as List;
            } else if (orderRes['data'] is Map &&
                orderRes['data']['docs'] is List) {
              docs = orderRes['data']['docs'] as List;
            }
          }
          if (docs != null) {
            ordersCount.value = docs.length;
            orderStatusLabel.value =
                docs.isNotEmpty ? '${docs.length} orders' : 'In transit';
            if (docs.isNotEmpty && docs.first is Map) {
              final recent = docs.first as Map;
              recentOrderNumber.value = recent['order_id']?.toString() ??
                  recent['_id']?.toString() ??
                  '';
              recentOrderStatus.value = recent['order_status']?.toString() ??
                  recent['status']?.toString() ??
                  'In Transit';
            }
          }
        }
      } catch (_) {}
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
        Get.until((route) => Get.isDialogOpen != true);

        if (response == null) return;
        // Evict old cached image so the updated one loads fresh
        if (imagePath.value.contains("http")) {
          await CachedNetworkImage.evictFromCache(imagePath.value);
        }
        await fetchDataFromServer();
        isLoading(false);

        Get.until((route) => Get.isDialogOpen != true);
        await AuthDetails().updateUserDetailsFromServer();
        //Get.find<BottombarController>().authDetails.value = updatedprofile;
        // HelperFunctions().showSnackBarSuccess(response["status"]);
        Get.until((route) => Get.isDialogOpen != true);
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
