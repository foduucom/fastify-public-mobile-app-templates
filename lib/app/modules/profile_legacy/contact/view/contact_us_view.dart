import 'package:flutter/material.dart';
import 'package:foddu/components/app_web_view_screen.dart';
import 'package:foddu/constants/constants.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppWebViewScreen(
      title: "Contact Us",
      url: "${url}contact",
    );
  }
}