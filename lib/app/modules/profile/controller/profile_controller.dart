import 'dart:io';
import 'package:flutter/material.dart';
import 'package:foddu/app/data/basic_provider.dart';
import 'package:foddu/app/modules/auth/auth_details.dart';
import 'package:foddu/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foddu/app/modules/profile/change_password/view/change_password_view.dart';
import 'package:foddu/app/modules/profile/profile_updates/personal_info.dart';
import 'package:foddu/app/routes/app_pages.dart';
import 'package:foddu/constants/constants.dart';
import 'package:foddu/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class ProfileMenuModel {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? iconPath;
  final VoidCallback onTap;
  final Widget? trailing;

  const ProfileMenuModel({
    required this.title,
    this.subtitle,
    this.icon,
    this.iconPath,
    required this.onTap,
    this.trailing,
  });
}

class ProfileController extends GetxController {
  static const String _profileEndpoint = 'auth/customer/profile';

  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userMobile = ''.obs;
  final RxString avatarUrl = ''.obs;
  final RxString avatarPath = 'assets/images/profile_avatar.png'.obs;
  final RxDouble walletBal = 0.0.obs;
  final RxList<Map<String, dynamic>> addresses = <Map<String, dynamic>>[].obs;

  // Live Stats for quick-action row
  final RxInt ordersCount = 0.obs;
  final RxInt wishlistCount = 0.obs;
  final RxInt couponsCount = 0.obs;
  final RxString orderStatusLabel = 'In transit'.obs;

  late final List<ProfileMenuModel> accountSettings;
  late final List<ProfileMenuModel> otherSettings;

  @override
  void onInit() {
    super.onInit();
    checkAuthAndLoad();
  }

  void checkAuthAndLoad() {
    isLoggedIn.value = AuthDetails.isUserLogin();
    _buildMenus();
    if (isLoggedIn.value) {
      fetchProfile();
      fetchStats();
    } else {
      _loadGuestCouponsPreview();
    }
  }

