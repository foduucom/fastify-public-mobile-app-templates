import 'dart:io';
import 'package:foduu_ecommerce/app/modules/auth/token_manager.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class OrderdetailController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  var isLoading = false.obs;
  var downloading = false.obs;

  var box = GetStorage();
  @override
  Future<void> onInit() async {
    super.onInit();
    if (Get.arguments != null && Get.arguments['id'] != null) {
      id.value = Get.arguments['id'];
    }

    await OrderDetail();
  }

  Future<void> OrderDetail() async {
    isLoading.value = true;
    var response = await BasicProvider("orders/show/$id")
        .getRequest()
        .catchError(handleError);

    if (response == null) return;
    item.value = response;
    isLoading.value = false;
  }

  // Future<void> downloadAndSavePDF(String orderId) async {
  //   final String apiUrl =
  //       'http://mern.foduu.com:3016/api/public/orders/exporttopdf/$id';
  //   // final String apiUrl = apiURL + endpiont;
  //   final PermissionStatus permissionStatus =
  //       await Permission.storage.request();
  //   if (permissionStatus != PermissionStatus.granted) {
  //     return;
  //   }
  //   try {
  //     final http.Response response = await http.get(Uri.parse(apiUrl));
  //     final appDocDir = await getExternalStorageDirectory();
  //     final List<int> bytes = response.bodyBytes;
  //     final String fileName = 'invoice_$orderId.pdf';
  //     // final String filePath = '${appDocDir!.path}/$fileName';
  //     final String filePath = '/storage/emulated/0/Download/$fileName';

  //     final File file = File(filePath);
  //     await file.writeAsBytes(bytes);
  //     HelperFunctions()
  //         .showSnackBarSuccess('Invoice downloaded and saved successfully');
  //     // launchUrl(file.path);
  //   } catch (e) {
  //     print('Error: $e');
  //     // Handle error
  //   }
  // }

  Future<void> downloadAndSavePDF(String id) async {
    if (await Permission.storage.request().isGranted) {
      try {
        downloading.value = true;

        final PermissionStatus permissionStatus =
            await Permission.storage.request();
        if (permissionStatus != PermissionStatus.granted) {
          // Handle permission denied
          return;
        }
        final url =
            'http://mern.foduu.com:3016/api/public/orders/exporttopdf/$id';
        final response = await Dio().get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );

        final directory = Platform.isAndroid
            ? await getExternalStorageDirectory()
            : await getApplicationDocumentsDirectory();

        final Uint8List bytes = Uint8List.fromList(response.data!);
        final appDocDir = await getExternalStorageDirectory();
        final String filePath = '/storage/emulated/0/Download/invoice_$id.pdf';
        final pdfPath = '${appDocDir!.path}/your_file_name.pdf';

        // await File(filePath).writeAsBytes(bytes);

        // print(response.data);

        // Use this for iOS
        // File(filePath).writeAsBytesSync(response.data);
        var file = File(filePath).openSync(mode: FileMode.write);
        file.writeFromSync(bytes);
        // final file = File(fielPath);
        // await file.writeAsBytes(response.data ,
        //     flush: false, mode: FileMode.writeOnly);
        // await file.close();
        downloading.value = false;
        HelperFunctions()
            .showSnackBarSuccess('Invoice downloaded and saved successfully');
      } catch (e) {
        print('error inn pdf downoad ${e}');
        downloading.value = false;
        HelperFunctions().showSnackBarError('Failed to download Invoice');
      }
    } else {
      print('permission denied');
    }
  }

  Map<String, String> headerType() {
    // var userData = box.read("userDetails");

    // print('token $userData');
    var token = TokenManager.accessToken;
    Map<String, String> userHeader;
    if (token != null) {
      userHeader = {
        "Accept": "application/json",
        "Authorization": "Bearer ${token}"
      };
    } else {
      userHeader = {
        "Accept": "application/json",
      };
    }
    return userHeader;
  }

  // Future<void> downloadAndSavePDF(String orderId) async {
  //   isLoading.value = true;

  //   final String endpiont = 'orders/pdf/$orderId';
  //   final String apiUrl = apiURL + endpiont;

  //   final PermissionStatus permissionStatus =
  //       await Permission.storage.request();
  //   // if (permissionStatus != PermissionStatus.granted) {
  //   //   return;
  //   // }
  //   try {
  //     final http.Response response =
  //         await http.get(Uri.parse(apiUrl), headers: headerType());
  //     final appDocDir = await getExternalStorageDirectory();
  //     final List<int> bytes = response.bodyBytes;
  //     final String fileName = 'invoice_$orderId.pdf';
  //     // final String filePath = '${appDocDir!.path}/$fileName';
  //     final String filePath = '/storage/emulated/0/Download/$fileName';

  //     final File file = File(filePath);
  //     await file.writeAsBytes(bytes);
  //     HelperFunctions()
  //         .showSnackBarSuccess('Invoice downloaded and saved successfully');
  //     // launchUrl(file.path);
  //     isLoading.value = false;
  //   } catch (e) {
  //     isLoading.value = false;

  //     print('Error: $e');
  //     // Handle error
  //   }
  // }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> postReview(
      {required String summary, required int rating}) async {
    var form = {
      'product': id,
      'rating': rating,
      'summary': summary,
    };
    var response = await BasicProvider("reviews/product")
        .postRequest(form)
        .catchError(handleError);
    print('$response     $id');
    if (response == null) return;
    HelperFunctions().showSnackBarSuccess('Review Send Successfully');
  }
}
