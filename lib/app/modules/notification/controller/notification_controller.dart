import 'package:flutter/cupertino.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/constants/firebase_notification.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController with BaseController {
  var isLoading = true.obs;
  var allnotificationList = List<dynamic>.empty().obs;
  var currentPage = 1.obs;
  var maxPage = 1.obs;
  late ScrollController scrollController;

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();
    
    // Initial fetch
    await fetchallnotificationlist();
    await fetchMoreDataOnScroll();

    // Listen for new local notifications
    ever(FirebaseHelpers.localNotifications, (_) {
      _mergeNotifications();
    });
  }

  void _mergeNotifications() {
    // Combine local and API notifications
    // Filter out duplicates if they have the same ID or title/body/date
    var combined = <dynamic>[...FirebaseHelpers.localNotifications];
    
    // Add API notifications that aren't already there
    for (var apiNotif in allnotificationListFromApi) {
      bool exists = combined.any((local) => 
        (local['title'] == apiNotif['title'] && local['body'] == apiNotif['body']) ||
        (apiNotif['id'] != null && local['id'] == apiNotif['id'])
      );
      if (!exists) {
        combined.add(apiNotif);
      }
    }
    
    allnotificationList.assignAll(combined);
  }

  var allnotificationListFromApi = <dynamic>[].obs;

  Future<void> fetchallnotificationlist() async {
    isLoading.value = true;
    var response = await BasicProvider(
            "frontend/notifications?count=10&page=${currentPage.value}")
        .getRequest()
        .catchError(handleError);
    if (response == null) return;
    allnotificationListFromApi.addAll(response["data"]);
    maxPage(response["last_page"]);
    _mergeNotifications();
    isLoading.value = false;
  }

  Future<void> fetchMoreDataOnScroll() async {
    scrollController.addListener(() async {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 50.0) {
        if (!isLoading.value && currentPage.value < maxPage.value) {
          currentPage(currentPage.value + 1);
          await fetchallnotificationlist();
        }
      }
    });
  }

  Future<void> onPullToRefresh() async {
    currentPage.value = 1;
    maxPage.value = 1;
    allnotificationListFromApi.clear();
    allnotificationList.clear();
    await fetchallnotificationlist();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
