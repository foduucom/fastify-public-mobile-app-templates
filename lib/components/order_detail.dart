import 'package:flutter/material.dart';
import '/constants/theme.dart';

class OrderDetail extends StatelessWidget {
  OrderDetail({
    Key? key,
    required this.title,
    required this.amount,
    this.titleWidget,
  }) : super(key: key);
  String title;
  Widget amount;
  final Widget? titleWidget;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (titleWidget != null) titleWidget!,
          if (titleWidget == null) Text(title, style: txtTheme().displaySmall),
          amount
        ],
      ),
    );
  }
}
