import 'package:flutter/material.dart';
import 'package:foduu_ecommerce/core/config/app_config.dart';

String get appMode => AppConfig.instance.appMode;

String get websiteDomain => AppConfig.instance.websiteDomain;
set websiteDomain(String value) => AppConfig.instance.websiteDomain = value;

String get url => AppConfig.instance.url;
String get socketUrl => AppConfig.instance.socketUrl;
set socketUrl(String value) => AppConfig.instance.socketUrl = value;

String get ACCESS_KEY => AppConfig.instance.accessKey;
set ACCESS_KEY(String value) => AppConfig.instance.accessKey = value;

String get assetURL => AppConfig.instance.assetURL;
String get apiURL => AppConfig.instance.apiURL;

String get appName => AppConfig.instance.appName;
String get supportEmail => AppConfig.instance.supportEmail;
set supportEmail(String value) => AppConfig.instance.supportEmail = value;

String get supportContact => AppConfig.instance.supportContact;
set supportContact(String value) => AppConfig.instance.supportContact = value;

bool get isOtpLogin => AppConfig.instance.isOtpLogin;
set isOtpLogin(bool value) => AppConfig.instance.isOtpLogin = value;

const Latofont = TextStyle(fontFamily: 'lato');

const pageSurroundingPadding = EdgeInsets.all(12.0);
const pageGridPadding = EdgeInsets.symmetric(horizontal: 12.0);

BorderRadiusGeometry get themeBorderRadius => BorderRadius.circular(
      AppConfig.instance.borderRadiusOverride ?? 30.0,
    );

ShapeBorder get themeShapeBorderRadius =>
    RoundedRectangleBorder(borderRadius: themeBorderRadius);

/// ****************** Design Properties ****************** ///
ButtonStyle get themeButton => ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            AppConfig.instance.buttonBorderRadiusOverride ?? 5.0,
          ),
        ),
      ),
      elevation: WidgetStateProperty.all(0),
    );
