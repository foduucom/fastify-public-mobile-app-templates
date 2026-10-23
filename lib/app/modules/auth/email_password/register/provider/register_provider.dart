import 'package:zouhi/app/data/basic_provider.dart';
import 'package:get/get_connect/connect.dart';

class RegisterProvider extends GetConnect {
  Future<dynamic> sendRegisterCustomerRequest(form) async {
    try {
      final response = await BasicProvider("auth/register").postRequest(form);
      return response;
    } catch (e) {
      print('register provider error ${e.toString()}');
      rethrow;
    }
  }
}

