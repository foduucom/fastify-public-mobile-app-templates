import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/Profie/services/invoice_service.dart'; // Import the new service
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get.dart';

class OrderdetailController extends GetxController with BaseController {
  var item = {}.obs;
  final id = '0'.obs;
  var isLoading = false.obs;
  var downloading = false.obs;
  final InvoiceService _invoiceService =
      InvoiceService(); // Instantiate InvoiceService

  // Order tracking
  var isordertrackingloading = false.obs;
  Map<String, dynamic>? trackingData;

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
      id.value = Get.arguments['id'];
    }

    await OrderDetail();
  }

  Future<void> OrderDetail() async {
    try {
      isLoading.value = true;
      var response =
          await BasicProvider("order/$id").getRequest().catchError(handleError);

      print("OrderDetail Response: $response");
      if (response == null) return;

      if (response['address'] is Map) {
        await resolveOrderAddress(response['address']);
      }

      if (response['products'] is List) {
        for (var product in response['products']) {
          if (product is Map) {
            if (product['price'] == null) {
              var productObj = product['product_id'] ?? product['product'];
              if (productObj is Map && productObj['price'] != null) {
                product['price'] = productObj['price'];
              }
            }
          }
        }
      }

      item.value = response;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resolveOrderAddress(Map<dynamic, dynamic> address) async {
    try {
      var countryResponse =
          await BasicProvider("countries?search=indi").getRequest();
      List<dynamic> countryDataList = [];
      if (countryResponse != null && countryResponse['data'] is List) {
        countryDataList = countryResponse['data'];
      }

      var countryVal = address['country'];
      String countryId = '';
      String countryName = '';
      if (countryVal is Map) {
        countryId = countryVal['_id']?.toString() ?? '';
        countryName = countryVal['name']?.toString() ?? '';
      } else if (countryVal is String) {
        countryId = countryVal;
        var matchedCountry = countryDataList.firstWhere(
          (element) => element['_id'] == countryId,
          orElse: () => null,
        );
        if (matchedCountry != null) {
          countryName = matchedCountry['name']?.toString() ?? '';
        }
      }

      if (countryId.isEmpty && countryDataList.isNotEmpty) {
        countryId = countryDataList[0]['_id']?.toString() ?? '';
        countryName = countryDataList[0]['name']?.toString() ?? '';
      }

      if (countryId.isNotEmpty && countryName.isNotEmpty) {
        address['country'] = {
          '_id': countryId,
          'name': countryName,
        };
      }

      var stateVal = address['state'];
      String stateId = '';
      String stateName = '';
      if (stateVal is Map) {
        stateId = stateVal['_id']?.toString() ?? '';
        stateName = stateVal['name']?.toString() ?? '';
      } else if (stateVal is String && countryId.isNotEmpty) {
        stateId = stateVal;
        var statesResponse =
            await BasicProvider("states/$countryId").getRequest();
        List<dynamic> states = [];
        if (statesResponse != null) {
          var list =
              statesResponse is Map ? statesResponse['data'] : statesResponse;
          if (list is List) {
            states = list;
          }
        }
        var matchedState = states.firstWhere(
          (element) => element['_id'] == stateId,
          orElse: () => null,
        );
        if (matchedState != null) {
          stateName = matchedState['name']?.toString() ?? '';
        }
      }

      if (stateId.isNotEmpty && stateName.isNotEmpty) {
        address['state'] = {
          '_id': stateId,
          'name': stateName,
        };
      }

      // Cities API call commented out
      /*
      var cityVal = address['city'];
      String cityId = '';
      String cityName = '';
      if (cityVal is Map) {
        cityId = cityVal['_id']?.toString() ?? '';
        cityName = cityVal['name']?.toString() ?? '';
      } else if (cityVal is String && stateId.isNotEmpty) {
        cityId = cityVal;
        var citiesResponse =
            await BasicProvider("cities/$stateId").getRequest();
        List<dynamic> cities = [];
        if (citiesResponse != null) {
          var list =
              citiesResponse is Map ? citiesResponse['data'] : citiesResponse;
          if (list is List) {
            cities = list;
          }
        }
        var matchedCity = cities.firstWhere(
          (element) => element['_id'] == cityId,
          orElse: () => null,
        );
        if (matchedCity != null) {
          cityName = matchedCity['name']?.toString() ?? '';
        }
      }

      if (cityId.isNotEmpty && cityName.isNotEmpty) {
        address['city'] = {
          '_id': cityId,
          'name': cityName,
        };
      }
      */
    } catch (e) {
      print('Error resolving order address: $e');
    }
  }

  /// Returns the current stage index (1-based) based on order status.
  int getCurrentStage() {
    final status = item['status']?.toString().toLowerCase() ?? '';
    if (status.contains('delivered')) return 5;
    if (status.contains('out for delivery') ||
        status.contains('out_for_delivery')) return 4;
    if (status.contains('shipped')) return 3;
    if (status.contains('processing')) return 2;
    return 1; // Order Placed
  }

  /// Handles the invoice download process according to industry standards.
  Future<void> downloadPdf(dynamic orderId) async {
    if (downloading.value) return; // Prevent multiple download attempts

    downloading.value = true;
    try {
      final String actualOrderId =
          orderId?.toString() ?? id.value;
      final filePath = await _invoiceService.downloadInvoice(actualOrderId);
      if (filePath != null) {
        _invoiceService.showDownloadSuccessSnackBar(
          filePath: filePath,
          orderId: actualOrderId,
        );
      }
    } catch (e) {
      HelperFunctions().showSnackBarError("Failed to download invoice: $e");
      print('Error in downloadPdf: $e');
    } finally {
      downloading.value = false;
    }
  }
}
