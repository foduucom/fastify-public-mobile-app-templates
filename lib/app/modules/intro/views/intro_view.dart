// import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/intro/controllers/intro_controller.dart';
import 'package:foduu_ecommerce/components/buttons/appbutton.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class IntroView extends GetView<IntroController> {
  const IntroView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        leading: Transform.translate(
          offset: const Offset(15, 0),
          child: Image.asset('assets/images/logo.png'),
        ),
        leadingWidth: 77,
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 12, end: 10),
            child: InkWell(onTap: () {
              controller.onProceedNext();
            }, child: Obx(() {
              return Text(
                controller.selectedPageIndex.value == 2 ? 'DONE' : 'SKIP',
                style: const TextStyle(
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w600,
                    // color: themeTextColor,
                    fontSize: 16),
              );
            })),
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: pageSurroundingPadding,
        child: Column(
          children: [
            Expanded(
              flex: 1,
              // height: 370,
              child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: (value) {
                    controller.selectedPageIndex.value = value;
                  },
                  itemCount: controller.introPage.length,
                  itemBuilder: (context, index) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                            controller.introPage[index]["image"].toString(),
                            height: 220,
                            width: 330,
                            fit: BoxFit.fill),
                        const SizedBox(height: 20),
                        Text(
                          controller.introPage[index]["title"].toString(),
                          style:
                              const TextStyle(fontFamily: 'Lato', fontSize: 20),
                        ),
                        const SizedBox(height: 5),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Text(
                            controller.introPage[index]["descrition"]
                                .toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        )
                      ],
                    );
                  }),
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(
                  controller.introPage.length,
                  (index) => Obx(() {
                    return Container(
                      width:
                          controller.selectedPageIndex.value == index ? 30 : 9,
                      height: 9,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }),
                )),
            // const Spacer(),
            SizedBox(
              height: 10,
            ),
            Obx(
              () => AppButton(
                itemText: controller.selectedPageIndex.value + 1 ==
                        controller.introPage.length
                    ? 'START SHOPPING'
                    : "NEXT",
                keypressEvent: () {
                  if (controller.selectedPageIndex.value + 1 ==
                      controller.introPage.length) {
                    controller.onProceedNext();
                    // Get.offNamed(Routes.BOTTOMBAR);
                  } else {
                    controller.pageController
                        .jumpToPage(controller.selectedPageIndex.value + 1);
                  }
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),

            // const Spacer(),
            // Center(
            //   child: RichText(
            //       text: TextSpan(
            //           text: 'Already have an account? ',
            //           style: const TextStyle(
            //               color: themeSecondrytext, fontFamily: 'Lato'),
            //           children: [
            //         TextSpan(
            //           text: 'Sign In',
            //           style: const TextStyle(
            //               color: themeSecondrytext,
            //               decoration: TextDecoration.underline),
            //           recognizer: TapGestureRecognizer()
            //             ..onTap = () {
            //               // Get.to(() => LoginView());
            //             },
            //         )
            //       ])),
            // ),
            // const Spacer(),
          ],
        ),
      ),
    ));
  }
}
