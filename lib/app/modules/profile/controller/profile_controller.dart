import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/app/data/basic_provider.dart';
import '/constants/constants.dart';

class ProfileMenuModel {
  final String title;
  final String iconPath;
  final VoidCallback onTap;
  const ProfileMenuModel({
    required this.title,
    required this.iconPath,
    required this.onTap,
  });
}

class ProfileController extends GetxController {

  // ── Correct endpoint ──────────────────────────────────────────
  static const String _profileEndpoint = 'auth/customer/profile';

  final RxBool   isLoading  = false.obs;
  final RxString userName   = ''.obs;
  final RxString userEmail  = ''.obs;
  final RxString userMobile = ''.obs;
  final RxString avatarUrl  = ''.obs;
  final RxString avatarPath = 'assets/images/profile_avatar.png'.obs;
  final RxDouble walletBal  = 0.0.obs;
  final RxList<Map<String, dynamic>> addresses =
      <Map<String, dynamic>>[].obs;

  late final List<ProfileMenuModel> accountSettings;
  late final List<ProfileMenuModel> otherSettings;

  @override
  void onInit() {
    super.onInit();
    _buildMenus();
    fetchProfile();
  }

  // ── Fetch Profile ─────────────────────────────────────────────
  // BasicProvider._processResponse returns body["data"] directly
  Future<void> fetchProfile() async {
    isLoading(true);
    try {
      final result =
      await BasicProvider(_profileEndpoint).getRequest();

      if (result != null && result is Map) {
        _parseProfile(Map<String, dynamic>.from(result));
      } else {
        debugPrint('⚠️ Profile response is null or unexpected type');
      }
    } catch (e) {
      debugPrint('Fetch profile error: $e');
    } finally {
      isLoading(false);
    }
  }

  // ── Parse Profile ─────────────────────────────────────────────
  void _parseProfile(Map<String, dynamic> data) {
    userName.value   = data['name']?.toString()   ?? '';
    userEmail.value  = data['email']?.toString()  ?? '';
    userMobile.value = data['mobile']?.toString() ?? data['phone']?.toString() ?? '';
    walletBal.value  = double.tryParse(
        data['wallet_balance']?.toString() ?? '0') ?? 0.0;

    // Addresses
    final rawAddr = data['addresses'];
    if (rawAddr is List) {
      addresses.assignAll(
        rawAddr.map<Map<String, dynamic>>(
              (a) => Map<String, dynamic>.from(a as Map),
        ).toList(),
      );
    }

    // Avatar
    final fi = data['featured_image'];
    if (fi is Map) {
      final du = fi['download_url']?.toString() ?? '';
      final fp = fi['filepath']?.toString()     ?? '';
      if (du.isNotEmpty) {
        avatarUrl.value  = du;
        avatarPath.value = '';
      } else if (fp.isNotEmpty) {
        avatarUrl.value  = '${assetURL}uploads/$fp';
        avatarPath.value = '';
      }
    } else if (data['avatar']?.toString().isNotEmpty == true) {
      avatarUrl.value  = data['avatar'].toString();
      avatarPath.value = '';
    } else {
      avatarUrl.value  = '';
    }

    debugPrint(
      '✅ Profile loaded: ${userName.value} | '
          '${userEmail.value} | avatar:${avatarUrl.value}',
    );
  }

  // ── Update Locally (instant UI after edit) ────────────────────
  void updateLocally({
    String? name,
    String? mobile,
    String? localImagePath,
    String? networkImageUrl,
  }) {
    if (name   != null && name.isNotEmpty)   userName.value   = name;
    if (mobile != null && mobile.isNotEmpty) userMobile.value = mobile;
    if (networkImageUrl != null && networkImageUrl.isNotEmpty) {
      avatarUrl.value  = networkImageUrl;
      avatarPath.value = '';
    } else if (localImagePath != null && localImagePath.isNotEmpty) {
      avatarPath.value = localImagePath;
      avatarUrl.value  = '';
    }
    debugPrint('✅ Profile locally updated: ${userName.value}');
  }

  // ── Default Address ───────────────────────────────────────────
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

  // ── Menus ─────────────────────────────────────────────────────
  void _buildMenus() {
    accountSettings = [
      ProfileMenuModel(
        title: 'Personal Information',
        iconPath: 'assets/icons/ic_personal_info.png',
        onTap: () => Get.toNamed('/personal-info'),
      ),
      ProfileMenuModel(
        title: 'Your Order',
        iconPath: 'assets/icons/ic_your_order.png',
        onTap: () => Get.toNamed('/orders'),
      ),
      ProfileMenuModel(
        title: 'Wishlist',
        iconPath: 'assets/icons/ic_wishlist.png',
        onTap: () => Get.toNamed('/wishlist'),
      ),
      ProfileMenuModel(
        title: 'Password & Security',
        iconPath: 'assets/icons/ic_password.png',
        onTap: () => Get.toNamed('/password'),
      ),
      ProfileMenuModel(
        title: 'Notifications Preferences',
        iconPath: 'assets/icons/ic_notification_pref.png',
        onTap: () => Get.toNamed('/notification'),
      ),
    ];

    otherSettings = [
      ProfileMenuModel(
        title: 'Terms & Conditions',
        iconPath: 'assets/icons/ic_terms.png',
        onTap: () => Get.toNamed('/terms-conditions'),
      ),
      ProfileMenuModel(
        title: 'Help Center',
        iconPath: 'assets/icons/ic_help.png',
        onTap: () => Get.toNamed('/help-support'),
      ),
      ProfileMenuModel(
        title: 'Sign out',
        iconPath: 'assets/icons/ic_logout.png',
        onTap: _onSignOut,
      ),
    ];
  }

  void onBackTap() => Get.back();
  void onCartTap() => Get.toNamed('/cart');

  Future<void> _onSignOut() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A))),
        content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: Color(0xFF6B6B6B))),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel',
                style: TextStyle(color: Color(0xFF6B6B6B))),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Out',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      // Clear stored token before navigating
      Get.offAllNamed('/login');
    }
  }
}
