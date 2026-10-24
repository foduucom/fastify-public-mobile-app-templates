import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';

const appMode = "protu";

// var url = "http://mern.foduu.com:3016/";
var url = "https://vision.foduu.store/";
// var url = 'https://api.protuffnutri.com/';

var assetURL = "${url}images/";
var apiURL = "${url}api/";
var vendorapiURL = "${url}vendorapi/";
var razorPayKey = "";

//var accessToken = "f654e0a9ed1f267915a55b950a579ad47d281f74d7fd4cd6";
var accessToken = "c50c0c1258bb25df3082b9053e7b3bc0ab5fcf96a0d78a04";
var websiteDomain = "vision.foduu.store";
var socketUrl = "https://studio.foduu.store/";
var ACCESS_KEY = "c50c0c1258bb25df3082b9053e7b3bc0ab5fcf96a0d78a04";

bool isOtpLogin = false;

/// Symbol of the app's single currency (empty until it has loaded).
String get currency => Get.isRegistered<CurrencyController>()
    ? Get.find<CurrencyController>().symbol
    : '';
const String appName = 'Vision Infrastructure';
String supportEmail = "support@vbought.com";
String supportContact = "1-800-570-7777";

String discountPercent = "15";

// Font family matches the parent site (vision.vbought.com): Poppins.
const Latofont = TextStyle(fontFamily: 'Poppins');

// Brand palette — values taken from the parent site's stylesheet
// (--v-primary, --v-text-dark, --v-body-bg, ...).
const themePrimaryColor = Color(0xFF20558A);
const themePrimaryDark = Color(0xFF18426D);
const themePrimaryLight = Color(0xFFEEF4F9);
const themeBackground = Color(0xFFF4F8FB);
const themeAccentOrange = Color(0xFFFFFFFF); // legacy name: plain white
const themegradient = [
  Color(0xFF20558A),
  Color(0xFF18426D),
];

const themeSecondryColor = Color(0xFF16324F); // deep navy
const themeTextColor = Color(0xFF1E293B);
const themeHeadingColor = Color(0xFF0F172A);
const themeSecondrytext = Color(0xFF64748B);
const themegreyColor = Color(0xFFF1F5F9);
const themeBorderColor = Color(0xFFE2E8F0);
const themetitleColor = Color(0xFF1E293B);

//theme specific colors
const themePurpleColor = Color(0xFF6b77ef);
const themeRedColor = Color(0xFFDD4B39); // sale / error
const themeYellowColor = Color(0xFFFFA800); // stars / warning
const themeSkyBlueColor = Color(0xFF00ADEF);
const themeBlueColor = Color(0xFF20558A);
const themeGreenColor = Color(0xFF3C8A38); // success
const themeTealColor = Color(0xFF00BAA3);
const themeWhiteColor = Colors.white;
const themeCardColor = Colors.white;
var colorwithopacity = const Color(0xFFCBD5E1).withOpacity(0.65);

// Card shadows from the parent site (--v-shadow, --v-shadow-hover).
const cardShadow = [
  BoxShadow(color: Color(0x0F000000), blurRadius: 20, offset: Offset(0, 4)),
];
const cardShadowHover = [
  BoxShadow(color: Color(0x2E20558A), blurRadius: 25, offset: Offset(0, 10)),
];

const themeAnimationDuration = Duration(milliseconds: 200);

const pageSurroundingPadding = EdgeInsets.all(12.0);
const pageGridPadding = EdgeInsets.symmetric(horizontal: 12.0);

const double themeBorderRadiusValue = 16.0;
const double themeButtonRadius = 8.0;
const double themeButtonHeight = 48.0;

BorderRadiusGeometry themeBorderRadius =
    BorderRadius.circular(themeBorderRadiusValue);
ShapeBorder themeShapeBorderRadius = RoundedRectangleBorder(
  borderRadius: themeBorderRadius,
);

/// ****************** Design Properties ****************** ///
ButtonStyle themeButton = ButtonStyle(
  shape: WidgetStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(themeButtonRadius)),
  ),
  textStyle: WidgetStateProperty.all<TextStyle>(
    const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w600,
      fontFamily: 'Poppins',
    ),
  ),
  backgroundColor: WidgetStateProperty.all(themePrimaryColor),
  elevation: WidgetStateProperty.all(0),
  minimumSize: WidgetStateProperty.all(Size.zero),
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
);

String environment = 'SANDBOX';
String saltKey = '099eb0cd-02cf-4e2a-8aca-3e6c6aff0399';
String merchantId = 'PGTESTPAYUAT';
String saltIndex = '1';
String appId = '';
String callBackUrl = '';
