import 'package:flutter/material.dart';
import 'package:foddu/components/app_web_view_screen.dart';
import 'package:foddu/constants/constants.dart';
import 'package:get/get.dart';
import '../controllers/termsandcondition_controller.dart';

class TermsandconditionView extends GetView<TermsConditionsController> {
  const TermsandconditionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppWebViewScreen(
      title: 'Terms & Conditions',
      url: '${url}terms-conditions',
    );
  }
}
