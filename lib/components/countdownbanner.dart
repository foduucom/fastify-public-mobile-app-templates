import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../constants/theme_ext.dart';

class countDownBanner extends StatelessWidget {
  const countDownBanner({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 22,
          ),
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: 159,
            decoration: BoxDecoration(color: context.themegreyColor),
            child: Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Denim Wear",
                    style: TextStyle(
                        color: context.themeSecondrytext,
                        fontFamily: 'Poppins',
                        fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text('Sales Starts In',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: context.themeTextColor)),
                  const SizedBox(height: 4),
                  TweenAnimationBuilder<Duration>(
                      duration: Duration(hours: 15),
                      tween:
                          Tween(begin: Duration(hours: 15), end: Duration.zero),
                      onEnd: () {
                        print('Timer ended');
                      },
                      builder: (BuildContext context, Duration value,
                          Widget? child) {
                        final hours = value.inHours;
                        final minutes = value.inMinutes % 60;
                        final seconds = value.inSeconds % 60;
                        return Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: context.themeRedColor),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Hours',
                                      style: TextStyle(
                                          color: context.colors.onPrimary,
                                          fontFamily: 'Poppins',
                                          fontSize: 8),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, right: 4, bottom: 2),
                                      child: Text(
                                        '$hours',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w700,
                                            color: context.colors.onPrimary),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: context.themeRedColor),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Minutes',
                                      style: TextStyle(
                                          color: context.colors.onPrimary,
                                          fontFamily: 'Poppins',
                                          fontSize: 8),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, right: 4, bottom: 2),
                                      child: Text(
                                        '$minutes',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w700,
                                            color: context.colors.onPrimary),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: context.themeRedColor),
                              child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Seconds',
                                      style: TextStyle(
                                          color: context.colors.onPrimary,
                                          fontFamily: 'Poppins',
                                          fontSize: 8),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 4, right: 4, bottom: 2),
                                      child: Text(
                                        '$seconds',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w700,
                                            color: context.colors.onPrimary),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                  const SizedBox(height: 9),
                  Text(
                    'Explore Now',
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: context.themeSecondrytext,
                        decoration: TextDecoration.underline),
                  )
                ],
              ),
            ),
          ),
        ),
        Positioned(
            right: 0,
            child: Image.asset(
              'assets/images/6-2-shopping-transparent.png',
              height: 180,
              fit: BoxFit.contain,
            )),
      ],
    );
  }
}
