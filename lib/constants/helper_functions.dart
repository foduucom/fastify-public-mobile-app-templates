import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/components/foduuformtextfield.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';

import 'package:zouhi/components/buttons/appbutton.dart';

class HelperFunctions {
  static double parseAmount(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static final Map<dynamic, String> _imageUrlCache = {};
  static DateTime? _lastErrorSnackBarTime;
  static String? _lastErrorSnackBarMessage;

  static dynamic _generateCacheKey(dynamic input) {
    if (input == null) return 'null_key';
    if (input is Map) {
      final pathKey = input['download_url']?.toString() ??
          input['downloadUrl']?.toString() ??
          input['url']?.toString() ??
          input['filePath']?.toString() ??
          input['filepath']?.toString() ??
          input['filename']?.toString();

      if (pathKey != null && pathKey.trim().isNotEmpty) {
        final id = input['_id']?.toString();
        return id != null ? '${id}_$pathKey' : pathKey;
      }

      return input['_id']?.toString() ?? input.toString();
    }
    if (input is List) {
      return input.isNotEmpty ? _generateCacheKey(input.first) : 'empty_list';
    }
    return input;
  }

  static String getNoImage() {
    return '';
  }

  void closeKeyboard(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  static String sanitizeErrorMessage(String rawMessage) {
    if (rawMessage.trim().isEmpty) {
      return "Something went wrong. Please try again.";
    }

    String msg = rawMessage.trim();

    // If it's already a clean user-facing account error, return as is
    if (msg.contains("couldn't find an account") ||
        msg.contains("account with this information")) {
      return msg;
    }

    // 1. If it's a login endpoint error or 404 on login
    if (msg.contains("api/auth/login") || msg.contains("auth/login")) {
      return "We couldn't find an account with this information. Please check and try again.";
    }

    // 2. Generic 404 / requested url not exist for other endpoints
    if (msg.contains("Requested URL not exist") || msg.contains("404")) {
      return "Service temporarily unavailable. Please try again later.";
    }

    // 2. Handle technical connectivity exceptions
    if (msg.contains("SocketException") || msg.contains("unreachable")) {
      return "Please check if your internet connection is stable!";
    }
    if (msg.contains("TimeoutException")) {
      return "Connection timed out. Please try again.";
    }

    // 3. Strip exception class prefixes
    final prefixes = [
      RegExp(r'^Bad Request:\s*', caseSensitive: false),
      RegExp(r'^FetchDataException:\s*', caseSensitive: false),
      RegExp(r'^UnAuthorized request:\s*', caseSensitive: false),
      RegExp(r'^AppException:\s*', caseSensitive: false),
      RegExp(r'^Exception:\s*', caseSensitive: false),
    ];
    for (var prefix in prefixes) {
      msg = msg.replaceAll(prefix, '');
    }

    // 4. Strip any http/https URLs from user message
    msg = msg.replaceAll(RegExp(r'https?://[^\s]+'), '').trim();

    // 5. Final fallback if sanitized message becomes empty
    if (msg.isEmpty || msg == "Error" || msg == "Bad Request") {
      return "Something went wrong. Please try again.";
    }

    return msg;
  }

  void showSnackBarError(String rawMessage) {
    final message = sanitizeErrorMessage(rawMessage);
    final context = Get.context;
    if (context != null) {
      final now = DateTime.now();
      if (_lastErrorSnackBarMessage == message &&
          _lastErrorSnackBarTime != null &&
          now.difference(_lastErrorSnackBarTime!) <
              const Duration(seconds: 4)) {
        return;
      }
      _lastErrorSnackBarTime = now;
      _lastErrorSnackBarMessage = message;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void showSnackBarSuccess(String message) {
    final context = Get.context;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
      final ctx = Get.context;
      Get.dialog(
        Center(
          child: Container(
            height: 130,
            width: 100,
            decoration: BoxDecoration(
              color: (ctx != null ? ctx.themeWhiteColor : Colors.white)
                  .withOpacity(0.8),
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
                    Text(
                      "Loading...",
                      style: TextStyle(
                          fontSize: 14,
                          color:
                              ctx != null ? ctx.themeTextColor : Colors.black),
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

  // Hide overlay loader dialog
  void hideOverlayLoader() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
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

  Color showJobStatus(String status) {
    Color labelBackColor;
    if (status == "Processing") {
      labelBackColor = Colors.orange.shade400;
    } else if (status == "Completed") {
      labelBackColor = themeSecondryColor;
    } else if (status == "Pending") {
      labelBackColor = Colors.deepPurpleAccent.shade700;
    } else if (status == "Approve") {
      labelBackColor = Colors.deepPurpleAccent.shade400;
    } else {
      labelBackColor = Colors.red;
    }
    return labelBackColor;
  }

  final int timerMaxSeconds = 60;

  int currentSeconds = 0;
  String get timerText =>
      '${((timerMaxSeconds - currentSeconds) ~/ 60).toString().padLeft(2, '0')}: ${((timerMaxSeconds - currentSeconds) % 60).toString().padLeft(2, '0')}';

  Future<String> Otptimer() async {
    final interval = const Duration(seconds: 1);

    // startTimeout([int? milliseconds]) {
    var duration = interval;
    Timer.periodic(duration, (timer) {
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

  static defaultdialogbox(String title, Color colour) {
    return Get.defaultDialog(
      barrierDismissible: false,
      titlePadding: const EdgeInsets.all(30),
      title: '',
      titleStyle: const TextStyle(fontSize: 0),
      content: Column(
        children: [
          Icon(Icons.check_circle, color: colour, size: 50),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
      actions: [
        // ElevatedButton(
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: colour,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //   ),
        //   onPressed: () {
        //     Get.back(); // closes dialog
        //   },
        //   child: const Text("Close", style: TextStyle(color: Colors.white)),
        // ),
        AppButton(
          width: 250,
          itemText: 'close',
          keypressEvent: () {
            Get.back();
          },
        )
      ],
    );
  }

  void showOverlayIconDialog(
      {barrierDismissible = false,
      icon = Icons.check_circle_outline_rounded,
      text = "Success"}) {
    final ctx = Get.context;
    Get.dialog(
      Center(
        child: Container(
          height: 170,
          width: 250,
          decoration: BoxDecoration(
            color: (ctx != null ? ctx.themeWhiteColor : Colors.white)
                .withOpacity(1),
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
                    style: TextStyle(
                        fontSize: 16,
                        color: ctx != null ? ctx.themeTextColor : Colors.black),
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

  String toCarbonToHumanDateFormat(dynamic dateTimeToFormat) {
    if (dateTimeToFormat == null ||
        dateTimeToFormat == "null" ||
        dateTimeToFormat.toString().trim().isEmpty) {
      return "";
    }
    try {
      DateTime dateTime = DateTime.parse(dateTimeToFormat.toString());
      String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime);
      return formattedDate;
    } catch (e) {
      return "";
    }
  }

  static String formatOrderPlacedDate(dynamic raw) {
    if (raw == null) return "";
    DateTime? dt;

    if (raw is Map) {
      // 1. Direct date keys
      final candidate = raw['createdAt'] ??
          raw['created_at'] ??
          raw['order_date'] ??
          raw['date'] ??
          raw['synced_at'] ??
          (raw['payments'] is List && (raw['payments'] as List).isNotEmpty
              ? raw['payments'][0]['paid_at'] ??
                  raw['payments'][0]['createdAt'] ??
                  raw['payments'][0]['created_at']
              : null);
      if (candidate != null &&
          candidate.toString().trim().isNotEmpty &&
          candidate.toString() != "null") {
        dt = DateTime.tryParse(candidate.toString())?.toLocal();
      }

      // 2. Parse from order_no (e.g. 2610140004 -> YY=26, MM=10, DD=14)
      if (dt == null) {
        final orderNo = (raw['order_no'] ?? raw['orderNo'] ?? '').toString();
        if (orderNo.length >= 6 && RegExp(r'^\d{6}').hasMatch(orderNo)) {
          final yy = int.tryParse(orderNo.substring(0, 2));
          final mm = int.tryParse(orderNo.substring(2, 4));
          final dd = int.tryParse(orderNo.substring(4, 6));
          if (yy != null &&
              mm != null &&
              dd != null &&
              mm >= 1 &&
              mm <= 12 &&
              dd >= 1 &&
              dd <= 31) {
            dt = DateTime(2000 + yy, mm, dd);
          }
        }
      }

      // 3. Parse from MongoDB _id (first 8 hex characters represent unix timestamp)
      if (dt == null) {
        final id = (raw['_id'] ?? '').toString();
        if (id.length >= 8) {
          final seconds = int.tryParse(id.substring(0, 8), radix: 16);
          if (seconds != null && seconds > 1000000000) {
            dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toLocal();
          }
        }
      }
    } else if (raw is DateTime) {
      dt = raw.toLocal();
    } else if (raw is num) {
      final val = raw.toInt();
      dt = DateTime.fromMillisecondsSinceEpoch(
              val > 1000000000000 ? val : val * 1000)
          .toLocal();
    } else {
      final str = raw.toString().trim();
      if (str.isEmpty || str == "null") return "";

      // Check if it's an ISO date string
      dt = DateTime.tryParse(str)?.toLocal();

      // Check if it's order_no YYMMDDxxxx
      if (dt == null && str.length >= 6 && RegExp(r'^\d{6}').hasMatch(str)) {
        final yy = int.tryParse(str.substring(0, 2));
        final mm = int.tryParse(str.substring(2, 4));
        final dd = int.tryParse(str.substring(4, 6));
        if (yy != null &&
            mm != null &&
            dd != null &&
            mm >= 1 &&
            mm <= 12 &&
            dd >= 1 &&
            dd <= 31) {
          dt = DateTime(2000 + yy, mm, dd);
        }
      }

      // Check if it's MongoDB ObjectId (24 hex characters)
      if (dt == null &&
          str.length >= 8 &&
          RegExp(r'^[0-9a-fA-F]{8}').hasMatch(str)) {
        final seconds = int.tryParse(str.substring(0, 8), radix: 16);
        if (seconds != null && seconds > 1000000000) {
          dt = DateTime.fromMillisecondsSinceEpoch(seconds * 1000).toLocal();
        }
      }
    }

    if (dt == null) {
      return "";
    }

    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    String suffix;
    final day = dt.day;
    if (day >= 11 && day <= 13) {
      suffix = 'th';
    } else {
      switch (day % 10) {
        case 1:
          suffix = 'st';
          break;
        case 2:
          suffix = 'nd';
          break;
        case 3:
          suffix = 'rd';
          break;
        default:
          suffix = 'th';
      }
    }
    return '$day$suffix ${months[dt.month - 1]}, ${dt.year}';
  }

  // static int lowestPrice(List<dynamic> variantIds) {
  //   int minPrice = variantIds.isEmpty ? null : variantIds.first['sale_price'];
  //   for (var variant in variantIds) {
  //     if (variant['sale_price'] < minPrice) {
  //       minPrice = variant['sale_price'];
  //     }
  //   }
  //   return minPrice;
  // }

  // static int highestPrice(List<dynamic> variantIds) {
  //   int maxPrice = 0;
  //   for (var variant in variantIds) {
  //     if (variant['sale_price'] > maxPrice) {
  //       maxPrice = variant['sale_price'];
  //     }
  //   }
  //   return maxPrice;
  // }
  static int lowestPrice(List<dynamic> variantIds) {
    if (variantIds.isEmpty) return 0;

    int? minPrice;
    for (var variant in variantIds) {
      int salePrice = variant['sale_price'];
      int finalPrice = salePrice > 0 ? salePrice : variant['price'];
      if (minPrice == null || finalPrice < minPrice) {
        minPrice = finalPrice;
      }
    }

    return minPrice ?? 0;
  }

  static int highestPrice(List<dynamic> variantIds) {
    if (variantIds.isEmpty) return 0;

    int maxPrice = 0;
    for (var variant in variantIds) {
      int salePrice = variant['sale_price'];
      int finalPrice = salePrice > 0 ? salePrice : variant['price'];
      if (finalPrice > maxPrice) {
        maxPrice = finalPrice;
      }
    }

    return maxPrice;
  }

  static void showLoginDialog(String msg) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          "Login Required",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Get.back(), // Close the dialog
            child: Text("Cancel",
                style: TextStyle(
                    color: Get.context?.themeSecondrytext ?? Colors.grey)),
          ),
          AppButton(
            width: 120,
            fontSize: 10,
            itemText: 'Go to Login',
            keypressEvent: () {
              Get.toNamed(Routes.LOGIN);
              // HelperFunctions().closeKeyboard(context);
              // controller.onSubmit();
            },
          ),
        ],
      ),
    );
  }

  static bool checkAndPromptLogin({String? message}) {
    if (!AuthDetails.isUserLogin()) {
      showLoginDialog(message ?? "Please login to proceed.");
      return false;
    }
    return true;
  }

  // static Future<int?> showQuantitySelectBox() {
  //   int selectedQuantity = 10; // Default quantity
  //   return Get.dialog<int>(
  //     StatefulBuilder(
  //       builder: (context, setState) {
  //         return AlertDialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //           title: const Text(
  //             "Select Bulk Quantity",
  //             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //           ),
  //           content: DropdownButton<int>(
  //             value: selectedQuantity,
  //             isExpanded: true,
  //             items: const [
  //               DropdownMenuItem(value: 10, child: Text("10")),
  //               DropdownMenuItem(value: 20, child: Text("20")),
  //               DropdownMenuItem(value: 30, child: Text("30")),
  //               DropdownMenuItem(value: 40, child: Text("40")),
  //               DropdownMenuItem(value: 50, child: Text("50")),
  //             ],
  //             onChanged: (value) {
  //               if (value != null) {
  //                 setState(() {
  //                   selectedQuantity = value;
  //                 });
  //               }
  //             },
  //           ),
  //           actions: [
  //             TextButton(
  //               onPressed: () => Get.back(result: -1), // Close the dialog
  //               child: const Text(
  //                 "Cancel",
  //                 style: TextStyle(color: Colors.grey),
  //               ),
  //             ),
  //             AppButton(
  //               width: 120,
  //               fontSize: 10,
  //               itemText: 'Add Quantity',
  //               keypressEvent: () {
  //                 // You can perform any additional actions here
  //                 print("Selected bulk quantity: $selectedQuantity");
  //                 Get.back(result: selectedQuantity);
  //               },
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );
  // }
  static Future<int?> showQuantitySelectBox(int defaultQuantity) {
    // int selectedQuantity = 10; // Default quantity
    TextEditingController controller =
        TextEditingController(text: defaultQuantity.toString());

    return Get.dialog<int>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text(
              "Add Bulk Quantity",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            content: FoduuFormTextField(
              controller: controller,
              keyType: TextInputType.number,
              validationmsg: 'Please enter valid quantity',
              title: 'Enter Quantity',
              fieldHintText: 'Enter Quantity',
              validCheck: (p0) {
                int? inputVal = int.tryParse(p0!);
                if (inputVal != null && inputVal > 0) {
                  // setState(() {
                  //   selectedQuantity = inputVal;
                  // });
                  return null;
                }
                return 'Please enter valid quantity';
              },
              // : const InputDecoration(
              //   labelText: "Enter Quantity",
              // ),
              // : (value) {
              //   int? inputVal = int.tryParse(value);
              //   if (inputVal != null) {
              //     setState(() {
              //       selectedQuantity = inputVal;
              //     });
              //   }
              // },
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: -1), // Close the dialog
                child: Text(
                  "Cancel",
                  style: TextStyle(color: context.themeSecondrytext),
                ),
              ),
              AppButton(
                width: 120,
                fontSize: 10,
                itemText: 'Add Quantity',
                keypressEvent: () {
                  // print("Selected bulk quantity: $selectedQuantity");
                  Get.back(result: int.tryParse(controller.text));
                },
              ),
            ],
          );
        },
      ),
    );
  }

  static Future<bool?> showRemoveSaapDialog() {
    return Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          "Confirm Removal",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Removing your SAP Code will move your account from B2B to B2C. Do you want to proceed?",
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false), // Cancel removal
            child: Text("Cancel",
                style: TextStyle(
                    color: Get.context?.themeSecondrytext ?? Colors.grey)),
          ),
          TextButton(
            onPressed: () => Get.back(result: true), // Confirm removal
            child: const Text("Remove"),
          ),
        ],
      ),
    );
  }

  static Future<String?> showAddSaapDialog() {
    final TextEditingController saapController = TextEditingController();
    return Get.dialog<String>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          "Add SAP Code",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Adding a SAP Code will move your account from B2C to B2B. Please enter your SAP Code below:",
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: saapController,
              decoration: const InputDecoration(
                hintText: "Enter SAP Code",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: null), // Cancel adding SAP code
            child: Text("Cancel",
                style: TextStyle(
                    color: Get.context?.themeSecondrytext ?? Colors.grey)),
          ),
          // TextButton(
          //   onPressed: () {
          // final String enteredCode = saapController.text.trim();
          // if (enteredCode.isNotEmpty) {
          //   Get.back(result: enteredCode); // Return the entered SAP code
          // } else {
          //   Get.snackbar("Error", "Please enter a valid SAP Code.");
          // }
          //   },
          //   child: const Text("Add"),
          // ),
          AppButton(
            width: 120,
            fontSize: 10,
            itemText: 'Add',
            keypressEvent: () {
              //  Get.back(result: selectedQuantity);
              final String enteredCode = saapController.text.trim();
              if (enteredCode.isNotEmpty) {
                Get.back(result: enteredCode); // Return the entered SAP code
              } else {
                Get.snackbar("Error", "Please enter a valid SAP Code.");
              }
            },
          ),
        ],
      ),
    );
  }

  static Widget buildStatusChip(String status) {
    Color bgColor;
    switch (status.toLowerCase()) {
      case 'close':
        bgColor = Colors.red.shade300;
        break;
      case 'pending':
        bgColor = Colors.orange.shade300;
        break;
      default:
        bgColor = Colors.green.shade300;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  static Widget buildPriorityChip(String priority) {
    Color bgColor;
    switch (priority.toLowerCase()) {
      case 'high':
        bgColor = Colors.red.shade200;
        break;
      case 'medium':
        bgColor = Colors.orange.shade200;
        break;
      default:
        bgColor = Colors.blue.shade200;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration:
          BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
      child: Text(
        priority.toUpperCase(),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
    );
  }

  String getImage(dynamic featuredImage, {bool? isLog, String? moduleName}) {
    if (featuredImage == null) {
      return HelperFunctions.getNoImage();
    }

    // Case 0: featuredImage is a List of candidates
    if (featuredImage is List) {
      for (var item in featuredImage) {
        String res = getImage(item, isLog: isLog, moduleName: moduleName);
        if (res != HelperFunctions.getNoImage()) {
          return res;
        }
      }
      return HelperFunctions.getNoImage();
    }

    if (featuredImage is String && featuredImage.trim().isEmpty) {
      return HelperFunctions.getNoImage();
    }

    final cacheKey = _generateCacheKey(featuredImage);
    final noImageUrl = HelperFunctions.getNoImage();

    if (_imageUrlCache.containsKey(cacheKey)) {
      final cached = _imageUrlCache[cacheKey]!;
      if (cached != noImageUrl) {
        final uri = Uri.tryParse(cached);
        if (uri != null && uri.hasAuthority && uri.host.isNotEmpty) {
          return cached;
        }
      }
    }

    String resolvedUrl = _processImageSource(featuredImage, isLog, moduleName);

    // Validate resolvedUrl has host
    final uri = Uri.tryParse(resolvedUrl);
    if (uri == null || !uri.hasAuthority || uri.host.isEmpty) {
      resolvedUrl = noImageUrl;
    }

    if (resolvedUrl != noImageUrl) {
      _imageUrlCache[cacheKey] = resolvedUrl;
    }

    return resolvedUrl;
  }

  String _normalizeImageUrl(String rawUrl) {
    String urlStr = rawUrl.trim();
    if (urlStr.contains('/owner/images/')) {
      urlStr = urlStr.replaceAll('/owner/images/', '/images/');
    }
    // Backend may return tenant / website_id subdomains (e.g. https://6a92a52778a2a51e604f819d.foduu.store/images/...)
    // which return 404, while the active app domain (https://vision.foduu.store/images/...) serves the image with 200 OK.
    final baseUri = Uri.tryParse(url);
    if (baseUri != null && baseUri.hasAuthority) {
      urlStr = urlStr.replaceAll(
        RegExp(r'^https?://[a-zA-Z0-9_\.-]+\.(vbought\.com|foduu\.store)/images/'),
        '${baseUri.origin}/images/',
      );
    }
    return urlStr;
  }

  String _processImageSource(
      dynamic featuredImage, bool? isLog, String? moduleName) {
    if (featuredImage == null) {
      return HelperFunctions.getNoImage();
    }

    // Case 1: featuredImage is a Map
    if (featuredImage is Map) {
      // Prioritize filepath: "2026/10/23/leaninig-f7fd5666.webp" gives 200 OK on active origin
      final path = featuredImage['filePath'] ??
          featuredImage['filepath'] ??
          featuredImage['filename'] ??
          featuredImage['path'];

      if (path != null && path.toString().trim().isNotEmpty) {
        String pathStr = path.toString().trim();
        return _processImageSource(pathStr, isLog, moduleName);
      }

      final directUrl = featuredImage['download_url'] ??
          featuredImage['downloadUrl'] ??
          featuredImage['url'];

      if (directUrl != null && directUrl.toString().trim().isNotEmpty) {
        String urlStr = directUrl.toString().trim();
        if (urlStr.startsWith('http')) {
          return _normalizeImageUrl(urlStr);
        } else {
          return _processImageSource(urlStr, isLog, moduleName);
        }
      }
    }

    if (featuredImage is String && featuredImage.trim().isNotEmpty) {
      String str = featuredImage.trim();
      if (str.startsWith('http')) {
        return _normalizeImageUrl(str);
      }
      // A bare MongoDB ObjectId (24 hex chars, no path separators) is not a
      // valid image path — guard against the cart/manage response inconsistency.
      final isRawId =
          RegExp(r'^[a-f0-9]{24}$', caseSensitive: false).hasMatch(str);
      if (isRawId) {
        return HelperFunctions.getNoImage();
      }

      if (str.startsWith('images/')) {
        return '$url$str';
      }
      if (str.startsWith('/images/')) {
        return '$url${str.substring(1)}';
      }
      if (str.startsWith('/')) {
        return '$url${str.substring(1)}';
      }

      return '${url}images/$str';
    }

    // Fallback
    return HelperFunctions.getNoImage();
  }

  /// Parses price values that may arrive as MongoDB Decimal128 maps
  /// (`{"$numberDecimal": "20.00"}`), numbers, strings, or wrapped maps.
  static double? parsePrice(dynamic val) {
    if (val == null) return null;
    if (val is Map) {
      if (val.containsKey('\$numberDecimal')) {
        return parsePrice(val['\$numberDecimal']);
      }
      if (val.containsKey('price')) {
        return parsePrice(val['price']);
      }
      return null;
    }
    if (val is num) return val.toDouble();
    if (val is String) {
      final trimmed = val.trim();
      if (trimmed.isEmpty) return null;
      return double.tryParse(trimmed);
    }
    return double.tryParse(val.toString());
  }
}

extension PriceExtension on num {
  String toFormattedPrice() {
    if (Get.isRegistered<CurrencyController>()) {
      return Get.find<CurrencyController>().formatPrice(this);
    }
    return toStringAsFixed(2);
  }

  double toConvertedPrice() {
    if (Get.isRegistered<CurrencyController>()) {
      return Get.find<CurrencyController>().convertPrice(this);
    }
    return this.toDouble();
  }
}

extension StringPriceExtension on String {
  String toFormattedPrice() {
    final val = double.tryParse(this) ?? 0.0;
    return val.toFormattedPrice();
  }

  double toConvertedPrice() {
    final val = double.tryParse(this) ?? 0.0;
    return val.toConvertedPrice();
  }
}
