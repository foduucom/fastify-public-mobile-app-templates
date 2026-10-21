import 'dart:io';
import '/constants/constants.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '/app/controllers/api_exception_handle_controller.dart';
import '/app/data/basic_provider.dart';
import '/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class OrderdetailController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  var isLoading = false.obs;
  var downloading = false.obs;

  final List<String> stages = [
    'Order Placed',
    'Processing',
    'Shipped',
    'Out for Delivery',
    'Delivered',
  ];

  @override
  Future<void> onInit() async {
    super.onInit();
    if (Get.arguments != null && Get.arguments['id'] != null) {
      id.value = Get.arguments['id'].toString();
    }

    await OrderDetail();
  }

  Future<void> OrderDetail() async {
    try {
      isLoading.value = true;
      var response = await BasicProvider("order/$id")
          .getRequest()
          .catchError(handleError);

      printInfo(info: 'OrderDetail response: $response');
      if (response == null) return;

      item.value = response;
    } catch (e) {
      print('Error in OrderDetail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Returns the current stage index (1-based) based on order status.
  int getCurrentStage() {
    final orderData = item.containsKey('data') && item['data'] is Map
        ? item['data']
        : item;
    final status = (orderData['status'] is Map
            ? orderData['status']['name']
            : orderData['status'])
        ?.toString()
        .toLowerCase() ??
        '';
    if (status.contains('delivered')) return 5;
    if (status.contains('out for delivery') ||
        status.contains('out_for_delivery')) return 4;
    if (status.contains('shipped')) return 3;
    if (status.contains('processing')) return 2;
    return 1; // Order Placed
  }

  Future<void> downloadAndSavePDF(String id) async {
    final orderData = item.containsKey('data') && item['data'] is Map ? item['data'] : item;
    final paymentMethod = (orderData['payment_method'] ?? '').toString().toLowerCase();
    final paymentStatus = (orderData['payment_status'] ?? '').toString().toLowerCase();
    if (paymentMethod == 'cod' && paymentStatus != 'paid') {
      HelperFunctions().showSnackBarError('Invoice will be available after payment is completed on delivery.');
      return;
    }
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
    var response = await BasicProvider("public/reviews/product")
        .postRequest(form)
        .catchError(handleError);
    print('$response     $id');
    if (response == null) return;
    HelperFunctions().showSnackBarSuccess('Review Send Successfully');
  }
}
