import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '/app/modules/auth/auth_details.dart';
import 'package:http/http.dart' as http;

import '../../constants/app_exceptions.dart';
import '../../constants/constants.dart';
import '../../constants/helper_functions.dart';
import 'package:get_storage/get_storage.dart';
// import 'cookie_client_manager.dart';

class BasicProvider {
  final String custom_url;

  BasicProvider(this.custom_url);
  var box = GetStorage();

  String fetchUrl() {
    //print('fetch url === $apiURL + $custom_url');
    return apiURL + custom_url;
  }


  Future<dynamic> getRequest({final queryParams}) async {
    try {
      // final client = CookieClientManager.getClient();

      // Build URL with query parameters
      var uri = Uri.parse(fetchUrl());
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: headerType())
          .timeout(const Duration(seconds: 60));

      //print("get response === $response");

      return _processResponse(response, fetchUrl());
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
    } on UnAuthorizedException {
      // await _refreshToken();
      // return await getRequest(queryParams: queryParams);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<dynamic> postRequest(form) async {
    try {
      // final client = CookieClientManager.getClient();

      final response = await http
          .post(
            Uri.parse(fetchUrl()),
            headers: headerType(),
            body: jsonEncode(form),
          )
          .timeout(const Duration(seconds: 120));

      print('POST API RESONSE ${response.body}');

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
      // await _refreshToken();
      // return await postRequest(form);
    }
  }

  Future<dynamic> patchRequest(form) async {
    try {
      // final client = CookieClientManager.getClient();

      final response = await http
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
      // await _refreshToken();
      // return await patchRequest(form);
    }
  }

  Future<dynamic> deleteRequest() async {
    try {
      // final client = CookieClientManager.getClient();

      final response = await http
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
      // await _refreshToken();
      // return await deleteRequest();
    }
  }

  Map<String, String> headerType() {
    try {
      Map<String, String> userHeader;
      final box   = GetStorage();
      final token = box.read<String>('auth_token') ?? '';

      userHeader = {
        "accept": "application/json",
        'access_key': ACCESS_KEY,
        "Content-Type": "application/json",
        if (token.isNotEmpty)
          'Authorization': 'Bearer $token',
      };

      if (AuthDetails.getToken() != null) {
        userHeader['Authorization'] = 'Bearer ${AuthDetails.getToken()}';
      }

      print('userHeader === $userHeader');
      return userHeader;
    } catch (e) {
      print('post request error $e');
      return {'': ''};
    }
  }

  // Add this method inside BasicProvider class

  Future<dynamic> multipartRequest(
      String method, {
        Map<String, String> fields = const {},
        Map<String, String> files  = const {},   // { fieldName: filePath }
      }) async {
    try {
      final uri     = Uri.parse(fetchUrl());
      final request = http.MultipartRequest(method.toUpperCase(), uri);

      // ── Auth headers (no Content-Type — http sets it automatically) ──
      final box   = GetStorage();
      final token = box.read<String>('auth_token') ?? '';
      request.headers.addAll({
        'accept':     'application/json',
        'access_key': ACCESS_KEY,
        if (token.isNotEmpty) 'Authorization': 'Bearer $token',
      });

      // ── Text fields ──────────────────────────────────────────────
      request.fields.addAll(fields);

      // ── File fields ──────────────────────────────────────────────
      for (final entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(entry.key, entry.value),
        );
      }

      print('📤 multipart [${method.toUpperCase()}] ${fetchUrl()} fields:$fields files:${files.keys}');

      final streamed = await request.send()
          .timeout(const Duration(seconds: 120));
      final response = await http.Response.fromStream(streamed);

      print('POST API RESONSE ${response.body}');

      return _processResponse(response, fetchUrl());
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
    } catch (e) {
      print('multipartRequest error: $e');
    }
  }


  dynamic _processResponse(http.Response response, url) async {
    print('url === $url ${response.statusCode}');
    print('response === ${response.body}');
    if (response.statusCode == null) {
      HelperFunctions()
          .showSnackBarError("No response from server\\n $custom_url");
      return;
    }

    var message = json.decode(response.body)?['data'] ??
        json.decode(response.body)?['message'];

    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body)["data"];
        return responseJson;
      case 201:
        var responseJson = json.decode(response.body)["data"];
        return responseJson;
      case 400:
        throw BadRequestException(message ?? response.request!.url.toString());
      case 401:
        throw UnAuthorizedException(
            message ?? response.request!.url.toString());
      case 403:
        throw UnAuthorizedException(
            message ?? response.request!.url.toString());
      case 404:
        throw BadRequestException(
            message ??
                "Requested URL not exist! ${response.request!.url.toString()}",
            response.request!.url.toString());
      case 409:
        return {
          "access_token": null,
          "message": json.decode(response.body)["data"],
          "status": response.statusCode
        };
      case 422:
        throw BadRequestException(message ?? response.request!.url.toString());
      case 500:
        throw FetchDataException(
            message, response.request!.url.toString(), response.statusCode);
      default:
        if (response.statusCode != null) {
          throw ApiNotRespondingException(
              'Error occured with code : ${response.statusCode ?? "Not able to fetch data"}',
              response.request!.url.toString());
        }
    }
  }
}
