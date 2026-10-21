                  import 'package:flutter/material.dart';
                  import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
                  import 'package:foduu_ecommerce/app/data/basic_provider.dart';
                  import 'package:get/get.dart';

                  class OrdersController extends GetxController with BaseController {
                    var isLoading = false.obs;
                    var orderList = List<dynamic>.empty().obs;
                    var currentPage = 1.obs;
                    var maxPage = 1.obs;
                    late ScrollController scrollController;

                    @override
                    Future<void> onInit() async {
                      super.onInit();
                      scrollController = ScrollController();
                      // fetchMoreCategoriesOnScroll();
                      await Orders();
                    }

                    Future<void> Orders() async {
                      try {
                        isLoading.value = true;
                        var response =
                            await BasicProvider("order").getRequest().catchError(handleError);

                        if (response != null) {
                          if (response is List) {
                            orderList.addAll(response);
                          } else if (response is Map) {
                            if (response["docs"] is Iterable) {
                              orderList.addAll(response["docs"]);
                            } else if (response["data"] is Iterable) {
                              orderList.addAll(response["data"]);
                            } else if (response["data"] is Map &&
                                response["data"]["docs"] is Iterable) {
                              orderList.addAll(response["data"]["docs"]);
                            }
                            // if (response["last_page"] != null) {
                            //   maxPage.value = response["last_page"];
                            // }
                          }
                        }
                      } catch (e) {
                        debugPrint('Orders error: $e');
                      } finally {
                        isLoading.value = false;
                      }
                    }

                    // Future<void> fetchMoreCategoriesOnScroll() async {
                    //   scrollController.addListener(() async {
                    //     if (scrollController.position.pixels >=
                    //         scrollController.position.maxScrollExtent - 50.0) {
                    //       if (!isLoading.value && currentPage.value < maxPage.value) {
                    //         currentPage(currentPage.value + 1);
                    //         await Orders();
                    //       }
                    //     }
                    //   });
                    // }

                    void onRefresh() async {
                      currentPage.value = 1;
                      maxPage.value = 1;
                      orderList.clear();
                      await Orders();
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
