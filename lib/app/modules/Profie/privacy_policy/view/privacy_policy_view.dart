import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/app_web_view_screen.dart';
import 'package:foduu_ecommerce/constants/constants.dart';
import 'package:get/get.dart';
import '../controller/privacy_policy_controller.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppWebViewScreen(
      title: "Privacy Policy",
      url: "${url}privacy-policy",
    );
  }
}