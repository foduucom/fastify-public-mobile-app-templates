import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/modules/address/controllers/address_controller.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/cart/controllers/cart_controller.dart';
import 'package:foduu_ecommerce/app/modules/payment/views/ordersucess_view.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
// import 'package:phonepe_payment_sdk/phonepe_payment_sdk.dart';

class PaymentController extends GetxController with BaseController {
  var deliveryOption = {}.obs;
  RxInt selectedIndex = 0.obs;
  var addressController = Get.find<AddressController>();
  var paymentOptions = [].obs;
  var box = GetStorage();
  var guestUseAddress = {};

  var deliveredAddess = {}.obs;
  var price = '0'.obs;
  var savedPrice = ''.obs;
  var couponAmount = ''.obs;
  var totalAmount = ''.obs;
  var couponPrefix = ''.obs;
  var couponCode = ''.obs;
  var isShippingLoading = true.obs;
  var shipping_details = {}.obs;
  var addressId;
  CartController cartController = Get.find<CartController>();

  @override
  void onInit() async {
    super.onInit();
    if (AuthDetails.isUserLogin()) {
      getAddressId();
      await getAddressbyId(id: addressId);
    } else {
      guestUseAddress = Get.arguments['guestUserAddress'];
    }
    print(
        'payment optition ${paymentOptions}  and is shinpping value ${isShippingLoading.value}');
    await getPaymentOpetion();
    getOrderDetails();
    if (AuthDetails.isUserLogin()) {
      paymentOptions.add(
        {"name": "Cash On Delivery"},
      );
    }

    await getShippingDetails();
  }

  void getAddressId() {
    addressId = addressController
        .userAddressList[addressController.selectAddress.value]['_id'];
  }

  Future<void> getShippingDetails() async {
    try {
      isShippingLoading.value = true;
      var selectedMethod = paymentOptions[selectedIndex.value];
      var paymentName = selectedMethod['name'];

      var form = FormData({
        // "pickup_postcode": Get.find<AddressController>().pickup_postcode, //change
        "pickup_postcode": "452014",
        "delivery_postcode": !AuthDetails.isUserLogin()
            ? guestUseAddress['pincode']
            : deliveredAddess['pincode'],
        "weight": AuthDetails.isUserLogin()
            ? cartController.otherCartDetails['weight']
            : cartController.guestUserCartWeight,
        "cod": paymentName == 'Cash On Delivery' ? 1 : 0
      });

      var response = await BasicProvider("orders/serviceability")
          .postRequest(form)
          .catchError(handleError);

      shipping_details.value = {};
      if (response == null) return;
      if (response['is_shipping'] == false) {
        shipping_details['shipping_charge'] = 'Shipping not Availabe';
      } else {
        shipping_details.value = response;
      }
      isShippingLoading.value = false;

      getOrderDetails();
    } catch (e) {
      isShippingLoading.value = false;
      print(e);
    }
    // shipping_details.addAll(response);
    // print(shipping_details);
    // print(form);
  }

  Future<void> getAddressbyId({required String id}) async {
    try {
      var response = await BasicProvider("address/show/$id")
          .getRequest()
          .catchError(handleError);
      if (response == null) return;
      deliveredAddess.addAll(response);
    } catch (e) {
      print('get addreess by id error $e');
    }
  }

