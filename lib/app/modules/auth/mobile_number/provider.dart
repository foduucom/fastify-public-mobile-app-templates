import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/constants/app_exceptions.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get_connect/connect.dart';

class OTPLoginProvider extends GetConnect {
  String fetchUrl(String path) {
    return apiURL + path;
  }

  Future<dynamic> sendLoginRequest(form) async {
    try {
      allowAutoSignedCert = true;
      // final response = await post(
      //   fetchUrl("auth/login"),
      //   form,
      // contentType: "application/json",
      // headers: {
      //   "Accept": "application/json",
      //   "Content-Type": "application/json",
      //   "access_key": accessToken,
      // },
      //);

      final response = await BasicProvider("auth/login").postRequest(form);
      return response;
    } on UnAuthorizedException catch (exception) {
      HelperFunctions().showSnackBarError(
          "We couldn't find an account with this information. Please check and try again.");
    } catch (exception) {
      HelperFunctions().showSnackBarError(
          "We couldn't find an account with this information. Please check and try again.");
      print('Mobile Login Error: $exception');
    }
  }
}
