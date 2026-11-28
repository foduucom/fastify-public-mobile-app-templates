import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zouhi/app/controllers/currency_controller.dart';
import 'package:zouhi/core/config/app_config.dart';

String get appMode => AppConfig.instance.appMode;

String get url => AppConfig.instance.url;
String get assetURL => AppConfig.instance.assetURL;
String get apiURL => AppConfig.instance.apiURL;
String get vendorapiURL => AppConfig.instance.vendorapiURL;
var razorPayKey = "";

String get accessToken => AppConfig.instance.accessKey;
set accessToken(String value) => AppConfig.instance.accessKey = value;

String get websiteDomain => AppConfig.instance.websiteDomain;
set websiteDomain(String value) => AppConfig.instance.websiteDomain = value;

String get socketUrl => AppConfig.instance.socketUrl;
set socketUrl(String value) => AppConfig.instance.socketUrl = value;

String get ACCESS_KEY => AppConfig.instance.accessKey;
set ACCESS_KEY(String value) => AppConfig.instance.accessKey = value;

bool get isOtpLogin => AppConfig.instance.isOtpLogin;
set isOtpLogin(bool value) => AppConfig.instance.isOtpLogin = value;

/// Symbol of the app's single currency (empty until it has loaded).
String get currency => Get.isRegistered<CurrencyController>()
    ? Get.find<CurrencyController>().symbol
    : '';
String get appName => AppConfig.instance.appName;
String get supportEmail => AppConfig.instance.supportEmail;
set supportEmail(String value) => AppConfig.instance.supportEmail = value;

String get supportContact => AppConfig.instance.supportContact;
set supportContact(String value) => AppConfig.instance.supportContact = value;

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

BorderRadiusGeometry get themeBorderRadius => BorderRadius.circular(
      AppConfig.instance.borderRadiusOverride ?? themeBorderRadiusValue,
    );
ShapeBorder get themeShapeBorderRadius => RoundedRectangleBorder(
      borderRadius: themeBorderRadius,
    );

/// ****************** Design Properties ****************** ///
ButtonStyle get themeButton => ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                AppConfig.instance.buttonBorderRadiusOverride ??
                    themeButtonRadius)),
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
