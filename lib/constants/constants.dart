import 'package:flutter/material.dart';

const appMode = "test";

// var url = "http://mern.foduu.com:3044/";
var url = "https://testdemo.foduu.com/";

var socketUrl = "https://studio.foduu.com/";

var ACCESS_KEY = 'c4144f5a5223976f79ac555d0a95e35f6dd9e34a69e0f935';

var assetURL = "${url}images/";
var apiURL = "${url}api/";

bool isOtpLogin = false;

const Latofont = TextStyle(fontFamily: 'lato');

const pageSurroundingPadding = EdgeInsets.all(12.0);
const pageGridPadding = EdgeInsets.symmetric(horizontal: 12.0);

BorderRadiusGeometry themeBorderRadius = BorderRadius.circular(30.0);
ShapeBorder themeShapeBorderRadius =
    RoundedRectangleBorder(borderRadius: themeBorderRadius);

/// ****************** Design Properties ****************** ///
ButtonStyle themeButton = ButtonStyle(
  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(05),
    ),
  ),
  elevation: MaterialStateProperty.all(0),
);
