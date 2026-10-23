import 'package:flutter/cupertino.dart';
import 'package:zouhi/app/controllers/api_exception_handle_controller.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';

class NotificationsController extends GetxController with BaseController {
  var isLoading = true.obs;
  var allnotificationList = List<dynamic>.empty().obs;
  var currentPage = 1.obs;
  var unreadNotification = 0.obs;
  var maxPage = 1.obs;
  late ScrollController scrollController;

  @override
  Future<void> onInit() async {
    super.onInit();
    scrollController = ScrollController();
    await fetchallnotificationlist();
    await fetchMoreDataOnScroll();
    updateNotificationCount();
  }

  void updateNotificationCount() async {
    // Get.find<HomepageController>().undreadNotificatoin.value = 0;
    var response = await BasicProvider("frontend/notifications/update-status")
        .getRequest()
        .catchError(handleError);

    if (response == null) return;
  }

  Future<void> fetchallnotificationlist() async {
    isLoading.value = true;
    var response = await BasicProvider(
            "frontend/notifications/show?count=10&page=${currentPage.value}")
        .getRequest()
        .catchError(handleError);
    print('response from notificatoins ${response}');
    isLoading.value = false;
    if (response == null) return;
    allnotificationList.addAll(response["data"]);
    maxPage(response["last_page"]);
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
