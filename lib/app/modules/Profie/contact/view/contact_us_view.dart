import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/app_web_view_screen.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AppWebViewScreen(
      title: "Contact Us",
      url: "https://traditional-ecom.vbought.com/contact",
    );
  }
}