import 'package:flutter/material.dart';
import 'package:zouhi/constants/constants.dart';

class CompanyTrademarkWidget extends StatelessWidget {
  final Color textColor;
  final double fontSize;
  final double logoHeight;
  final EdgeInsetsGeometry padding;

  const CompanyTrademarkWidget({
    Key? key,
    this.textColor = themeSecondrytext,
    this.fontSize = 13.0,
    this.logoHeight = 24.0,
    this.padding = const EdgeInsets.symmetric(vertical: 8.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Design by',
            style: TextStyle(
              color: textColor,
              fontFamily: 'Poppins',
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(width: 6),
          Image.asset(
            'assets/images/foduu-logo.webp',
            height: logoHeight,
            fit: BoxFit.contain,
            semanticLabel: 'FODUU',
          ),
        ],
      ),
    );
  }
}
