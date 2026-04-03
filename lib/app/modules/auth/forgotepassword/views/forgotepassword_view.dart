import 'package:flutter/material.dart';
import '../../../../../components/app_bar.dart';
import '/app/routes/app_pages.dart';
import '/components/foduuformtextfield.dart';
import '/constants/constants.dart';
import 'package:get/get.dart';
import '../controllers/forgotepassword_controller.dart';

class ForgotepasswordView extends GetView<ForgotepasswordController> {
   ForgotepasswordView({Key? key}) : super(key: key);

  // ✅ Local controller since ForgotepasswordController doesn't have one
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,
       appBar: CustomAppBar(title: ''),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [



                // ── Grey Circle Back Button ─────────────────────────────


                const SizedBox(height: 40),

                // ── Title ───────────────────────────────────────────────
                Center(
                  child: Text(
                    'Forgot Password',
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // ── Subtitle ────────────────────────────────────────────
                Center(
                  child: Text(
                    'Recover your account password',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade500,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Email Label ─────────────────────────────────────────
                Text(
                  'E-mail',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Color(0xFF78828A),
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 8),

                // ── Email Input Field ───────────────────────────────────
                FoduuFormTextField(
                  fieldHintText: 'Enter your email',
                  title: '',
                  validationmsg: 'Please enter email',
                  validCheck: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter an email address".tr;
                    } else if (!GetUtils.isEmail(value)) {
                      return "Please enter a valid email address".tr;
                    }
                    return null;
                  },
                  keyType: TextInputType.emailAddress,
                  controller: _emailController, // ✅ local controller
                ),

                const SizedBox(height: 32),

                // ── Continue Button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                      // TODO: wire up to your controller method
                      // e.g. controller.sendOtp(_emailController.text)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Continue',
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}
