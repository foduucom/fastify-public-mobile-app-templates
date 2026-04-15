import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const appMode = "test";

// var isWeb = false;

// var websiteDomain = isWeb ? "testdemo.vbought.com" : 'Not Provided';
// var url = isWeb ? "https://${websiteDomain}/" : 'Not Provided';
// var socketUrl = "https://studio.vbought.com/";

// var ACCESS_KEY =
//     isWeb ? 'c4144f5a5223976f79ac555d0a95e35f6dd9e34a69e0f935' : 'Not Provided';

// var websiteDomain = "mywatch.vbought.com";
// var url = "https://${websiteDomain}/";
// var socketUrl = "https://studio.vbought.com/";

// ZOOHI websiteDomain
var websiteDomain = "zouhi.vbought.com";
var url = "https://${websiteDomain}/";
var socketUrl = "https://studio.vbought.com/";

// var ACCESS_KEY = '72a5a13ab02a20737217279980c33374f41554ec60742815';

// ZOOHI ACCESS Key
var ACCESS_KEY = '51830a0444c7859cd3df935095fe17dc2c4f0e45bf722d90';

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
