import 'package:flutter/cupertino.dart';
import 'package:zouhi/constants/theme.dart';
import '../constants/constants.dart';
import '../constants/theme_ext.dart';

class deliveryCartProducts extends StatelessWidget {
  deliveryCartProducts({
    required this.assetImage,
    required this.productName,
    required this.deliveryDate,
    Key? key,
  }) : super(key: key);
  String assetImage;
  String productName;
  String deliveryDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: context.themegreyColor,
          borderRadius: BorderRadius.circular(5)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                height: 90,
                width: 90,
                color: context.themegreyColor,
                child: Image.asset(assetImage, fit: BoxFit.contain),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(productName,
                    style: TextStyle(
                        fontFamily: 'Poppins', color: context.themeSecondrytext)),
                const SizedBox(height: 5.0),
                RichText(
                    text: TextSpan(
                  text: 'Delivery ',
                  style: txtTheme().headlineSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Poppins'),
                  children: [
                    TextSpan(
                        text: "${deliveryDate}th July",
                        style: TextStyle(color: context.themeGreenColor)),
                  ],
                ))
              ],
            )
          ],
        ),
      ),
    );
  }
}
