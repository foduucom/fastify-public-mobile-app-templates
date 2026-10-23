import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/modules/coupons/controllers/coupons_controller.dart';
import 'package:zouhi/app/modules/coupons/views/widgets/coupon_card.dart';
import 'package:zouhi/app/modules/coupons/views/widgets/coupon_shimmer.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/constants/theme_ext.dart';

class CouponsView extends GetView<CouponsController> {
  const CouponsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: AppBar(
        title: Text(
          'Available Coupons',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: context.themetitleColor,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: context.themeWhiteColor,
        iconTheme: IconThemeData(color: context.themeTextColor),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: context.themeBorderColor.withOpacity(0.6),
            height: 1,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.couponsList.isEmpty) {
          return const CouponShimmer();
        }

        if (controller.isGuestUser.value) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: context.themePrimaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 38,
                      color: context.themePrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Sign In to View Coupons',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: context.themetitleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Login to your account to view available coupon codes, discounts, and personalized offers.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      color: context.themeSecondrytext,
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    onPressed: () async {
                      await Get.toNamed(Routes.LOGIN);
                      controller.fetchCoupons();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.themePrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Sign In / Register',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.couponsList.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.red.shade400,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: context.themeSecondrytext,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () => controller.fetchCoupons(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.themePrimaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.couponsList.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.fetchCoupons(isRefresh: true),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: context.themePrimaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.confirmation_number_outlined,
                        size: 40,
                        color: context.themePrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'No Coupons Available',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: context.themetitleColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Check back later for exciting offers and deals!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: context.themeSecondrytext,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchCoupons(isRefresh: true),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            itemCount: controller.couponsList.length,
            itemBuilder: (context, index) {
              final coupon = controller.couponsList[index];
              return CouponCard(
                coupon: coupon,
                onInfoTap: () =>
                    controller.openCouponDetails(context, coupon),
                onCopyTap: () =>
                    controller.copyCouponCode(coupon.code, context: context),
              );
            },
          ),
        );
      }),
    );
  }
}
