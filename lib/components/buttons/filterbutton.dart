import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '/constants/constants.dart';

class filterButton extends StatelessWidget {
  filterButton({
    Key? key,
    required this.reset,
    required this.filter,
    required this.pressEvnetReset,
    required this.pressEvnetFilter,
  }) : super(key: key);
  String reset;
  String filter;
  VoidCallback pressEvnetReset;
  VoidCallback pressEvnetFilter;

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
                                style: const TextStyle(
                                  fontFamily: 'lato',
                                )))),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 42,
                    child: ElevatedButton(
                      onPressed: pressEvnetFilter,
                      style: themeButton,
                      child: Text(filter.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Lato')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
