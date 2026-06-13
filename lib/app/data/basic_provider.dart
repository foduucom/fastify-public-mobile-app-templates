import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:get/get.dart' as get_x;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../constants/app_exceptions.dart';
import '../../constants/constants.dart';
import '../../constants/helper_functions.dart';
import 'package:get_storage/get_storage.dart';

class BasicProvider {
  final String custom_url;

  BasicProvider(this.custom_url);
  var box = GetStorage();

  String fetchUrl() {
    return apiURL + custom_url;
  }

  Future<dynamic> getRequest({final queryParams}) async {
    try {
      var uri = Uri.parse(fetchUrl());
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: headerType())
          .timeout(const Duration(seconds: 60));

      return _processResponse(response, fetchUrl());
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw "No internet connection!";
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw "Timeout : API is not responding!";
    } on UnAuthorizedException {
      rethrow;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  Future<dynamic> postRequest(form) async {
    form ??= {};
    try {
      http.Response response;
      if (form is get_x.FormData) {
        print("Detected FormData, sending MultipartRequest to: ${fetchUrl()}");
        var request = http.MultipartRequest('POST', Uri.parse(fetchUrl()));

        // Add headers
        Map<String, String> headers = headerType();
        headers
            .removeWhere((key, value) => key.toLowerCase() == 'content-type');
        request.headers.addAll(headers);
        print("MultipartRequest final headers: ${request.headers}");

        // Add fields
        for (var field in form.fields) {
          request.fields[field.key] = field.value;
        }

        // Add files
        for (var file in form.files) {
          get_x.MultipartFile getFile = file.value;
          if (getFile.stream != null) {
            request.files.add(http.MultipartFile(
              file.key,
              getFile.stream!,
              getFile.length ?? 0,
              filename: getFile.filename,
              contentType: getFile.contentType != null
                  ? MediaType.parse(getFile.contentType!)
                  : null,
            ));
          } else {
            print(
                "Warning: MultipartFile stream is null for field: ${file.key}");
          }
        }

        var streamedResponse =
            await request.send().timeout(const Duration(seconds: 120));
        response = await http.Response.fromStream(streamedResponse);
      } else {
        response = await http
            .post(
              Uri.parse(fetchUrl()),
              headers: headerType(),
              body: jsonEncode(form),
            )
            .timeout(const Duration(seconds: 120));
      }

      // print('POST API RESPONSE ${response.body}');

      return _processResponse(response, fetchUrl());
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw "No internet connection!";
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw "Timeout : API is not responding!";
    } on UnAuthorizedException {
      throw "Unauthorized!";
    } catch (e) {
      print("POST request failed with error: $e");
      rethrow;
    }
  }

  Future<dynamic> patchRequest(form) async {
    form ??= {};
    try {
      final response = await http
          .patch(
            Uri.parse(fetchUrl()),
            headers: headerType(),
            body: jsonEncode(form),
          )
          .timeout(const Duration(seconds: 120));

      return _processResponse(response, fetchUrl());
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw "No internet connection!";
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw "Timeout : API is not responding!";
    } on UnAuthorizedException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> deleteRequest() async {
    try {
      final response = await http
          .delete(
            Uri.parse(fetchUrl()),
            headers: headerType(),
          )
          .timeout(const Duration(seconds: 60));

      return _processResponse(response, fetchUrl());
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw "No internet connection!";
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw "Timeout : API is not responding!";
    } on UnAuthorizedException {
      rethrow;
    } catch (e) {
      rethrow;
    }
  }

  Map<String, String> headerType() {
    try {
      Map<String, String> userHeader;

      userHeader = {
        "accept": "application/json",
        'access-key': ACCESS_KEY,
        "Content-Type": "application/json",
      };

      if (AuthDetails.getToken() != null) {
        userHeader['Authorization'] = 'Bearer ${AuthDetails.getToken()}';
      }

      print("headers: $userHeader");
      return userHeader;
    } catch (e) {
      print('header error $e');
      return {'': ''};
    }
  }

  dynamic _processResponse(http.Response response, url) {
    print('url === $url ${response.statusCode}');
    // print('response === ${response.body}');

    var responseBody;
    try {
      responseBody = json.decode(response.body);
    } catch (e) {
      print("JSON decode error: $e");
    }

    var message = responseBody?['data'] ?? responseBody?['message'];

    switch (response.statusCode) {
      case 200:
      case 201:
        // If data is missing but message exists, return message or success
        return responseBody["data"] ?? responseBody;
      case 400:
        throw BadRequestException(message ?? response.request!.url.toString());
      case 401:
      case 403:
        throw UnAuthorizedException(
            message ?? response.request!.url.toString());
      case 404:
        throw BadRequestException(message ?? "Requested URL does not exist!",
            response.request!.url.toString());
      case 409:
        return {
          "access_token": null,
          "message": responseBody["data"],
          "status": response.statusCode
        };
      case 422:
        throw BadRequestException(message ?? response.request!.url.toString());
      case 500:
        throw FetchDataException(
            message, response.request!.url.toString(), response.statusCode);
      default:
        throw ApiNotRespondingException(
            'Error occurred with code : ${response.statusCode}',
            response.request!.url.toString());
    }
  }
}
