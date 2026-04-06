import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '/app/modules/auth/auth_details.dart';
import '/app/modules/bottomar/controllers/bottombar_controller.dart';
import '/app/modules/Profie/profile/controllers/profile_controller.dart';
import '/app/modules/Profie/profile/views/editprofile_view.dart';
import '/app/routes/app_pages.dart';
import '/components/buttons/appbutton.dart';
import '/components/buttons/outlinebutton.dart';
import '/constants/constants.dart';
import '/constants/helper_functions.dart';
import '/constants/theme.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key);
  final profileController =
      Get.lazyPut<ProfileController>(() => ProfileController());

  final bottomeController = Get.find<BottombarController>();

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    if (!AuthDetails.isUserLogin()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Profile',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontFamily: 'lato',
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
                child: Text(
              'Login to View Profile',
              style: txtTheme().displayMedium,
            )),
            const SizedBox(height: 15),
            SizedBox(
              width: Get.width * 0.6,
              child: AppButton(
                  itemText: 'Login',
                  keypressEvent: () {
                    // controller.box.erase();
                    Get.offAllNamed(Routes.LOGIN);
                  }),
            ),
          ],
        ),
      );
    } else {
      return SafeArea(
        child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                print(AuthDetails.isUserLogin());
                print(AuthDetails.getUserDetails());
              },
            ),
            appBar: AppBar(
              centerTitle: true,
              title: SizedBox(
                width: width * 0.26,
                child: Text(
                  "My Profile",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: height * 0.025,
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
              ),
              elevation: 0,
              automaticallyImplyLeading: false,
            ),
            body: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.05,
                vertical: height * 0.02,
              ),
              children: [
                // Profile Header Card
                Container(
                  width: width * 0.92,
                  padding: EdgeInsets.all(width * 0.03),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(height * 0.015),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image
                      Obx(
                        () => Container(
                          width: height * 0.075,
                          height: height * 0.075,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: controller.profiledata['featured_image'] ==
                                      null
                                  ? const AssetImage('assets/images/men.png')
                                  : NetworkImage(HelperFunctions().getImage(
                                          controller
                                              .profiledata['featured_image']))
                                      as ImageProvider,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: width * 0.05),
                      // User Info
                      SizedBox(
                        width: width * 0.60,
                        height: height * 0.07,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Obx(
                                    () => Text(
                                      controller.profiledata['name']
                                              ?.toString() ??
                                          '',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: height * 0.022,
                                        fontWeight: FontWeight.w600,
                                        height: 1.66,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Get.to(() => const EditprofileView());
                                      },
                                      child: const Text('Edit',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'Lato')),
                                    ),
                                  ),
                                ]),
                            Obx(
                              () => Text(
                                controller.profiledata['email']?.toString() ??
                                    '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: height * 0.018,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: height * 0.0215),

                // Profile Menu List
                Container(
                  width: width * 0.92,
                  height: height * 0.69,
                  child: ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: controller.profileOptions.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox.shrink(),
                    itemBuilder: ((context, index) {
                      return Container(
                        width: width * 0.92,
                        padding: EdgeInsets.only(
                          bottom: height * 0.025,
                        ),
                        margin: EdgeInsets.only(
                          bottom: index < controller.profileOptions.length - 1
                              ? height * 0.02
                              : 0,
                        ),
                        decoration: index < controller.profileOptions.length - 1
                            ? const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey,
                                    width: 1,
                                  ),
                                ),
                              )
                            : null,
                        child: profileSection(
                          ontap: () {
                            switch (index) {
                              case 0:
                                Get.toNamed(Routes.ORDERS);
                                break;
                              case 1:
                                Get.toNamed(Routes.WISHLIST);
                                break;
                              case 2:
                                Get.toNamed(Routes.PAYMENT);
                                break;
                              case 3:
                                Get.toNamed(Routes.ADDRESS_LIST);
                                break;
                              case 4:
                                Get.toNamed(Routes.NOTIFICATION);
                              case 5:
                                Get.toNamed(Routes.CONTACTUS);
                                break;
                              default:
                            }
                          },
                          assetIcon: controller.profileOptions[index]['icon']
                              .toString(),
                          profileOption: controller.profileOptions[index]
                                  ['title']
                              .toString(),
                          optionDetial: controller.profileOptions[index]
                                  ['subtitle']
                              .toString(),
                          width: width,
                          height: height,
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 20),

                // Logout Button
                outLineButton(
                  pressEvent: () {
                    Get.find<BottombarController>().logout();
                  },
                  buttonText: 'LOG OUT',
                  backgroundColor: Theme.of(context).primaryColor,
                ),

                const SizedBox(height: 20),
              ],
            )),
      );
    }
  }
}

class profileSection extends StatelessWidget {
  profileSection({
    Key? key,
    required this.assetIcon,
    required this.profileOption,
    required this.optionDetial,
    required this.ontap,
    required this.width,
    required this.height,
  }) : super(key: key);

  String assetIcon;
  String profileOption;
  String optionDetial;
  VoidCallback ontap;
  double width;
  double height;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: ontap,
      child: Row(
        children: [
          // Icon - handle both SVG and icon data types
          if (assetIcon.startsWith('assets/'))
            SvgPicture.asset(
              assetIcon,
              width: height * 0.025,
            )
          else
            Icon(
              _getIconFromString(assetIcon),
              size: height * 0.025,
            ),

          SizedBox(width: width * 0.03),

          // Title and Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profileOption,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: height * 0.018,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                if (optionDetial.isNotEmpty)
                  Text(
                    optionDetial,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: height * 0.016,
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
              ],
            ),
          ),

          // Chevron Icon
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              size: height * 0.025,
            ),
            onPressed: ontap,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // Helper method to convert string to IconData
  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'orders':
        return Icons.shopping_bag_outlined;
      case 'wishlist':
        return Icons.favorite_border;
      case 'payment':
        return Icons.payment_outlined;
      case 'address':
        return Icons.location_on_outlined;
      case 'notifications':
        return Icons.notifications_outlined;
      default:
        return Icons.circle_outlined;
    }
  }
}