  Future<void> fetchProfile() async {
    if (!AuthDetails.isUserLogin()) {
      isLoggedIn.value = false;
      return;
    }
    isLoggedIn.value = true;
    isLoading.value = true;

    try {
      final result = await BasicProvider(_profileEndpoint).getRequest();
      if (result != null && result is Map) {
        _parseProfile(Map<String, dynamic>.from(result));
      }
    } catch (e) {
      debugPrint('Fetch profile error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchStats() async {
    if (!AuthDetails.isUserLogin()) return;

    // Fetch Orders Count
    try {
      final orderRes = await BasicProvider('order').getRequest();
      if (orderRes != null) {
        List? docs;
        if (orderRes is List) {
          docs = orderRes;
        } else if (orderRes is Map) {
          if (orderRes['docs'] is List) {
            docs = orderRes['docs'] as List;
          } else if (orderRes['data'] is List) {
            docs = orderRes['data'] as List;
          } else if (orderRes['data'] is Map &&
              orderRes['data']['docs'] is List) {
            docs = orderRes['data']['docs'] as List;
          }
        }
        if (docs != null) {
          ordersCount.value = docs.length;
          orderStatusLabel.value =
              docs.isNotEmpty ? '${docs.length} orders' : 'In transit';
        }
      }
    } catch (_) {}

    // Fetch Coupons Count
    try {
      final couponRes = await BasicProvider('coupons').getRequest();
      if (couponRes != null) {
        List? listData;
        if (couponRes is List) {
          listData = couponRes;
        } else if (couponRes is Map) {
          if (couponRes['data'] is List) {
            listData = couponRes['data'] as List;
          } else if (couponRes['coupons'] is List) {
            listData = couponRes['coupons'] as List;
          }
        }
        if (listData != null) {
          couponsCount.value = listData.length;
        }
      }
    } catch (_) {}

    // Wishlist count
    try {
      final wishRes = await BasicProvider('wishlist').getRequest();
      if (wishRes != null && wishRes is List) {
        wishlistCount.value = wishRes.length;
      }
    } catch (_) {}
  }

  Future<void> _loadGuestCouponsPreview() async {
    try {
      final couponRes = await BasicProvider('coupons').getRequest();
      if (couponRes != null) {
        List? listData;
        if (couponRes is List) {
          listData = couponRes;
        } else if (couponRes is Map) {
          if (couponRes['data'] is List) {
            listData = couponRes['data'] as List;
          } else if (couponRes['coupons'] is List) {
            listData = couponRes['coupons'] as List;
          }
        }
        if (listData != null) {
          couponsCount.value = listData.length;
        }
      }
    } catch (_) {}
  }

  void _parseProfile(Map<String, dynamic> data) {
    userName.value = data['name']?.toString() ?? '';
    userEmail.value = data['email']?.toString() ?? '';
    userMobile.value =
        data['mobile']?.toString() ?? data['phone']?.toString() ?? '';
    walletBal.value =
        double.tryParse(data['wallet_balance']?.toString() ?? '0') ?? 0.0;

    final rawAddr = data['addresses'];
    if (rawAddr is List) {
      addresses.assignAll(
        rawAddr.map<Map<String, dynamic>>(
          (a) => Map<String, dynamic>.from(a as Map),
        ).toList(),
      );
    }

    final fi = data['featured_image'];
    if (fi is Map) {
      final du = fi['download_url']?.toString() ?? '';
      final fp = fi['filepath']?.toString() ?? '';
      if (du.isNotEmpty) {
        avatarUrl.value = du;
        avatarPath.value = '';
      } else if (fp.isNotEmpty) {
        avatarUrl.value = '${assetURL}uploads/$fp';
        avatarPath.value = '';
      }
    } else if (data['avatar']?.toString().isNotEmpty == true) {
      avatarUrl.value = data['avatar'].toString();
      avatarPath.value = '';
    } else {
      avatarUrl.value = '';
    }
  }

  void updateLocally({
    String? name,
    String? mobile,
    String? localImagePath,
    String? networkImageUrl,
  }) {
    if (name != null && name.isNotEmpty) userName.value = name;
    if (mobile != null && mobile.isNotEmpty) userMobile.value = mobile;
    if (networkImageUrl != null && networkImageUrl.isNotEmpty) {
      avatarUrl.value = networkImageUrl;
      avatarPath.value = '';
    } else if (localImagePath != null && localImagePath.isNotEmpty) {
      avatarPath.value = localImagePath;
      avatarUrl.value = '';
    }
  }

  Map<String, dynamic>? get defaultAddress {
    if (addresses.isEmpty) return null;
    try {
      return addresses.firstWhere(
        (a) => a['is_default'] == true,
        orElse: () => addresses.first,
      );
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  void _buildMenus() {
    accountSettings = [
      ProfileMenuModel(
        title: 'My Orders',
        subtitle: 'Track, return, or reorder items',
        icon: Icons.local_shipping_outlined,
        onTap: () => Get.toNamed(Routes.ORDERS),
      ),
      ProfileMenuModel(
        title: 'Your Wishlist',
        subtitle: "Items you've saved for later",
        icon: Icons.favorite_border_rounded,
        onTap: () => Get.toNamed(Routes.WISHLIST),
      ),
      ProfileMenuModel(
        title: 'Coupons & Vouchers',
        subtitle: 'Exclusive discounts & promo codes',
        icon: Icons.local_offer_outlined,
        onTap: () => Get.toNamed(Routes.COUPONS),
      ),
      ProfileMenuModel(
        title: 'Saved Addresses',
        subtitle: 'Home, work & delivery addresses',
        icon: Icons.location_on_outlined,
        onTap: () => Get.toNamed(Routes.ADDRESS_LIST),
      ),
    ];

    otherSettings = [
      ProfileMenuModel(
        title: 'Support Tickets',
        subtitle: 'View and raise support requests',
        icon: Icons.confirmation_num_outlined,
        onTap: () => Get.toNamed(Routes.SUPPORT_TICKET),
      ),
      ProfileMenuModel(
        title: 'My Reviews',
        subtitle: "Reviews & ratings you've posted",
        icon: Icons.rate_review_outlined,
        onTap: () => Get.toNamed(Routes.MY_REVIEWS),
      ),
      ProfileMenuModel(
        title: 'Help Center & FAQs',
        subtitle: 'Customer care, questions & guides',
        icon: Icons.help_outline_rounded,
        onTap: () => Get.toNamed(Routes.HELPANDSUPPORT),
      ),
      ProfileMenuModel(
        title: 'About Daksh Store',
        subtitle: 'Our heritage, story & craft',
        icon: Icons.info_outline_rounded,
        onTap: () => Get.toNamed(Routes.ABOUTUS),
      ),
      ProfileMenuModel(
        title: 'Terms & Privacy',
        subtitle: 'Terms of service & privacy policy',
        icon: Icons.shield_outlined,
        onTap: () => Get.toNamed(Routes.TERMS_CONDITIONS),
      ),
    ];
  }

  void onEditProfileTap() {
    Get.to(() => const PersonalInfoView())?.then((_) {
      fetchProfile();
    });
  }

  void onChangePasswordTap() {
    Get.to(() => const ChangePasswordView());
  }

  void onLoginTap() {
    isOtpLogin ? Get.toNamed(Routes.MOBILELOGIN) : Get.toNamed(Routes.LOGIN);
  }

  void onRegisterTap() {
    Get.toNamed(Routes.REGISTER);
  }

  Future<void> onSignOut(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE53935).withOpacity(0.12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFE53935),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Sign Out?',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to sign out from your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: isDark ? Colors.white60 : const Color(0xFF6B6B6B),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.black12,
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color:
                              isDark ? Colors.white70 : const Color(0xFF111111),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      if (Get.isRegistered<BottombarController>()) {
        await Get.find<BottombarController>().logout();
      } else {
        await AuthDetails.logout();
      }
    }
  }
}
