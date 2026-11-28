import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/createnewpassword/controllers/create_new_password_controllers.dart';
import 'package:foduu_ecommerce/app/routes/app_pages.dart';
import 'package:foduu_ecommerce/components/buttons/primary_action_button.dart';
import 'package:get/get.dart';

class CreateNewPasswordView extends GetView<CreateNewPasswordController> {
  const CreateNewPasswordView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Password recovery')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.lock_reset_outlined, size: 56, color: colors.primary),
              const SizedBox(height: 20),
              Text(
                'Password reset is unavailable',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'The store has not provided a secure password-reset endpoint yet. Your password was not changed. Contact store support for help.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 28),
              PrimaryActionButton(
                text: 'Contact Support',
                onPressed: () => Get.offAllNamed(Routes.HELPANDSUPPORT),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Get.offAllNamed(Routes.LOGIN),
                child: const Text('Back to Sign In'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
