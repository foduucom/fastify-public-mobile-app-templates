import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/contact/binding/contact_binding.dart';
import 'package:foduu_ecommerce/app/modules/contact/views/contact_view.dart';

class ContactUsView extends StatelessWidget {
  const ContactUsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ensure ContactBinding dependencies are initialized
    ContactBinding().dependencies();
    return const ContactView();
  }
}
