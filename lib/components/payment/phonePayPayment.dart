// import 'dart:convert';
// import 'package:get/get.dart';
// import 'package:crypto/crypto.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';
// import 'package:zouhi/app/data/basic_provider.dart';
// import 'package:zouhi/app/modules/payment/views/ordersucess_view.dart';
// import 'package:zouhi/constants/helper_functions.dart'; // Import PhonePe SDK

// class PhonePePayment {
//   final bool enableLogging;
//   final String phonePeCallBackURL;
//   final String apiEndPoint;
//   final Rx<Object?> result = Rx<Object?>(null);

//   String transactionId = DateTime.now().millisecondsSinceEpoch.toString();
//   String checkSum = '';
//   String body = '';
//   String saltKey = '';
//   String merchantId = '';
//   String index = '';

//   PhonePePayment({
//     required this.enableLogging,
//     required this.phonePeCallBackURL,
//     this.apiEndPoint = '/pg/v1/pay',
//   });

//   Object? get resultValue => result.value;

//   Future<void> startPhonePay({
//     required String phonepeMerchantId,
//     required String phonePaySaltkey,
//     required String phonePayIndex,
//     required double totalAmount,
//   }) async {
//     merchantId = phonepeMerchantId;
//     saltKey = phonePaySaltkey;
//     index = phonePayIndex;

//     body = await getCheckSum(totalAmount);

//     await phonePayInit('beforeOrderId');
//   }

//   Future<String> getCheckSum(double totalAmount) async {
//     try {
//       var box = GetStorage();
//       var user = box.read('userDetails')['userData'];

//       final requestData = {
//         "merchantId": merchantId,
//         "merchantTransactionId": transactionId,
//         "merchantUserId": "MUID123",
//         "amount": totalAmount,
//         "callbackUrl": phonePeCallBackURL,
//         "mobileNumber": user['mobile'],
//         "paymentInstrument": {"type": "PAY_PAGE"}
//       };

//       String base64body = base64.encode(utf8.encode(json.encode(requestData)));
//       checkSum =
//           '${sha256.convert(utf8.encode(base64body + apiEndPoint + saltKey)).toString()}###$index';

//       return base64body;
//     } catch (e) {
//       print('Error in generating checksum: $e');
//       return '';
//     }
//   }

//   Future<void> phonePayInit(String beforeOrderId) async {
//     try {
//       PhonePePaymentSdk.init('environment', 'appId', merchantId, enableLogging)
//           .then((val) {
//         if (val) {
//           startPgTransaction(beforeOrderId);
//         }
//       }).catchError((error) {
//         HelperFunctions().showSnackBarError(error.toString());
//         print('Error initializing PhonePe SDK: $error');
//       });
//     } catch (e) {
//       print('PhonePe initialization error: $e');
//     }
//   }

//   void startPgTransaction(String beforeOrderId) {
//     try {
//       PhonePePaymentSdk.startTransaction(body, phonePeCallBackURL, checkSum, '')
//           .then((response) async {
//         if (response != null) {
//           String status = response['status'].toString();
//           if (status == 'SUCCESS') {
//             try {
//               var res = await BasicProvider("transaction/status/$beforeOrderId")
//                   .getRequest();
//               Get.offAll(() => OrdersucessView());
//               if (res == null) {
//                 HelperFunctions().showSnackBarError(
//                     "There is some issue with API, please contact administrator!");
//               }
//             } catch (e) {
//               print('Error in second API call: $e');
//             }
//           } else {
//             result.value = "Flow Incomplete";
//           }
//         }
//       }).catchError((error) {
//         HelperFunctions().showSnackBarError(error.toString());
//         print('Transaction error: $error');
//       });
//     } catch (e) {
//       print('Start PG transaction error: $e');
//     }
//   }
// }

class PhonePePayment {
  final String merchantId;
  PhonePePayment({required this.merchantId});

  Future<void> processPayment({
    required double amount,
    required Map<String, dynamic> metadata,
  }) async {
    throw UnimplementedError("PhonePe payment is not enabled/supported in this build.");
  }
}

