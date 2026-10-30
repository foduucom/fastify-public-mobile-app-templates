import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../login/views/create_account_view.dart';

/// RegisterView delegates to CreateAccountView which handles both
/// login and registration flows via a tab/toggle.
class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CreateAccountView();
  }
}

