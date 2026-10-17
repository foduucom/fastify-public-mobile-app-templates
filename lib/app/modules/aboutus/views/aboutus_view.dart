import 'package:flutter/material.dart';
import 'package:new_fastify_template/components/app_web_view_screen.dart';
import 'package:new_fastify_template/constants/constants.dart';
import 'package:get/get.dart';
import '../controllers/aboutus_controller.dart';

class AboutusView extends GetView<AboutusController> {
  const AboutusView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppWebViewScreen(
      title: 'About Us',
      url: '${url}about',
    );
  }
}
