// import 'dart:convert';

// import 'package:crypto/crypto.dart';
// import 'package:get/get.dart';
// import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

// import 'package:http/http.dart' as http;

// class PhonePayController extends GetxController {
//   String environment = 'SANDBOX';
//   String appId = '';
//   String merchantId = 'PGTESTPAYUAT';
//   bool enableLogging = true;

//   String checkSum = '';
//   String saltKey = '099eb0cd-02cf-4e2a-8aca-3e6c6aff0399';
//   String saltIndex = '1';
//   String callBackUrl = '';
//   String body = '';
//   String transactionId = DateTime.now().millisecondsSinceEpoch.toString();

//   String apiEntPoint = '/pg/v1/pay';

//   Rx<Object?> result = Rx<Object?>(null);
//   Object? get resultValue => result.value;

//   // Setter for updating the value of result
//   set resultValue(Object? value) => result.value = value;

//   @override
//   void onInit() {
//     super.onInit();
//     phonePayInit();
//     body = getCheckSum().toString();
//   }

//   String getCheckSum() {
//     final requestData = {
//       "merchantId": merchantId,
//       "merchantTransactionId": transactionId,
//       "merchantUserId": "MUID123",
//       "amount": 10000,
//       "callbackUrl": "https://webhook.site/callback-url",
//       "mobileNumber": "9999999999",
//       "paymentInstrument": {"type": "PAY_PAGE"}
//     };

//     String base64body = base64.encode(utf8.encode(json.encode(requestData)));
//     checkSum =
//         '${sha256.convert(utf8.encode(base64body + apiEntPoint + saltKey)).toString()}###$saltIndex';

//     return base64body;
//   }

//   void phonePayInit() {
//     PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
//         .then((val) {
//       result.value = 'PhonePe SDK Initialized - $val';
//     }).catchError((error) {
//       handleError(error);
//       return <dynamic>{};
//     });
//   }

//   void handleError(error) {
//     result.value = {'error': error};
//   }

//   void startPgTransaction() {
//     PhonePePaymentSdk.startTransaction(
//       body,
//       callBackUrl,
//       checkSum,
//       '',
//     ).then((response) async {
//       if (response != null) {
//         String status = response['status'].toString();
//         String error = response['error'].toString();
//         if (status == 'SUCCESS') {
//           result.value = "Flow Completed - Status: Success!";
//           await checkStatus();
//         } else {
//           result.value = "Flow Completed - Status: $status and Error: $error";
//         }
//       } else {
//         result.value = "Flow Incomplete";
//       }
//     }).catchError((error) {
//       handleError(error);
//       return <dynamic>{};
//     });
//   }

//   checkStatus() async {
//     try {
//       String url =
//           "https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/status/$merchantId/$transactionId"; //Test

//       String concatenatedString =
//           "/pg/v1/status/$merchantId/$transactionId$saltKey";

//       var bytes = utf8.encode(concatenatedString);
//       var digest = sha256.convert(bytes);
//       String hashedString = digest.toString();

//       //  combine with salt key
//       String xVerify = "$hashedString###$saltIndex";

//       Map<String, String> headers = {
//         "Content-Type": "application/json",
//         "X-MERCHANT-ID": merchantId,
//         "X-VERIFY": xVerify,
//       };

//       await http.get(Uri.parse(url), headers: headers).then((value) {
//         Map<String, dynamic> res = jsonDecode(value.body);

//         try {
//           if (res["code"] == "PAYMENT_SUCCESS" &&
//               res['data']['responseCode'] == "SUCCESS") {
//             // Fluttertoast.showToast(msg: res["message"]);
//             Get.showSnackbar(GetSnackBar(
//               message: res['message'],
//             ));
//           } else {
//             // Fluttertoast.showToast(msg: " Something went wrong");
//             Get.showSnackbar(const GetSnackBar(
//               message: 'something went wrong',
//             ));
//           }
//         } catch (e) {
//           // Fluttertoast.showToast(msg: " Something went wrong");
//           Get.showSnackbar(GetSnackBar(
//             message: 'something went wrong $e',
//           ));
//         }
//       });
//     } catch (e) {
//       // Fluttertoast.showToast(msg: " Error");
//       Get.showSnackbar(const GetSnackBar(
//         message: 'error',
//       ));
//     }
//   }
// }
