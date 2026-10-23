import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart'
    as DioPackage; // Alias Dio's Response to avoid conflict
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zouhi/constants/helper_functions.dart'; // Assuming this exists for snackbars
import 'package:zouhi/app/data/basic_provider.dart'; // Import BasicProvider
import 'package:zouhi/constants/constants.dart'; // Import constants for apiURL

class InvoiceService {
  final DioPackage.Dio _dio = DioPackage.Dio();

  /// Downloads an invoice PDF for a given order ID.
  /// Returns the path to the downloaded file on success, or null on failure.
  Future<String?> downloadInvoice(String orderId) async {
    try {
      // Use BasicProvider to get the headers, leveraging its token management.
      // Instantiate BasicProvider with a dummy URL as we only need headerType().
      // The actual endpoint for the invoice will be constructed separately for Dio.
      final basicProvider = BasicProvider("dummy_url");
      final Map<String, String> headers = basicProvider.headerType();

      // BasicProvider's headerType already includes "Authorization" and "access_key"
      // based on TokenManager and constants.accessToken.
      // We check if these critical headers are present.
      if (!headers.containsKey('Authorization') ||
          !headers.containsKey('access_key')) {
        HelperFunctions().showSnackBarError(
            "Authentication token or access key missing. Please log in again.");
        return null;
      }

      // Get the application's documents directory for saving the file.
      // This is a private directory for the app and doesn't require
      // external storage permissions on Android/iOS.
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/Invoice_$orderId.pdf';

      // Construct the full API URL
      final url = '${apiURL}order/$orderId/invoice';

      Future<DioPackage.Response> fetch(Map<String, String> h) => _dio.get(
            url,
            options: DioPackage.Options(
              headers: h,
              responseType: DioPackage
                  .ResponseType.bytes, // Crucial for downloading file bytes
              followRedirects: false,
              validateStatus: (status) =>
                  status! < 500, // Accept 4xx responses for custom error handling
            ),
          );

      // The backend's API-key middleware requires Accept == application/json
      // exactly (even for PDF responses), so keep BasicProvider's headers as-is.
      DioPackage.Response response = await fetch(headers);

      // Dio bypasses BasicProvider's refresh-and-retry, so do it once here.
      if (response.statusCode == 401) {
        await BasicProvider.refreshSession();
        response = await fetch(basicProvider.headerType());
      }

      final bytes = response.data is List<int> ? response.data as List<int> : null;
      final isPdf = bytes != null &&
          bytes.length > 4 &&
          String.fromCharCodes(bytes.sublist(0, 4)) == '%PDF';

      if (response.statusCode == 200 && isPdf) {
        final file = File(filePath);
        await file.writeAsBytes(bytes);
        return file.path;
      } else {
        HelperFunctions().showSnackBarError(
            "Failed to download invoice. Status: ${response.statusCode}");
        print(
            'Invoice download failed: ${response.statusCode} - ${response.statusMessage}');
        print('Invoice url: $url');
        print('Invoice response body: '
            '${bytes == null ? response.data : utf8.decode(bytes, allowMalformed: true)}');
        return null;
      }
    } catch (e) {
      HelperFunctions()
          .showSnackBarError("An error occurred during invoice download: $e");
      print('Error downloading invoice: $e');
      return null;
    }
  }

  /// Displays an industry-standard floating SnackBar with an interactive OPEN action.
  void showDownloadSuccessSnackBar({
    required String filePath,
    required String orderId,
  }) {
    final context = Get.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          "Invoice downloaded successfully",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: "OPEN",
          textColor: Colors.amberAccent,
          onPressed: () => openFile(filePath),
        ),
      ),
    );
  }

  /// Opens a file using the device's default application.
  Future<void> openFile(String filePath) async {
    await OpenFilex.open(filePath);
  }

  /// Shares a file using the device's native share sheet.
  Future<void> shareFile(String filePath, String orderId) async {
    try {
      await Share.shareXFiles([XFile(filePath)], text: 'Invoice $orderId');
    } catch (e) {
      print('Error sharing file: $e');
    }
  }
}
