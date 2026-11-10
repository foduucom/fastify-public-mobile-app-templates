import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foddu/app/data/basic_provider.dart';
import 'package:foddu/app/modules/auth/auth_details.dart';
import 'package:foddu/app/modules/coupons/models/coupon_model.dart';
import 'package:foddu/app/modules/coupons/views/widgets/coupon_details_dialog.dart';
import 'package:foddu/constants/helper_functions.dart';
import 'package:get/get.dart';

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
    final bool loggedIn = AuthDetails.isUserLogin();
    isGuestUser.value = !loggedIn;

    if (!loggedIn) {
      couponsList.clear();
      errorMessage.value = '';
      isLoading.value = false;
      return;
    }

    if (!isRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await BasicProvider('coupons').getRequest();

      List? listData;
      if (response != null) {
        if (response is List) {
          listData = response;
        } else if (response is Map) {
          if (response['data'] is List) {
            listData = response['data'] as List;
          } else if (response['coupons'] is List) {
            listData = response['coupons'] as List;
          } else if (response['result'] is List) {
            listData = response['result'] as List;
          }
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
      if (!loggedIn) {
        isGuestUser.value = true;
      } else {
        errorMessage.value = "Failed to load coupons. Please try again.";
      }
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
      final isDark = Theme.of(context).brightness == Brightness.dark;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Coupon "$code" copied to clipboard!',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? Colors.white : Colors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor:
              isDark ? const Color(0xFF1E1E1E) : const Color(0xFF111111),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: const Color(0xFFD4AF37).withOpacity(0.4),
              width: 1,
            ),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      HelperFunctions()
          .showSnackBarSuccess('Coupon "$code" copied to clipboard!');
    }
  }

  void openCouponDetails(BuildContext context, CouponModel coupon) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CouponDetailsDialog
      
      
      (coupon: coupon),
    );
  }
}
