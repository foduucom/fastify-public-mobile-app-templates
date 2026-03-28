// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '/constants/helper_functions.dart';
import '/constants/theme.dart';
import 'package:get/get.dart';
import '../../../../../constants/constants.dart';
import '../controllers/termsandcondition_controller.dart';

class TermsandconditionView extends GetView<TermsandconditionController> {
  const TermsandconditionView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Terms & Condition",
            style: txtTheme()
                .headlineSmall!
                .copyWith(fontWeight: FontWeight.bold, fontFamily: "Lato"),
          ),
          iconTheme: IconThemeData(
            color: Colors.black,
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() {
                  if (controller.termsAndConditinDetails.isEmpty) {
                    return Center(
                      child: HelperFunctions().loadingIndicator(),
                    );
                  } else {
                    return Html(
                      data: controller.termsAndConditinDetails.toString(),
                      style: {
                        "body": Style(
                          // padding: EdgeInsets.zero,
                          fontFamily: "Lato",
                        ),
                        "div": Style(
                            // padding: EdgeInsets.zero,
                            ),
                        "p": Style(
                            // padding: EdgeInsets.zero,
                            ),
                      },
                    );
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
