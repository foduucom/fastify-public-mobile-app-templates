import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:zouhi/app/modules/Profie/profile/views/editprofile_view.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/buttons/appbutton.dart';
import 'package:zouhi/components/buttons/outlinebutton.dart';
import 'package:zouhi/components/support_call_sheet.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:zouhi/constants/theme.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';

import 'package:zouhi/components/foduu_name_initial_widget.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key);
  final profileController = Get.put(ProfileController(), permanent: true);

  final bottomeController = Get.find<BottombarController>();

  @override
  Widget build(BuildContext context) {
    // Rebuilds the moment the session is torn down, so cached name/email and
    // the account menu never outlive a dead session.
    return Obx(() {
      AuthDetails.loggedIn.value;
      return _buildBody(context);
    });
  }

  Widget _buildBody(BuildContext context) {
    if (!AuthDetails.loggedIn.value) {
      return SafeArea(
        child: Scaffold(
          backgroundColor: context.themeBackground,
          appBar: AppBar(
            backgroundColor: context.themeWhiteColor,
            elevation: 0,
            title: Text(
              'Profile',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
                color: context.themetitleColor,
              ),
            ),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcoming Guest Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.themeWhiteColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.themeBorderColor),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: context.themePrimaryLight,
                              border: Border.all(
                                color:
                                    context.themePrimaryColor.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.person_outline_rounded,
                              size: 32,
                              color: context.themePrimaryColor,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, Guest',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                    color: context.themetitleColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Sign in to track orders, save items & get personalized deals.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Poppins',
                                    color: context.themeSecondrytext,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Dual Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0B7FD4),
                                    Color(0xFF1257A5),
                                    Color(0xFF0A2A6B),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF1257A5)
                                        .withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  isOtpLogin
                                      ? Get.toNamed(Routes.MOBILELOGIN)
                                      : Get.toNamed(Routes.LOGIN);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 44,
                              child: OutlinedButton(
                                onPressed: () {
                                  isOtpLogin
                                      ? Get.toNamed(Routes.MOBILEREGISTER)
                                      : Get.toNamed(Routes.REGISTER);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: context.themePrimaryColor,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: Text(
                                  'Create Account',
                                  style: TextStyle(
                                    color: context.themePrimaryColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Quick Guest Utilities Card
                Text(
                  'Quick Services',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: context.themetitleColor,
                  ),
                ),
                const SizedBox(height: 10),

                Material(
                  color: context.themeWhiteColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: context.themeBorderColor),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      // _buildGuestTile(
                      //   context,
                      //   icon: Icons.track_changes_rounded,
                      //   title: 'Track an Order',
                      //   subtitle: 'Check order status with your Order ID',
                      //   onTap: () {
                      //     _showTrackOrderDialog(context);
                      //   },
                      // ),
                      // _buildTileDivider(context),
                      _buildGuestTile(
                        context,
                        icon: Icons.confirmation_number_outlined,
                        title: 'Coupons & Deals',
                        subtitle: 'Browse current offers and store discounts',
                        onTap: () => Get.toNamed(Routes.COUPONS),
                      ),
                      _buildTileDivider(context),
                      _buildGuestTile(
                        context,
                        icon: Icons.support_agent_rounded,
                        title: '24/7 Customer Support',
                        subtitle: 'Call $supportContact',
                        onTap: () => handleSupportCall(context),
                      ),
                      _buildTileDivider(context),
                      _buildGuestTile(
                        context,
                        icon: Icons.help_outline_rounded,
                        title: 'Help & FAQs',
                        subtitle: 'Frequently asked questions and guides',
                        onTap: () => Get.toNamed(Routes.HELPANDSUPPORT),
                      ),
                      _buildTileDivider(context),
                      _buildGuestTile(
                        context,
                        icon: Icons.business_outlined,
                        title: 'About Vision Infrastructure',
                        subtitle: 'Leading fiber optic & networking solutions',
                        onTap: () => Get.toNamed(Routes.ABOUTUS),
                      ),
                      _buildTileDivider(context),
                      _buildGuestTile(
                        context,
                        icon: Icons.hub_outlined,
                        title: 'Network Solutions',
                        subtitle: 'Infrastructure built around your industry',
                        onTap: () => Get.toNamed(Routes.SOLUTIONS),
                      ),

                      _buildTileDivider(context),
                      _buildGuestTile(
                        context,
                        icon: Icons.article_outlined,
                        title: 'From Our Blog',
                        subtitle: 'Read network infrastructure trends & guides',
                        onTap: () => Get.toNamed(Routes.BLOG),
                      ),
                      _buildTileDivider(context),
                      _buildGuestTile(
                        context,
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy Policy',
                        subtitle: 'How we collect and protect your data',
                        onTap: () => Get.toNamed(
                          Routes.POLICY_DETAIL,
                          arguments: {
                            'type': 'privacy',
                            'title': 'Privacy Policy',
                          },
                        ),
                      ),
                      _buildTileDivider(context),
                      _buildGuestTile(
                        context,
                        icon: Icons.gavel_rounded,
                        title: 'Terms & Conditions',
                        subtitle: 'Rules governing the use of our store',
                        onTap: () => Get.toNamed(
                          Routes.POLICY_DETAIL,
                          arguments: {
                            'type': 'terms',
                            'title': 'Terms & Conditions',
                          },
                        ),
                      ),
                      //_buildTileDivider(context),
                      // _buildGuestTile(
                      //   context,
                      //   icon: Icons.assignment_return_outlined,
                      //   title: 'Return & Refund Policy',
                      //   subtitle: 'Know your rights on returns',
                      //   onTap: () => Get.toNamed(
                      //     Routes.POLICY_DETAIL,
                      //     arguments: {
                      //       'type': 'refund',
                      //       'title': 'Return & Refund Policy',
                      //     },
                      //   ),
                      // ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Vision Infrastructure • Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      color: context.themeSecondrytext.withOpacity(0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.ensureDataLoaded();
      });
      return SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text('Profile',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    color: context.themeTextColor,
                    fontWeight: FontWeight.bold)),
            iconTheme: IconThemeData(
              color: context.themeTextColor,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await controller.fetchDataFromServer(forceRefresh: true);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: pageSurroundingPadding,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Obx(
                          () {
                            final imageVal =
                                controller.profiledata['featured_image'];
                            final nameVal = controller
                                    .nameController.text.isNotEmpty
                                ? controller.nameController.text
                                : controller.profiledata['name']?.toString();
                            final bool hasImage = imageVal != null &&
                                imageVal.toString().trim().isNotEmpty;

                            if (!hasImage) {
                              return FoduuNameInitialWidget(
                                name: nameVal,
                                size: 70,
                              );
                            }

                            final String imgUrl = HelperFunctions()
                                .getImage(imageVal, moduleName: 'ProfileView');
                            final Uri? parsedUri = Uri.tryParse(imgUrl);
                            final bool isValidUrl = parsedUri != null &&
                                parsedUri.hasAuthority &&
                                parsedUri.host.isNotEmpty;

                            if (!isValidUrl) {
                              return FoduuNameInitialWidget(
                                name: nameVal,
                                size: 70,
                              );
                            }

                            return ClipOval(
                              child: CachedNetworkImage(
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                                imageUrl: imgUrl,
                                errorWidget: (_, __, ___) =>
                                    FoduuNameInitialWidget(
                                  name: nameVal,
                                  size: 70,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(
                                () {
                                  final name =
                                      controller.profiledata['name']?.toString();
                                  final displayName =
                                      (name != null && name.isNotEmpty)
                                          ? name
                                          : controller.nameController.text;
                                  return Text(
                                    displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: context.themeTextColor),
                                  );
                                },
                              ),
                              Obx(
                                () {
                                  final email =
                                      controller.profiledata['email']?.toString();
                                  final displayEmail =
                                      (email != null && email.isNotEmpty)
                                          ? email
                                          : controller.emailController.text;
                                  return Text(
                                    displayEmail,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: context.themeSecondrytext),
                                  );
                                },
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 28,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.to(EditprofileView());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: themePrimaryColor,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    minimumSize: Size.zero,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 0),
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          themeButtonRadius),
                                    ),
                                  ),
                                  child: const Text('Edit',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Poppins')),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: ((context, index) {
                          final item = controller.profileOptions[index];
                          return SizedBox(
                            child: profileSection(
                              ontap: () {
                                if (item['title'] == 'Your Wishlist') {
                                  BottombarController.switchTab(3);
                                } else if (item['route'] != null) {
                                  Get.toNamed(item['route']);
                                }
                              },
                              assetIcon: item['icon'].toString(),
                              profileOption: item['title'].toString(),
                              optionDetial: item['subtitle'].toString(),
                            ),
                          );
                        }),
                        separatorBuilder: (context, index) => Divider(
                              thickness: 0.9,
                              color: context.themegreyColor,
                            ),
                        itemCount: controller.profileOptions.length),
                    const SizedBox(height: 20),
                    outLineButton(
                      pressEvent: () {
                        bottomeController.confirmAndLogout(context);
                      },
                      buttonText: 'LOG OUT',
                      backgroundColor: context.themeSecondrytext,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildGuestTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: context.themePrimaryLight,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: context.themePrimaryColor,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          color: context.themetitleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Poppins',
          color: context.themeSecondrytext,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: context.themeSecondrytext.withOpacity(0.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
    );
  }

  Widget _buildTileDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.8,
      indent: 62,
      endIndent: 14,
      color: context.themeBorderColor.withOpacity(0.6),
    );
  }

  void _showTrackOrderDialog(BuildContext context) {
    final orderIdController = TextEditingController();
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.themeWhiteColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Track Your Order',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                    color: context.themetitleColor,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Enter your 24-character Order ID or reference to look up live status.',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: context.themeSecondrytext,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: orderIdController,
              decoration: InputDecoration(
                hintText: 'e.g. 6a92d50a3c13c2a7e993eff5',
                hintStyle: TextStyle(
                  fontSize: 13,
                  color: context.themeSecondrytext.withOpacity(0.6),
                ),
                filled: true,
                fillColor: context.themeBackground,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: context.themeBorderColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: context.themeBorderColor),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  final id = orderIdController.text.trim();
                  if (id.isEmpty) {
                    HelperFunctions()
                        .showSnackBarError('Please enter a valid Order ID');
                    return;
                  }
                  Get.back();
                  Get.toNamed(Routes.ORDER_DETAILS, arguments: {'id': id});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.themePrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Lookup Order',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}

class profileSection extends StatelessWidget {
  profileSection(
      {Key? key,
      required this.assetIcon,
      required this.profileOption,
      required this.optionDetial,
      required this.ontap})
      : super(key: key);
  String assetIcon;
  String profileOption;
  String optionDetial;
  VoidCallback ontap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: ontap,
        child: Row(
          children: [
            SvgPicture.asset(
              assetIcon,
              width: 25,
              colorFilter: ColorFilter.mode(
                context.themeTextColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profileOption,
                    style: TextStyle(
                        fontSize: 14,
                        color: context.themeTextColor,
                        fontFamily: 'Poppins')),
                Text(optionDetial,
                    style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Poppins',
                        color: context.themeSecondrytext))
              ],
            )
          ],
        ),
      ),
    );
  }
}
