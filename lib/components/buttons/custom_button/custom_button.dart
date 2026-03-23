import 'package:flutter/material.dart';

import '../../../app/modules/auth/login/views/widgets/app_text_styles.dart';
import '../../../app_colors.dart';


class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isEnabled;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.label,
    this.onTap,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? AppColors.primaryButtonActive
              : AppColors.scaffoldBackground,
          disabledBackgroundColor: AppColors.scaffoldBackground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: isLoading
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            color: AppColors.buttonText,
            strokeWidth: 2.5,
          ),
        )
            : Text(label, style: AppTextStyles.primaryButton),
      ),
    );
  }
}
