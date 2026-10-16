import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/components/app_web_view_screen.dart';

class ContactView extends StatelessWidget {
  const ContactView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const AppWebViewScreen(
      title: "Contact Us",
      url: "https://traditional-ecom.vbought.com/contact",
    );
  }
}
