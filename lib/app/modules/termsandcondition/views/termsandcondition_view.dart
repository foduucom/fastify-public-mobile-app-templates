import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/app_web_view_screen.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:get/get.dart';
import '../controllers/termsandcondition_controller.dart';

class TermsandconditionView extends GetView<TermsandconditionController> {
  const TermsandconditionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppWebViewScreen(
      title: "Terms & Conditions",
      url: "${url}terms-conditions",
    );
  }
}
