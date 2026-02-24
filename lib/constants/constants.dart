import 'package:flutter/material.dart';

const appMode = "test";

// var url = "http://mern.foduu.com:3044/";
var websiteDomain = "byonegetonefree.vbought.com";
var url = "https://${websiteDomain}/";
var socketUrl = "https://studio.vbought.com/";

//var ACCESS_KEY = '3220a65ef5a53f06d689f394fd17da90cd04e25fa2c7f073';

// BY ONE GET ONE FREE API KEY
// 53b2b97b6a31dbdc644321261f63bb7be1b251dddc211bbe
var ACCESS_KEY = '53b2b97b6a31dbdc644321261f63bb7be1b251dddc211bbe';

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
