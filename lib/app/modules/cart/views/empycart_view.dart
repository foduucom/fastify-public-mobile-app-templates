import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zouhi/app/modules/bottomar/controllers/bottombar_controller.dart';
import 'package:zouhi/app/routes/app_pages.dart';
import 'package:zouhi/components/buttons/appbutton.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class EmptycartView extends GetView {
  const EmptycartView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text('Shop',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    color: context.themeTextColor,
                    fontWeight: FontWeight.w600)),
            actions: [
              IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset('assets/icon/appbarshop.svg'))
            ],
            iconTheme: IconThemeData(
              color: context.colors.onSurface,
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
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 20),
                const SizedBox(
                    width: 320,
                    child: Text(
                        'Looks like you haven’t added anything to your cart yet. You will find a lot of interesting products on our “Shop” page',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 16))),
                const SizedBox(height: 20),
                AppButton(
                    itemText: 'START SHOPPING',
                    keypressEvent: () {
                      BottombarController.switchTab(1);
                    })
              ],
            ),
          )),
    );
  }
}
