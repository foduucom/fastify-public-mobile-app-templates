import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/constants/app_exceptions.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/connect.dart';

class LoginProvider extends GetConnect {
  String fetchUrl(String path) {
    print(apiURL + path);
    return apiURL + path;
  }

  Future<dynamic> sendLoginRequest(form) async {
    try {
      allowAutoSignedCert = true;
      final response = await BasicProvider("auth/login").postRequest(form);
      return response;
    } on AppException catch (exception) {
      print('Login AppException: ${exception.message}');
      String msg = (exception.message != null && exception.message!.trim().isNotEmpty)
          ? exception.message!
          : "We couldn't find an account with this information. Please check and try again.";
      HelperFunctions().showSnackBarError(msg);
      return null;
    } catch (exception) {
      print('Login Error: $exception');
      final msg = errorMessageOf(exception,
          fallback: "Login failed. Please check your credentials and try again.");
      HelperFunctions().showSnackBarError(msg);
      return null;
    }
  }
}
