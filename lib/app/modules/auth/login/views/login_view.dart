// Alias — LoginView is the unified auth entry screen.
// The actual implementation lives in create_account_view.dart.
export 'create_account_view.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_account_view.dart';
import '../controllers/login_controller.dart';

/// LoginView is a thin wrapper / alias for CreateAccountView.
/// Routes that navigate to LOGIN use this class so the router stays consistent.
class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return const CreateAccountView();
  }
}

