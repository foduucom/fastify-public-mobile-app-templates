import 'package:flutter/material.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/commonWidgets/appbarIcons.dart';
import 'package:zouhi/components/home_component/appslider.dart';
import 'package:zouhi/components/home_component/category_home.dart';
import 'package:zouhi/components/home_component/customDrawer.dart';
import 'package:zouhi/components/home_component/parent_sections.dart';
import 'package:zouhi/app/data/models/home_cms.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';

class HomePageView extends GetView<HomepageController> {
  HomePageView({super.key});
  // final homeController = Get.find<HomepageController>();
  final homeController = Get.put(HomepageController());

  @override
  Widget build(BuildContext context) {
    // print('home controller length ${controller.widgetList.length}');
    var scaffoldKey = GlobalKey<ScaffoldState>();
    // final categorycontroller = Get.put(CategoryController());

    // print('testing home ${controller.dashboardDesign.toString()}');

    // var box = GetStorage();
    // var list = box.read('homeComponent');
    // print('list ${list.toString()}');

    return Scaffold(
      key: scaffoldKey,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Image.asset(
          'assets/images/VIC-Logo-Final-1213.png',
          width: 140,
        ),
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: context.colors.surface,
        surfaceTintColor: context.colors.surface,
        iconTheme: IconThemeData(color: context.colors.onSurface),
        leading: IconButton(
            onPressed: () => scaffoldKey.currentState!.openDrawer(),
            icon: Icon(Icons.menu, color: context.colors.onSurface)),
        actions: [
          SearchIcon(() {
            Get.toNamed(Routes.SEARCH);
          }),
          // ShopIcon(() {
          //   Get.toNamed(Routes.SHOPPRODUCTLISTVIEW, arguments: {
          //     'productId': '',
          //     'name': 'Shop',
          //     'productType': '',
          //     'source': 'dashboard'
          //   });
          // }),
          const SizedBox(width: 14),
        ],
      ),

      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshAllData();
        },
        // Sections follow the parent site's CMS order (`pages/home`); each one
        // is built lazily so below-the-fold content costs nothing until seen.
        child: Obx(() {
          final sections = _sections(controller.cms.value ?? HomeCms.fallback());
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 10, bottom: 24),
            itemCount: sections.length,
            itemBuilder: (_, i) => sections[i](),
          );
        }),
      ),
      // child: Text('data'),
    );
  }

  List<Widget Function()> _sections(HomeCms cms) {
    final out = <Widget Function()>[];
    for (final c in cms.components) {
      switch (c.type) {
        case 'index_hero-banner':
          out.add(() => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: FoduuSlider(id: 'mobileslider'),
              ));
          break;
        case 'index_feature-strip':
          out.add(() => Padding(
              padding: const EdgeInsets.only(top: 12),
              child: FeatureStrip(component: c)));
          out.add(() => Obx(
                () => CategoryHome(
                  title: c.str('category_section_heading',
                      'Top Categories Of The Month'),
                  itemLimit: c.integer('items_per_page', 10) < 9
                      ? 10
                      : c.integer('items_per_page', 10),
                  isLoading: controller.isLoading.value,
                  productCategoryList: controller.productCategoryList.toList(),
                ),
              ));
          break;
        case 'spacer_bs':
          out.add(() => SpacerBlock(component: c));
          break;
        case 'index_category-banners':
          out.add(() => CategoryBanners(component: c));
          break;
        case 'index_seller-products':
          out.add(() => BestSellerSection(component: c));
          break;
        case 'index_promo-strip':
          out.add(() => PromoStrip(component: c));
          break;
        case 'index_picos-platform':
          out.add(() => PicosSection(component: c));
          break;
        case 'index_products-section':
          out.add(() => LatestProductsSection(component: c));
          break;
        case 'index_blog-posts':
          // Deprecated on parent website home screen
          break;
      }
    }
    return out;
  }
}
