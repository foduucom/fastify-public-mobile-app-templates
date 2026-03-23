import 'package:flutter/material.dart';

import '../../../../../../app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: AppColors.titleText,
    letterSpacing: 0,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.subtitleText,
  );

  static const TextStyle fieldLabel = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.labelText,
  );

  static const TextStyle fieldInput = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.labelText,
  );

  static const TextStyle fieldHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.hintText,
  );

  static const TextStyle primaryButton = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
    letterSpacing: 0.3,
  );

  static const TextStyle dividerLabel = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.scaffoldBackground,
  );

  static const TextStyle socialButton = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: AppColors.socialButtonText,
  );
}
