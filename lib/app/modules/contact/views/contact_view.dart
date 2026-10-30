import 'package:flutter/material.dart';
import 'package:foddu/components/app_web_view_screen.dart';
import 'package:foddu/constants/constants.dart';

class ContactView extends StatelessWidget {
  const ContactView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppWebViewScreen(
      title: "Contact Us",
      url: "${url}contact",
    );
  }
}
