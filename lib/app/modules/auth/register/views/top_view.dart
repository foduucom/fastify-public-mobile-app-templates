import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../../components/app_back_button.dart';


class OTPView extends StatefulWidget {
  const OTPView({Key? key}) : super(key: key);

  @override
  State<OTPView> createState() => _OTPViewState();
}

class _OTPViewState extends State<OTPView> {

  // ── State ────────────────────────────────────────────────────────
  final List<TextEditingController> _controllers =
  List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
  List.generate(4, (_) => FocusNode());

  bool  _isLoading    = false;
  int   _resendSeconds = 30;
  Timer? _timer;

  String get _email =>
      (Get.arguments?['email'] ?? 'example@gmail.com').toString();

  String get _otpCode =>
      _controllers.map((c) => c.text).join();

  // ── Lifecycle ────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes)  f.dispose();
    super.dispose();
  }

  // ── Timer ────────────────────────────────────────────────────────
  void _startResendTimer() {
    setState(() => _resendSeconds = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendSeconds == 0) {
        t.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  // ── Actions ──────────────────────────────────────────────────────
  Future<void> _verifiyOtp() async {
    if (_otpCode.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all 4 digits')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      // TODO: call your verify API here with _otpCode
      await Future.delayed(const Duration(seconds: 1)); // remove this line
      // Get.offAllNamed(Routes.BOTTOMBAR);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendOtp() async {
    // TODO: call your resend API here
    _startResendTimer();
  }

  // ── Build ─────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Colors.white,

      // ── AppBar ────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: AppBackButton(),
        ),
      ),

      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              const SizedBox(height: 32),

              // ── Title ──────────────────────────────────────────────
              Text(
                'Enter OTP',
                style: textTheme.headlineMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),

              const SizedBox(height: 14),

              // ── Subtitle ───────────────────────────────────────────
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text:
                  'We have just sent you 4 digit code via your\nemail ',
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade500,
                    height: 1.6,
                  ),
                  children: [
                    TextSpan(
                      text: _email,
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ── 4 Circular OTP Boxes ───────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                      (index) => _buildOtpBox(
                    context: context,
                    index: index,
                    colorScheme: colorScheme,
                    textTheme: textTheme,
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // ── Continue Button ────────────────────────────────────
              _isLoading
                  ? Center(
                child: CircularProgressIndicator(
                    color: colorScheme.primary),
              )
                  : SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _verifiyOtp,
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

              const SizedBox(height: 24),

              // ── Resend Code ────────────────────────────────────────
              GestureDetector(
                onTap: _resendSeconds == 0 ? _resendOtp : null,
                child: RichText(
                  text: TextSpan(
                    text: "Didn't receive code? ",
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    children: [
                      TextSpan(
                        text: _resendSeconds > 0
                            ? 'Resend in ${_resendSeconds}s'
                            : 'Resend Code',
                        style: TextStyle(
                          color: _resendSeconds > 0
                              ? Colors.grey.shade400
                              : colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Single Circular OTP Box ────────────────────────────────────────
  Widget _buildOtpBox({
    required BuildContext context,
    required int index,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      width: 68,
      height: 68,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.primary, width: 1.5),
        color: Colors.white,
      ),
      child: Center(
        child: TextFormField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: textTheme.headlineSmall?.copyWith(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) {
            if (value.isNotEmpty && index < 3) {
              FocusScope.of(context)
                  .requestFocus(_focusNodes[index + 1]);
            } else if (value.isEmpty && index > 0) {
              FocusScope.of(context)
                  .requestFocus(_focusNodes[index - 1]);
            }
          },
        ),
      ),
    );
  }
}