import 'package:flutter/material.dart';

class ExtendedPageController extends PageController {
  ExtendedPageController({
    int initialPage = 0,
    double viewportFraction = 1.0,
    bool keepPage = true,
    double cachedExtent = 9999,
  }) : super(
          initialPage: initialPage,
          viewportFraction: viewportFraction,
          keepPage: keepPage,
        );

  double get cacheExtent => cacheExtent;
}
