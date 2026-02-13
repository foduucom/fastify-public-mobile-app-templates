import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:foduu_ecommerce/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class EmptycartView extends GetView {
  const EmptycartView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: const Text('Shop',
                style: TextStyle(
                    fontFamily: 'lato',
                    fontSize: 16,
                    // color: themeTextColor,
                    fontWeight: FontWeight.w600)),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset('assets/icon/appbarshop.svg'))
            ],
            iconTheme: const IconThemeData(
              color: Colors.black,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: pageSurroundingPadding,
            child: Column(
              children: [
                Lottie.asset('assets/lotti/emptyanimation.json'),
                const SizedBox(height: 20),
                const Text('Whoops !! Cart is Empty',
                    style: TextStyle(
                        fontFamily: 'lato',
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                const SizedBox(
                    width: 320,
                    child: Text(
                        'Looks like you haven’t added anything to your cart yet. You will find a lot of interesting products on our “Shop” page',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'lato', fontSize: 16))),
                const SizedBox(height: 20),
                AppButton(
                    itemText: 'START SHOPPING',
                    keypressEvent: () {
                      Get.back();
                      Get.find<BottombarController>().currentPageIndex.value =
                          0;
                      Get.find<BottombarController>()
                          .pageController
                          .jumpToPage(0);
                    })
              ],
            ),
          )),
    );
  }
}
