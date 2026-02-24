import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:foduu_ecommerce/constants/internet_controller.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:http/http.dart' as http;

import '../modules/auth/token_manager.dart';
import '../../constants/app_exceptions.dart';
import '../../constants/constants.dart';
import '../../constants/helper_functions.dart';
import 'package:get_storage/get_storage.dart';
import 'cookie_client_manager.dart';

class BasicProvider {
  final String custom_url;

  BasicProvider(this.custom_url);
  var box = GetStorage();

  String fetchUrl() {
    return apiURL + custom_url;
  }

  Future<void> _refreshToken() async {
    String? refreshToken = TokenManager.refreshToken;

    try {
      final client = CookieClientManager.getClient();
      final response = await client.post(
        Uri.parse(apiURL + 'auth/customer/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'refresh_token': refreshToken ?? '',
        },
        body: jsonEncode({}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await TokenManager.setAccessToken(data['access_token']);
        await TokenManager.setRefreshToken(data['refresh_token']);
      } else {
        await TokenManager.clearTokens();
      }
    } catch (e) {
      print('Error refreshing token: $e');
      await TokenManager.clearTokens();
    }
  }

  Future<dynamic> getRequest({final queryParams}) async {
    // Check internet before making request
    if (!Get.find<InternetController>().isInternet.value) {
      // Don't make API call if no internet
      return null;
    }

    try {
      final client = CookieClientManager.getClient();

      print('Request headers: ${headerType()}'); // This will show auth tokens

      // Build URL with query parameters
      var uri = Uri.parse(fetchUrl());
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await client
          .get(uri, headers: headerType())
          .timeout(const Duration(seconds: 60));

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      return _processResponse(response, fetchUrl());
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
    } on UnAuthorizedException {
      await _refreshToken();
      return await getRequest(queryParams: queryParams);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> postRequest(form) async {
    // Check internet before making request
    if (!Get.find<InternetController>().isInternet.value) {
      return null;
    }

    print('Request headers: ${headerType()}'); // This will show auth tokens
    print('Request body: ${jsonEncode(form)}');
    print('Request url: ${fetchUrl()}');

    try {
      final client = CookieClientManager.getClient();

      final response = await client
          .post(
            Uri.parse(fetchUrl()),
            headers: headerType(),
            body: jsonEncode(form),
          )
          .timeout(const Duration(seconds: 120));

      return _processResponse(response, fetchUrl());
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw Future.error("No internet connection!");
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw Future.error("Timeout : API is not responding!");
    } on UnAuthorizedException {
      await _refreshToken();
      return await postRequest(form);
    }
  }

  Future<dynamic> patchRequest(form) async {
    // Check internet before making request
    if (!Get.find<InternetController>().isInternet.value) {
      return null;
    }

    try {
      final client = CookieClientManager.getClient();

      final response = await client
          .patch(
            Uri.parse(fetchUrl()),
            headers: headerType(),
            body: jsonEncode(form),
          )
          .timeout(Duration(seconds: 120));

      return _processResponse(response, fetchUrl());
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw Future.error("No internet connection!");
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw Future.error("Timeout : API is not responding!");
    } on UnAuthorizedException {
      await _refreshToken();
      return await patchRequest(form);
    }
  }

  Future<dynamic> deleteRequest() async {
    // Check internet before making request
    if (!Get.find<InternetController>().isInternet.value) {
      return null;
    }

    try {
      final client = CookieClientManager.getClient();

      final response = await client
          .delete(
            Uri.parse(fetchUrl()),
            headers: headerType(),
          )
          .timeout(Duration(seconds: 60));

      return _processResponse(response, fetchUrl());
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw Future.error("No internet connection!");
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw Future.error("Timeout : API is not responding!");
    } on UnAuthorizedException {
      await _refreshToken();
      return await deleteRequest();
    }
  }

  Map<String, String> headerType() {
    try {
      Map<String, String> userHeader;

      userHeader = {
        "accept": "application/json",
        'access_key': ACCESS_KEY,
        "Content-Type": "application/json",
      };

      return userHeader;
    } catch (e) {
      print('post request error $e');
      return {'': ''};
    }
  }

  dynamic _processResponse(http.Response response, url) async {
    print('url === $url ${response.statusCode}');

    if (response.statusCode == null) {
      HelperFunctions()
          .showSnackBarError("No response from server\\n $custom_url");
      return;
    }

    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body)["data"];
        return responseJson;
      case 201:
        var responseJson = json.decode(response.body)["data"];
        return responseJson;
      case 400:
        throw BadRequestException(
            json.decode(response.body), response.request!.url.toString());
      case 401:
        throw UnAuthorizedException(json.decode(response.body)["message"],
            response.request!.url.toString());
      case 403:
        throw UnAuthorizedException(json.decode(response.body)["message"],
            response.request!.url.toString());
      case 404:
        throw BadRequestException(
            "Requested URL not exist! ${response.request!.url.toString()}",
            response.request!.url.toString());
      case 409:
        return {
          "access_token": null,
          "message": json.decode(response.body)["data"],
          "status": response.statusCode
        };
      case 422:
        throw BadRequestException(
            json.decode(response.body), response.request!.url.toString());
      case 500:
        var body = json.decode(response.body);
        throw FetchDataException(body["data"] ?? body["message"],
            response.request!.url.toString(), response.statusCode);
      default:
        if (response.statusCode != null) {
          throw ApiNotRespondingException(
              'Error occured with code : ${response.statusCode ?? "Not able to fetch data"}',
              response.request!.url.toString());
        }
    }
  }
}
