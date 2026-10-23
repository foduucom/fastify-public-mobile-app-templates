import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/theme_ext.dart';

class filterButton extends StatelessWidget {
  filterButton({
    Key? key,
    required this.reset,
    required this.filter,
    required this.pressEvnetReset,
    required this.pressEvnetFilter,
    this.isEnabled = true,
  }) : super(key: key);
  String reset;
  String filter;
  VoidCallback pressEvnetReset;
  VoidCallback? pressEvnetFilter;
  bool isEnabled;

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 0,
        child: Material(
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  InkWell(
                    onTap: pressEvnetReset,
                    child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        height: 42,
                        child: Center(
                            child: Text(reset.toUpperCase(),
                                style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: context.themeTextColor)))),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: isEnabled ? pressEvnetFilter : null,
                      style: isEnabled
                          ? themeButton
                          : ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(05)),
                              ),
                              backgroundColor: MaterialStateProperty.all(
                                  context.themegreyColor),
                              elevation: MaterialStateProperty.all(0),
                            ),
                      child: Text(filter.toUpperCase(),
                          style: TextStyle(
                              color: context.colors.onPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Poppins')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
