import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const appMode = "test";

// var isWeb = false;

// var websiteDomain = isWeb ? "testdemo.vbought.com" : 'Not Provided';
// var url = isWeb ? "https://${websiteDomain}/" : 'Not Provided';
// var socketUrl = "https://studio.vbought.com/";

// var ACCESS_KEY =
//     isWeb ? 'c4144f5a5223976f79ac555d0a95e35f6dd9e34a69e0f935' : 'Not Provided';

var websiteDomain = "shoponline.vbought.com";
var url = "https://${websiteDomain}/";
var socketUrl = "https://studio.vbought.com/";

var ACCESS_KEY = '3220a65ef5a53f06d689f394fd17da90cd04e25fa2c7f073';
// var websiteDomain = "Not Provided";
// var url = "https://${websiteDomain}/";
// var socketUrl = "https://studio.vbought.com/";

// var ACCESS_KEY = 'Not provided';

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
