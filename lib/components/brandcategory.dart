import 'package:flutter/cupertino.dart';

import '../constants/constants.dart';

class brandCategory extends StatelessWidget {
  const brandCategory({
    Key? key,
    required this.assetImage,
  }) : super(key: key);
  final String assetImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(3)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              assetImage,
              fit: BoxFit.contain,
            ),
          ),
        ));
  }
}