  void getOrderDetails() {
    if (AuthDetails.isUserLogin()) {
      couponPrefix.value = cartController.couponDetails
              .containsKey('coupon_type')
          ? cartController.couponDetails['coupon_type'] == 'fixAmount'
              ? '(\u{20B9}${cartController.couponDetails['discount_value']})'
              : '(${cartController.couponDetails['discount_value'].toString()}%)'
          : '';
      price.value = AuthDetails.isUserLogin()
          ? cartController.otherCartDetails['total'].toString()
          : cartController.bagpriceAmount.value.toString();
      totalAmount.value = AuthDetails.isUserLogin()
          ? ((((cartController.otherCartDetails['total'] ?? 0) -
                          ((cartController.otherCartDetails['total'] ?? 0) -
                              (cartController.otherCartDetails['subtotal'] ??
                                  0))) -
                      (cartController.couponDetails
                              .containsKey('discount_amount')
                          ? (cartController.couponDetails['discount_amount'] ??
                              0.00)
                          : 0.00)) +
                  (shipping_details['shipping_charge'] ?? 0.00))
              .toStringAsFixed(2)
              .toString()
          : cartController.totalAmount.toString();
      // totalAmount.value = 'testing';
      couponCode.value = cartController.couponDetails['message'] == 'Applyed'
          ? cartController.couponController.text.toString()
          : 'Apply Coupon';
      couponAmount.value = cartController.couponDetails['message'] == 'Applyed'
          ? cartController.couponDetails['discount_amount'].toString()
          : '0.00';
      savedPrice.value = AuthDetails.isUserLogin()
          ? (cartController.otherCartDetails['total'] -
                  cartController.otherCartDetails['subtotal'])
              .toString()
          : cartController.discountAmount.value.toString();
    } else {
      couponPrefix.value = '';
      price.value = cartController.bagpriceAmount.value.toString();
      totalAmount.value = (cartController.totalAmount.value +
              (shipping_details['shipping_charge'] ?? 0.00))
          .toStringAsFixed(2);
      couponCode.value = '';
      couponAmount.value = 'Apply Coupon';
      savedPrice.value = cartController.discountAmount.value.toString();
    }
  }

  getPaymentOpetion() async {
    var response = await BasicProvider("frontend/payment-gateway")
        .getRequest()
        .catchError(handleError);
    if (response == null) return;
    paymentOptions.addAll(response);
  }

  List paymentMethod = [
    {"image": "assets/icon/cashone.svg", "method": "Cash On Delivery"},
    {"image": "assets/icon/card.svg", "method": "Debit/Credit Card"},
    {"image": "assets/icon/wallet.svg", "method": "Stripe"},
    {"image": "assets/icon/banking.svg", "method": "Net Banking"},
  ];

