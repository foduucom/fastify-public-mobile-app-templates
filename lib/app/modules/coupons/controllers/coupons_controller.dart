import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/data/basic_provider.dart';
import 'package:zouhi/app/modules/coupons/models/coupon_model.dart';
import 'package:zouhi/app/modules/coupons/views/widgets/coupon_details_dialog.dart';
import 'package:zouhi/constants/helper_functions.dart';

import 'package:zouhi/app/modules/auth/auth_details.dart';

class CouponsController extends GetxController {
  final isLoading = false.obs;
  final couponsList = <CouponModel>[].obs;
  final errorMessage = ''.obs;
  final isGuestUser = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCoupons();
  }

  Future<void> fetchCoupons({bool isRefresh = false}) async {
    if (!AuthDetails.isUserLogin()) {
      isGuestUser.value = true;
      couponsList.clear();
      isLoading.value = false;
      return;
    }

    isGuestUser.value = false;
    if (!isRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await BasicProvider('coupons', showSnackBar: false)
          .getRequest();

      List? listData;
      if (response != null) {
        if (response is List) {
          listData = response;
        } else if (response is Map && response['data'] is List) {
          listData = response['data'] as List;
        }
      }

      if (listData != null) {
        final parsed = listData
            .map((item) {
              if (item is Map) {
                return CouponModel.fromJson(Map<String, dynamic>.from(item));
              }
              return null;
            })
            .whereType<CouponModel>()
            .toList();

        couponsList.assignAll(parsed);
      } else {
        if (couponsList.isEmpty) {
          couponsList.clear();
        }
      }
    } catch (e) {
      debugPrint("Error fetching coupons: $e");
      errorMessage.value = "Failed to load coupons. Please try again.";
    } finally {
      isLoading.value = false;
    }
  }

  void copyCouponCode(String code, {BuildContext? context}) {
    if (code.isEmpty) return;
    Clipboard.setData(ClipboardData(text: code));
    HapticFeedback.lightImpact();

    if (context != null && context.mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Coupon "$code" copied to clipboard!',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF18426D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      HelperFunctions().showSnackBarSuccess('Coupon "$code" copied to clipboard!');
    }
  }

  void openCouponDetails(BuildContext context, CouponModel coupon) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CouponDetailsDialog(coupon: coupon),
    );
  }
}
