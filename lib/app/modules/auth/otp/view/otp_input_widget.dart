import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/app/modules/auth/otp/controller.dart/otp_controller.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';
import 'package:foduu_ecommerce/app/modules/auth/login/components/app_text.dart';

class OtpInputWidget extends StatefulWidget {
  final int length;
  final Function(String) onCompleted;
  final FocusNode? focusNode;
  final OtpController controller;

  const OtpInputWidget({
    Key? key,
    this.length = 4,
    required this.onCompleted,
    this.focusNode,
    required this.controller,
  }) : super(key: key);

  @override
  _OtpInputWidgetState createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  late List<String> _otpValues;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = List.generate(
      widget.length,
      (index) => TextEditingController(),
    );
    _focusNodes = List.generate(
      widget.length,
      (index) => FocusNode(),
    );
    _otpValues = List.filled(widget.length, '');

    // Set up focus node listeners
    for (int i = 0; i < widget.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          widget.controller.setActive(i);
        }
      });
    }
  }

  void _handleTextChange(String value, int index) {
    // Remove any non-digit characters
    value = value.replaceAll(RegExp(r'[^0-9]'), '');

    if (value.isNotEmpty && value.length > 1) {
      // User pasted multiple characters
      _handlePaste(value, index);
      return;
    }

    // Update OTP value
    _otpValues[index] = value;

    // Update the controller text field
    _controllers[index].text = value;

    // Move to next field if current field is filled
    if (value.isNotEmpty && index < widget.length - 1) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    }

    // Move to previous field if backspace pressed and current field is empty
    if (value.isEmpty && index > 0) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
    }

    // Check if OTP is complete
    _checkOtpComplete();
  }

  void _handlePaste(String pastedText, int startIndex) {
    // Take only the needed characters
    final neededLength = widget.length - startIndex;
    final textToPaste =
        pastedText.substring(0, neededLength.clamp(0, pastedText.length));

    // Fill the fields with pasted text
    for (int i = 0; i < textToPaste.length; i++) {
      final charIndex = startIndex + i;
      if (charIndex < widget.length) {
        _controllers[charIndex].text = textToPaste[i];
        _otpValues[charIndex] = textToPaste[i];
      }
    }

    // Move focus to last filled field
    final lastFilledIndex = startIndex + textToPaste.length - 1;
    if (lastFilledIndex < widget.length) {
      FocusScope.of(context).requestFocus(_focusNodes[lastFilledIndex]);
    }

    _checkOtpComplete();
  }

  void _checkOtpComplete() {
    final otp = _otpValues.join();
    if (otp.length == widget.length) {
      widget.onCompleted(otp);
    }
    // Update controller
    widget.controller.otpCode.value = otp;
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var width = Get.width;
    var height = Get.height;

    return Obx(() => Container(
          width: width * 0.92,
          height: height * 0.08,
          padding: EdgeInsets.symmetric(horizontal: width * 0.04),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onInverseSurface,
            borderRadius: BorderRadius.circular(height * 0.01),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (index) {
              return GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(_focusNodes[index]);
                  widget.controller.setActive(index);
                },
                child: Container(
                  width: width * 0.18,
                  height: height * 0.08,
                  padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04,
                    vertical: height * 0.02,
                  ),
                  decoration: BoxDecoration(
                    //color: Theme.of(context).colorScheme.onSurface,
                    color: DefaultThemeColors.lightOnPrimary,
                    borderRadius: BorderRadius.circular(height * 0.01),
                    border: Border.all(
                      color: widget.controller.activeIndex.value == index
                          ? DefaultThemeColors.darkdark
                          : DefaultThemeColors.darklight,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: height * 0.022,
                        fontWeight: FontWeight.w600,
                        //color: Theme.of(context).colorScheme.onInverseSurface,
                        color: DefaultThemeColors.darkdark,
                      ),
                      decoration: const InputDecoration(
                        counterText: '',
                        border: InputBorder.none,
                      ),
                      onChanged: (value) => _handleTextChange(value, index),
                    ),
                  ),
                ),
              );
            }),
          ),
        ));
  }
}
