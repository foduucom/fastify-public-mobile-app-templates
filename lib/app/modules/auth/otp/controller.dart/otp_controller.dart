import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/core/services/cartServcie.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum OtpContext { login, register }

class OtpController extends GetxController with BaseController {
  var isLoading = false.obs;
  var isResendVisible = false.obs;
  final box = GetStorage();
  var otpCode = "".obs;
  var otpLength = 6.obs;

  // Context-specific variables
  var email = "".obs;
  var otpContext = OtpContext.login.obs;

  @override
  Future<void> onInit() async {
    super.onInit();

    // Get arguments passed from login/register screen
    final args = Get.arguments;
    if (args != null) {
      email.value = args['email'] ?? '';
      otpLength.value = args['codeLength'] ?? 6;

      // Determine context
      String contextStr = args['context'] ?? 'login';
      otpContext.value =
          contextStr == 'register' ? OtpContext.register : OtpContext.login;

      print(
          'OTP Screen - Email: ${email.value}, Context: ${otpContext.value}, Length: ${otpLength.value}');
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  /// Verify OTP based on context
  Future<void> verifyOtp({required String otp}) async {
    otpCode.value = otp;
    if (otpCode == "" || otpCode.value.length < otpLength.value) {
      HelperFunctions().showSnackBarError("Please enter OTP");
      return;
    }

    isLoading(true);

    try {
      var body = {};
      if (otpContext.value == OtpContext.login) {
        body = {
          'email': email.value,
          'otp': otp,
          // 'device_details': await HelperFunctions.getDeviceDetails(),
        };
      } else {
        body = {
          'email': email.value,
          'otp': otp,
          // 'device_details': await HelperFunctions.getDeviceDetails(),
        };
      }

      print('body ${body}');

      var response = await BasicProvider('auth/verify-otp')
          .postRequest(body)
          .catchError(handleError);

      print('response from otp controller api response ${response}');

      if (response != null) {
        AuthDetails.saveLoginResponse(response);

        // Sync any local (guest) cart items to the server
        await CartService.to.syncLocalCartToServer();

        Get.toNamed(Routes.BOTTOMBAR);
      }

      // if()
    } catch (error) {
      isLoading(false);
      print('OTP verification error: $error');
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    isResendVisible(false);
    isLoading(true);

    try {
      var body = {};
      if (otpContext.value == OtpContext.login) {
        body = {
          'email': email.value,
          'device_details': await HelperFunctions.getDeviceDetails(),
        };
      } else {
        body = {
          'email': email.value,
          'device_details': await HelperFunctions.getDeviceDetails(),
        };
      }

      var response = await BasicProvider('auth/resend-otp')
          .postRequest(body)
          .catchError(handleError);

      print('Login Otp Success Response ${response}');
      isLoading(false);
    } catch (error) {
      isLoading(false);
      print('Error resending OTP: $error');
    }
  }
}
