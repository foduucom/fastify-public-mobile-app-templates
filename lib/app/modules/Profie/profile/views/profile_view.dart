import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/controllers/profile_controller.dart';
import 'package:foduu_ecommerce/app/modules/Profie/profile/views/editprofile_view.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/components/buttons/outlinebutton.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:foduu_ecommerce/constants/helper_functions.dart';
import 'package:foduu_ecommerce/constants/theme.dart';
import 'package:get/get.dart';

class ProfileView extends GetView<ProfileController> {
  ProfileView({Key? key}) : super(key: key);
  final profileController =
      Get.lazyPut<ProfileController>(() => ProfileController());

  final bottomeController = Get.find<BottombarController>();

  @override
  Widget build(BuildContext context) {
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
              heroTag: 'profile_fab',
              onPressed: () {
                print(AuthDetails.isUserLogin());
                print(AuthDetails.getUserDetails());
              },
            ),
            appBar: AppBar(
              title: const Text('Profile',
                  style: TextStyle(
                      fontFamily: 'lato', fontWeight: FontWeight.bold)),
              elevation: 0,
              automaticallyImplyLeading: false,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: pageSurroundingPadding,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Obx(
                          () => ClipOval(
                              child: controller.profiledata['featured_image'] ==
                                      null
                                  ? ClipRRect(
                                      borderRadius:
                                          BorderRadiusGeometry.circular(100),
                                      child: Container(
                                        height: 70,
                                        width: 70,
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                        ),
                                        child: Image.asset(
                                            'assets/images/user.png',
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            width: 40,
                                            fit: BoxFit.fill),
                                      ),
                                    )
                                  : CachedNetworkImage(
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      imageUrl: HelperFunctions().getImage(
                                          controller
                                              .profiledata['featured_image']))),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(
                              () => Text(
                                  controller.profiledata['name']?.toString() ??
                                      '',
                                  style: const TextStyle(
                                    fontFamily: 'lato',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  )),
                            ),
                            Obx(
                              () => Text(
                                  controller.profiledata['email']?.toString() ??
                                      '',
                                  // controller.profiledata[0]['email'],
                                  style: const TextStyle(
                                    fontFamily: 'lato',
                                    fontSize: 12,
                                  )),
                            ),
                            const SizedBox(height: 10),
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
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 1.7,
                      child: ListView.separated(
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: ((context, index) {
                            return SizedBox(
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
                                      Get.toNamed(Routes.ADDRESS_LIST1);
                                      break;
                                    case 4:
                                      Get.toNamed(Routes.NOTIFICATION);
                                      break;
                                    case 5:
                                      Get.toNamed(Routes.CONTACTUS);
                                      break;
                                    default:
                                  }
                                },
                                assetIcon: controller.profileOptions[index]
                                        ['icon']
                                    .toString(),
                                profileOption: controller.profileOptions[index]
                                        ['title']
                                    .toString(),
                                optionDetial: controller.profileOptions[index]
                                        ['subtitle']
                                    .toString(),
                              ),
                            );
                          }),
                          separatorBuilder: (context, index) => const Divider(
                                thickness: 0.9,
                              ),
                          itemCount: controller.profileOptions.length),
                    ),
                    const SizedBox(height: 20),
                    outLineButton(
                      pressEvent: () {
                        Get.find<BottombarController>().logout();
                      },
                      buttonText: 'LOG OUT',
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            )),
      );
    }
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
            SvgPicture.asset(assetIcon, width: 25),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profileOption,
                    style: const TextStyle(
                        fontSize: 14,
                        // color: themeTextColor,
                        fontFamily: 'lato')),
                Text(optionDetial,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'lato',
                      // color: themeSecondrytext
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