  Future<String> createOrder() async {
    if (AuthDetails.isUserLogin()) {
      var form = FormData({
        "address": addressController
            .userAddressList[addressController.selectAddress.value]['_id'],
        "total": totalAmount,
        "subtotal": cartController.otherCartDetails['subtotal'].toString(),
        "discount": couponAmount.value,
        "shipping": shipping_details['shipping_charge'] == null
            ? '0.00'
            : shipping_details['shipping_charge'].toString(),
        'device': 'mobile',
        "payment_method": paymentOptions[selectedIndex.value]['name'],
        "coupon_code":
            couponCode.value == 'Apply Coupon' ? null : couponCode.value
      });
      var response = await BasicProvider("orders/create")
          .postRequest(form)
          .catchError(handleError);
      if (response == null) return "";

      return response['order_no'];
    } else {
      var form = {
        "address": guestUseAddress,
        "products": cartController.guestUserCartList,
        "payment_method": paymentOptions[selectedIndex.value]['name'],
        "shipping": shipping_details['shipping_charge'] == null
            ? '0.00'
            : shipping_details['shipping_charge'].toString(),
        "total": cartController.viewTotalAmount.value,
        "subtotal": cartController.viewsavedPrice.value
      };
      var response = await BasicProvider("create/order")
          .postRequest(form)
          .catchError(handleError);
      if (response == null) return "";
    }
    return '';
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Cash on Delivery ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\

  Future<dynamic> createOrderCOd() async {
    try {
      var form = FormData({
        "total": totalAmount,
        "subtotal": cartController.otherCartDetails['subtotal'].toString(),
        "address": addressId,
        "discount": couponAmount.value,
        'device': 'mobile',
        "shipping": shipping_details['shipping_charge'] == null
            ? '0.00'
            : shipping_details['shipping_charge'].toString(),
        "payment_method": 'cod',
        "coupon_code":
            couponCode.value == 'Apply Coupon' ? '' : couponCode.value
      });

      var response = await BasicProvider("orders/create")
          .postRequest(form)
          .catchError(handleError);

      if (response == null) return;
      return response['_id'];
    } catch (e) {
      print('cash on delivery error $e');
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~ phone pay payment gateway start ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\
  bool enableLogging = true;

  String checkSum = '';
  String body = '';
  String transactionId = DateTime.now().millisecondsSinceEpoch.toString();

  String apiEntPoint = '/pg/v1/pay';

  Rx<Object?> result = Rx<Object?>(null);
  Object? get resultValue => result.value;
  String saltkey = '';
  String merchantId = '';
  String index = '';
  String phonePeCallBackURL =
      "http://mern.foduu.com:3016/api/public/orders/pay_response";

  // set resultValue(Object? value) => result.value = value;

  void startPhonePay(
      {required String phonepeMerchantId,
      required String phonePaySaltkey,
      required String phonePayIndex}) async {
    merchantId = phonepeMerchantId;
    saltkey = phonePaySaltkey;
    index = phonePayIndex;
    print('~~~~~~~~~~~~~~~~~~~~~~~ $merchantId , $saltkey, $index');
    // var beforeOrderId = await createOrder();
    body = await getCheckSum();
    // print(body);
    print('ssssssssssssssssssssssssssssssssssssssss');
    await phonePayInit('beforeOrderId');
  }

  Future<String> getCheckSum() async {
    try {
      var box = GetStorage();
      var user = box.read('userDetails')['userData'];

      final requestData = {
        "merchantId": merchantId,
        "merchantTransactionId": transactionId,
        "merchantUserId": "MUID123",
        "amount": totalAmount.value,
        // "callbackUrl": "https://webhook.site/callback-url",
        "callbackUrl": phonePeCallBackURL,
        "mobileNumber": user['mobile'],
        "paymentInstrument": {"type": "PAY_PAGE"}
      };

      String base64body = base64.encode(utf8.encode(json.encode(requestData)));
      // checkSum =
      //     '${sha256.convert(utf8.encode(base64body + apiEntPoint + saltKey)).toString()}###$index';

      return base64body;
    } catch (e) {
      print('error $e');
      return '';
    }
  }

  Future<void> phonePayInit(String beforeOrderId) async {
    try {
      // PhonePePaymentSdk.init(environment, appId, merchantId, enableLogging)
      //     .then((val) {
      //   // result.value = 'PhonePe SDK Initialized - $val';
      //   if (val) {
      //     print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
      //     startPgTransaction(beforeOrderId);
      //   }
      // }).catchError((error) {
      //   HelperFunctions().showSnackBarError(error.toString());
      //   // return;
      //   print('error $error');
      // });
    } catch (e) {
      print('phone pay init error');
    }
  }

  void startPgTransaction(String beforeOrderId) {
    // try {
    //   PhonePePaymentSdk.startTransaction(body, callBackUrl, checkSum, '')
    //       .then((response) async {
    //     if (response != null) {
    //       String status = response['status'].toString();
    //       String error = response['error'].toString();
    //       if (status == 'SUCCESS') {
    //         try {
    //           var res =
    //               await BasicProvider("transaction/status/${beforeOrderId}")
    //                   .getRequest();
    //           Get.offAll(() => OrdersucessView());
    //           if (res == null) {
    //             HelperFunctions().showSnackBarError(
    //                 "There is some issue with API, please contact administrator!");
    //             return;
    //           }
    //         } catch (e) {
    //           print('second api error $e');
    //         }
    //         // var res = {};

    //         // if (res["payment_status"] == "paid") {
    //         //   await checkStatus();
    //         // } else {
    //         //   result.value = "Flow Completed - Status: $status and Error: $error";
    //         // }
    //       } else {
    //         result.value = "Flow Incomplete";
    //       }
    //     }
    //   }).catchError((error) {
    //     handleError(error);
    //     return <dynamic>{};
    //   });
    // } catch (e) {
    //   print('start pg transcation error $e');
    // }
  }
}
