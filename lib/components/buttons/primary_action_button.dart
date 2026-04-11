import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/constants/dynamic_theme.dart';
import 'package:get/get.dart';

class PrimaryActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final double fontSize;
  final Color? backgroundColor;
  final Color? textColor;
  final FontWeight fontWeight;
  final double elevation;
  final bool isLoading; // New parameter
  final Widget? loadingWidget; // Optional custom loading widget
  final Color? loadingIndicatorColor; // Color for the loading indicator
  final double verticalPadding;

  const PrimaryActionButton({
    super.key,
    required this.text,
    this.onPressed,
    this.height = 0.07,
    this.borderRadius = 30,
    this.fontSize = 15,
    this.backgroundColor,
    this.textColor,
    this.fontWeight = FontWeight.w600,
    this.elevation = 3,
    this.isLoading = false, // Default to false
    this.loadingWidget,
    this.loadingIndicatorColor,
    this.verticalPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: Get.height * height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Disable when loading
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? DefaultThemeColors.mainprimary,
          elevation: elevation,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          // Optional: Change color when disabled/loading
          disabledBackgroundColor:
              (backgroundColor ?? DefaultThemeColors.mainprimary)
                  .withOpacity(0.7),
        ),
        child: isLoading
            ? _buildLoadingWidget()
            : Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  color: textColor ?? DefaultThemeColors.lightOnPrimary,
                  fontWeight: fontWeight,
                ),
              ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    if (loadingWidget != null) {
      return loadingWidget!;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              loadingIndicatorColor ??
                  textColor ??
                  DefaultThemeColors.lightOnPrimary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading...',
          style: TextStyle(
            fontSize: fontSize,
            color: textColor ?? DefaultThemeColors.lightOnPrimary,
            fontWeight: fontWeight,
          ),
        ),
      ],
    );
  }
}
