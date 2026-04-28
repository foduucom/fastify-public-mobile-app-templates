import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class HelperFunctions {
  static double parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static String getNoImage() {
    // return 'https://st4.depositphotos.com/14953852/24787/v/450/depositphotos_247872612-stock-illustration-no-image-available-icon-vector.jpg';
    return 'https://static.vecteezy.com/system/resources/thumbnails/004/141/669/small/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg';
  }

  void closeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  void showSnackBarError(String message) {
    Get.snackbar("Error!", message,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        // animationDuration: Duration(microseconds: 2000),
        duration: const Duration(seconds: 3));
  }

  void showSnackBarSuccess(String message) {
    Get.snackbar("Success!", message,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        isDismissible: true,
        dismissDirection: DismissDirection.horizontal,
        duration: const Duration(seconds: 5));
  }

  Widget loadingIndicator({color, themePrimaryColor}) {
    return Center(
        child: CircularProgressIndicator(
      strokeWidth: 1.9,
      color: color,
    ));
  }

  void showOverlayLoader({barrierDismissible = false}) {
    bool isKeyboardOpen() {
      return WidgetsBinding.instance.focusManager.primaryFocus?.hasFocus ??
          false;
    }

    if (isKeyboardOpen()) {
      Get.dialog(
        Center(
          child: Container(
            height: 130,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 30,
                      width: 30,
                      child: HelperFunctions().loadingIndicator(),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Loading...",
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        barrierDismissible: barrierDismissible,
      );
    }
  }

  //---------------START: For Image Picker from Gallery or Camera ---------------//
  Future<String> getImageFromGalleryOrCamera(imageSource) async {
    final ImagePicker pickedFile = ImagePicker();
    final XFile? image = await pickedFile.pickImage(source: imageSource);
    if (image != null) {
      File file = File(image.path);
      if (file.absolute.path.endsWith(".jpg") ||
          file.absolute.path.endsWith(".jpeg") ||
          file.absolute.path.endsWith(".png") ||
          file.absolute.path.endsWith(".webp")) {
        var compressImage = await compressFile(file);
        return compressImage!.path;
      } else {
        HelperFunctions().showSnackBarError("Invalid image format!");
        return "";
      }
    }
    return "";
  }

  Future<XFile?> compressFile(File file) async {
    final filePath = file.absolute.path;
    // Create output file path
    // eg:- "Volume/VM/abcd_out.jpeg"
    final lastIndex;
    var compressFormat;
    if (filePath.endsWith(".jpg") || filePath.endsWith(".jpeg")) {
      lastIndex = filePath.lastIndexOf(RegExp(r'.jp'));
      compressFormat = CompressFormat.jpeg;
    } else if (filePath.endsWith(".png")) {
      lastIndex = filePath.lastIndexOf(RegExp(r'.png'));
      compressFormat = CompressFormat.png;
    } else if (filePath.endsWith(".webp")) {
      lastIndex = filePath.lastIndexOf(RegExp(r'.webp'));
      compressFormat = CompressFormat.webp;
    } else {
      lastIndex = filePath.lastIndexOf(RegExp(r'.jpeg'));
      compressFormat = CompressFormat.jpeg;
    }

    final splitted = filePath.substring(0, (lastIndex));
    final outPath = "${splitted}_out${filePath.substring(lastIndex)}";
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      outPath,
      quality: 70,
      format: compressFormat,
    );
    // print(file.lengthSync());
    // print(result!.lengthSync());
    return result;
  }
  //---------------END: For Image Picker from Gallery or Camera ---------------//

  //---------------START: For Multiple Image Picker from Gallery or Camera ---------------//
  Future<List<String>> getMultiplesImagesFromGalleryOrCamera() async {
    final ImagePicker pickedFile = ImagePicker();
    final List<XFile>? images =
        await pickedFile.pickMultiImage(imageQuality: 60);
    final List<String> imagesPath = [];
    if (images != null) {
      for (var image in images) {
        File file = File(image.path);
        var compressImage = await compressFile(file);
        imagesPath.add(compressImage!.path);
      }
      return imagesPath;
    }
    return imagesPath;
  }
  //---------------END: For Image Picker from Gallery or Camera ---------------//

  final int timerMaxSeconds = 60;

  int currentSeconds = 0;
  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  Future<String> Otptimer() async {
    final interval = const Duration(seconds: 1);

    // startTimeout([int? milliseconds]) {
    var duration = interval;
    Timer.periodic(duration, (timer) {
      print(timer.tick);
      currentSeconds = timer.tick;
      if (timer.tick >= timerMaxSeconds) {
        timer.cancel();
      }
    });
    // }
    return "";
  }

  var _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  String likeCountFormat(count) {
    if (count is String) {
      count = int.parse(count);
    }
    if (count == 0) {
      return "0";
    }
    if (count >= 1000 && count <= 1100) {
      return (count / 1000).toString() + "K";
    }
    if (count >= 1100) {
      return (count / 1000).toStringAsFixed(1) + "K";
    }

    return count.toString();
  }

  static defaultdialogbox(String title) {
    return Get.defaultDialog(
        barrierDismissible: false,
        titlePadding: const EdgeInsets.only(top: 0),
        title: '',
        titleStyle: const TextStyle(fontSize: 0),
        content: Column(
          children: [
            Icon(Icons.check_circle, size: 50),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ));
  }

  void showOverlayIconDialog(
      {barrierDismissible = false,
      icon = Icons.check_circle,
      text = "Success"}) {
    Get.dialog(
      Center(
        child: Container(
          height: 170,
          width: 250,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    child: Icon(icon, size: 50),
                  ),
                  SizedBox(height: 10),
                  Text(
                    text,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: Text("OK"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  String toCarbonToHumanDateFormat(String dateTimeToFromat) {
    DateTime dateTime = DateTime.parse(dateTimeToFromat);
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
    return formattedDate;
  }

  static double lowestPrice(List<dynamic> variantIds) {
    if (variantIds.isEmpty) return 0.0;
    double? minPrice;
    for (var variant in variantIds) {
      double currentPrice =
          parseAmount(variant['sale_price'] ?? variant['price']);
      if (minPrice == null || currentPrice < minPrice) {
        minPrice = currentPrice;
      }
    }
    return minPrice ?? 0.0;
  }

  static double highestPrice(List<dynamic> variantIds) {
    double maxPrice = 0;
    for (var variant in variantIds) {
      double currentPrice =
          parseAmount(variant['sale_price'] ?? variant['price']);
      if (currentPrice > maxPrice) {
        maxPrice = currentPrice;
      }
    }
    return maxPrice;
  }

  static Future<Map<String, dynamic>> getDeviceDetails() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      var webBrowserInfo = await deviceInfo.webBrowserInfo;
      return {
        'type': 'web',
        'mobile_name': webBrowserInfo.browserName.toString(),
        'brand': webBrowserInfo.vendor ?? 'Unknown',
        'version': webBrowserInfo.appVersion ?? 'Unknown',
        'device_identifier': webBrowserInfo.userAgent ?? 'Unknown',
      };
    } else if (Platform.isAndroid) {
      var androidInfo = await deviceInfo.androidInfo;
      return {
        'type': Platform.operatingSystem,
        'mobile_name': androidInfo.model,
        'brand': androidInfo.manufacturer,
        'version': androidInfo.version.release,
        'device_identifier': androidInfo.id.toString(),
      };
    } else {
      var iosInfo = await deviceInfo.iosInfo;
      return {
        'type': Platform.operatingSystem,
        'mobile_name': iosInfo.utsname.machine,
        'brand': iosInfo.model,
        'version': iosInfo.systemVersion,
        'device_identifier': iosInfo.identifierForVendor,
      };
    }
  }

  String getImage(dynamic featuredImage, {bool? isLog, String? moduleName}) {
    // Case 0: featuredImage is a List
    if (featuredImage is List && featuredImage.isNotEmpty) {
      featuredImage = featuredImage.first;
    }

    // Case 1: featuredImage is a Map
    if (featuredImage is Map) {
      final path = featuredImage['filePath'] ??
          featuredImage['filepath'] ??
          featuredImage['filename'];

      if (path != null && path.toString().isNotEmpty) {
        final imageUrl = '${url}images/$path';

        if (isLog == true) {
          print('swapnil path $moduleName => $imageUrl');
        }

        return imageUrl;
      }
    }

    if (featuredImage is String && featuredImage.isNotEmpty) {
      // A bare MongoDB ObjectId (24 hex chars, no path separators) is not a
      // valid image path — guard against the cart/manage response inconsistency.
      final isRawId = RegExp(r'^[a-f0-9]{24}$').hasMatch(featuredImage);
      if (isRawId) return HelperFunctions.getNoImage();

      final imageUrl = '${url}images/$featuredImage';

      if (isLog == true) {
        print('swapnil path $moduleName => $imageUrl');
      }

      return imageUrl;
    }

    // Fallback
    return HelperFunctions.getNoImage();
  }
}
