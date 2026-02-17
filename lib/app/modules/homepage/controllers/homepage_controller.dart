import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/controllers/api_exception_handle_controller.dart';
import 'package:foduu_ecommerce/app/data/basic_provider.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/home_component/home_products.dart';
import 'package:foduu_ecommerce/components/home_component/home_rich_text_component.dart';
import 'package:foduu_ecommerce/components/home_component/home_slider.dart';
import 'package:foduu_ecommerce/components/home_component/home_banner.dart';
import 'package:foduu_ecommerce/components/home_component/home_blogs.dart';
import 'package:foduu_ecommerce/components/home_component/home_category.dart';
import 'package:foduu_ecommerce/components/home_component/home_common_widgets.dart';
import 'package:foduu_ecommerce/components/home_component/home_price_filter.dart';
import 'package:foduu_ecommerce/components/search_bar_rounded.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/helpers/socket_helper.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomepageController extends GetxController with BaseController {
  var selectcategory = 0.obs;
  var isLoading = true.obs;
  var box = GetStorage();
  final isLogin = false.obs;
  var widgetList = [].obs;
  var blogList = [].obs;
  var notificatoinCount = 0.obs;
  var isDrawerNavigationLoading = false.obs;
  var drawernavigationItems = [].obs;
  final _socketHelper = SocketHelper();
  var dashboardDesign = {}.obs;

  // Created By
  RxInt currentIndex = 0.obs;
  // Created By
  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    getDrawerNavigation();
    await getDashboardDesign('home');
    if (kIsWeb) {
      _socketHelper.connect();
    }
  }

  void getWidgetbyCategory() {
    print('=== getWidgetbyCategory STARTED ===');
    print('Reading from box: homeComponent');
    final homeComponent = box.read('homeComponent') ?? [];
    print('homeComponent length: ${homeComponent.length}'); // Add this debug
    widgetList.clear();
    for (int i = 0; i < homeComponent.length; i++) {
      var item = homeComponent[i];
      print('Processing item ${i + 1}: type=${item['type']}');
      var contentJson = item['content_json'];
      print("Inner data of Sections ContentType: ${item['content_json']}");
      print("Inner data of Sections Type: ${item['type']}");
      switch (item['type']) {
        case 'search':
          widgetList.add(Padding(
            padding: pageSurroundingPadding,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent, // o
              onTap: () {
                Get.toNamed(Routes.SEARCH);
                // print('sarch ... ${contentJson['placeholder']}');
              },
              child: AbsorbPointer(
                child: SearchBarRounded(
                    onChanged: (p0) {
                      print('sarch ... ${contentJson}');
                    },
                    searchHintText: contentJson['placeholder'] ?? 'Search...',
                    SearchsController: SearchController()),
              ),
            ),
          ));
          break;
        case 'slider':
          var sliderData = {};
          if (contentJson != null) {
            sliderData = contentJson;
          }
          widgetList.add(FoduuSlider(sliderData: sliderData));
          break;
        case 'categories':
          var categoryData = contentJson ?? {};
          widgetList.add(CategoryHome(
            categoryData: categoryData,
          ));
          break;
        case 'blog':
          widgetList.add(BlogSection(
            blogData: contentJson,
          ));
          break;

        case 'banner':
          if (contentJson != null) {
            widgetList.add(HomeBanner(bannerContent: contentJson));
            print('HomeBanner added to widgetList');
          }
          break;
        case 'price_filter':
          widgetList.add(PriceFilter(contentJson: contentJson));
          break;
        case 'spacer':
          widgetList.add(SpacerComponent(contentJson: contentJson));
          break;

        case 'divider':
          widgetList.add(DividerComponent(contentJson: contentJson));
          break;

        case 'text_block':
          widgetList.add(TextBlockComponent(contentJson: contentJson));
          break;

        case 'products':
          widgetList.add(TrendingProductSection(
            contentJson: contentJson,
          ));
          break;
        case 'rich_text':
          widgetList.add(RichTextComponent(contentJson: contentJson));
          break;
      }
    }
    print('=== getWidgetbyCategory COMPLETED ===');
    print('widgetList length: ${widgetList.length}');
    print(
        'widgetList types: ${widgetList.map((w) => w.runtimeType.toString()).toList()}');

    update(); // Make sure to call update() to refresh the UI
  }

  Future<dynamic> getDashboardDesign(String name) async {
    try {
      // var response = {
      //   "content_json": [
      //     {
      //       "type": "banner",
      //       "content_json": {
      //         "banners": [
      //           {
      //             "id": "test_carousel",
      //             "type": "horizontal_scroll",
      //             "layout": "card_peek",
      //             "items": [
      //               {
      //                 "featured_image":
      //                     "https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=1200&h=600&fit=crop",
      //                 "link_type": "product",
      //                 "link": {"value": "prod_001", "label": "Test Product"}
      //               },
      //               {
      //                 "featured_image":
      //                     "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=1200&h=600&fit=crop",
      //                 "link_type": "category",
      //                 "link": {"value": "cat_002", "label": "Test Category"}
      //               }
      //             ],
      //             "config": {
      //               // "auto_play": true,
      //               // "auto_play_interval": 3000,
      //               // "show_indicators": true,
      //               // "height": 200,
      //               // "border_radius": 02
      //               "card_width": 0.85,
      //               "card_height": 180,
      //               "peek_amount": 40,
      //               "spacing": 12,
      //               "border_radius": 16
      //             }
      //           }
      //         ]
      //       }
      //     }
      //   ]
      // };

      isLoading(true);

      var response = await BasicProvider("mobile-app/69708c1b6968f244e799ea6a")
          .getRequest();

      print('✅ API Response received');
      print(
          'Response keys: ${response?.keys}'); // This will show all keys in the response

      if (response != null) {
        var list = response['sections'];
        if (list != null && list is List) {
          box.write('homeComponent', list);
          getWidgetbyCategory();
        }
      }
      if (kIsWeb) {
        _setupSocketListener("69708c1b6968f244e799ea6a");
      }
      return response;
    } catch (e) {
      print('home page controller error $e');
    } finally {
      isLoading(false); // Stop loading regardless of success/failure
    }
  }

  void _setupSocketListener(String slug) {
    final eventName = 'dashboard-update-$slug';

    _socketHelper.off(eventName);

    _socketHelper.on(eventName, (data) {
      print('Received socket update for $eventName: $data');

      if (data != null) {
        dashboardDesign.value = data;

        // ✅ FIX: Also use 'sections' here
        var sections = data[
            'sections']; // Changed from 'sections' to 'sections' (it was already correct)
        if (sections != null && sections is List) {
          box.write('homeComponent', sections);
          getWidgetbyCategory();
        }
      }
    });
  }

  Future<dynamic> getDrawerNavigation() async {
    try {
      isDrawerNavigationLoading(true);

      var response = await BasicProvider("navigation/sidebar")
          .getRequest()
          .catchError(handleError);

      var list = response['value'];
      drawernavigationItems.assignAll(list);

      return response;
    } catch (e) {
      print('home page controller error $e');
    } finally {
      isDrawerNavigationLoading.value = false;
    }
  }

  @override
  void onClose() {
    if (kIsWeb) {
      _socketHelper.off('dashboard-update-69708c1b6968f244e799ea6a');
    }
    super.onClose();
  }
}
