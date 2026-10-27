import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/homepage/controllers/homepage_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/commonWidgets/appbarIcons.dart';
import 'package:zouhi/components/home_component/category_home.dart';
import 'package:zouhi/components/home_component/customDrawer.dart';
import 'package:zouhi/components/home_component/parent_sections.dart';
import 'package:zouhi/components/home_component/vision_hero_slider.dart';
import 'package:zouhi/constants/theme_ext.dart';

class HomePageView extends GetView<HomepageController> {
  const HomePageView({super.key});

  @override
  HomepageController get controller => Get.isRegistered<HomepageController>()
      ? Get.find<HomepageController>()
      : Get.put(HomepageController());

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: context.colors.surface,
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
          icon: Icon(Icons.menu, color: context.colors.onSurface),
        ),
        actions: [
          SearchIcon(() {
            Get.toNamed(Routes.SEARCH);
          }),
          const SizedBox(width: 14),
        ],
      ),
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.refreshAllData();
        },
        child: Obx(() {
          final heroData = controller.heroSlider.value;
          final badgesData = controller.trustBadges.value;
          final categoriesData = controller.topCategories.value;
          final offersData = controller.specialOffersSection.value;
          final bannersData = controller.banners.value;
          final bestSellersData = controller.bestSellersSection.value;
          final latestProductsData = controller.latestProductsSection.value;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 8, bottom: 32),
            children: [
              // 1. Hero Swiper Carousel Banner
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: VisionHeroSlider(data: heroData),
              ),

              // 2. Trust Badges / Value Strip
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: FeatureStrip(data: badgesData),
              ),

              // 3. Top Categories of The Month
              CategoryHome(
                title: categoriesData.heading,
                itemLimit: 10,
                isLoading: controller.isLoading.value,
                productCategoryList: controller.productCategoryList.toList(),
              ),

              // 4. Special Offers Section (Countdown Timer + Products Rail)
              SpecialOffersSection(data: offersData),

              // 5. Category Banner (Enterprise Networking / Security Cameras - Coming Soon)
              CategoryBanners(data: bannersData),

              // 6. Best Seller Products Section (with Top Seller banner positioned between heading and products)
              BestSellerSection(
                data: bestSellersData,
                bannerItem: bannersData.fiberOpticAccessories,
              ),

              // 7. Next-Gen Networking Promo Strip
              PromoStrip(data: bannersData.nextGenNetworking),

              // 8. Latest Products Section
              LatestProductsSection(data: latestProductsData),
            ],
          );
        }),
      ),
    );
  }
}
