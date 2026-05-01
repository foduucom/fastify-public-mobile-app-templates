import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:get/get.dart';
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
    //print('fetchUrl $apiURL + $custom_url');
    return apiURL + custom_url;
  }

  // Future<void> _refreshToken() async {
  //   try {
  //     final client = CookieClientManager.getClient();
  //     final response = await client.post(
  //       Uri.parse(apiURL + 'auth/customer/refresh'),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'refresh_token':   ?? '',
  //       },
  //       body: jsonEncode({}),
  //     );
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       } else {
  //      }
  //   } catch (e) {
  //     print('Error refreshing token: $e');
  //     await TokenManager.clearTokens();
  //   }
  // }

  Future<dynamic> getRequest({final queryParams}) async {
    try {
      // final client = CookieClientManager.getClient();

      // Build URL with query parameters
      var uri = Uri.parse(fetchUrl());
      //print("Uri Get Request $uri");
      if (queryParams != null) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: headerType())
          .timeout(const Duration(seconds: 60));
      // CRITICAL: Print the RAW response body
      // print('RAW RESPONSE BODY: ${response.body}');
      // print('RESPONSE STATUS: ${response.statusCode}');

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
      if (form is FormData) {
        var request = http.MultipartRequest('POST', Uri.parse(fetchUrl()));
        request.headers.addAll(headerType(isMultipart: true));

        // Add fields
        form.fields.forEach((field) {
          request.fields[field.key] = field.value;
        });

        // Add files
        for (var file in form.files) {
          request.files.add(http.MultipartFile(
            file.key,
            file.value.stream!,
            file.value.length ?? 0,
            filename: file.value.filename,
          ));
        }

        final streamedResponse =
            await request.send().timeout(const Duration(seconds: 120));
        final response = await http.Response.fromStream(streamedResponse);

        return _processResponse(response, fetchUrl());
      }

      final response = await http
          .post(
            Uri.parse(fetchUrl()),
            headers: headerType(),
            body: jsonEncode(form),
          )
          .timeout(const Duration(seconds: 120));

      //print('POST API RESONSE ${response.body}');

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
            body: '{}',
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

  Map<String, String> headerType({bool isMultipart = false}) {
    try {
      Map<String, String> userHeader;

      userHeader = {
        "accept": "application/json",
        'access_key': ACCESS_KEY,
      };

      if (!isMultipart) {
        userHeader["Content-Type"] = "application/json";
      }

      if (AuthDetails.getToken() != null) {
        userHeader['Authorization'] = 'Bearer ${AuthDetails.getToken()}';
      }

      print("userHeader: $userHeader");

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
          .showSnackBarError("No response from server\n $custom_url");
      return;
    }

    var decodedBody = json.decode(response.body);
    print('Decoded body: $decodedBody');

    var message = decodedBody['data'] ?? decodedBody['message'];

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('━━━━━━━━━━━━━━━ API ERROR ━━━━━━━━━━━━━━━');
      print('URL: $url');
      print('STATUS: ${response.statusCode}');
      print('MESSAGE: $message');
      print('BODY: ${response.body}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    switch (response.statusCode) {
      case 200:
        var decoded = json.decode(response.body);
        var responseJson = decoded["data"];
        print("━━━━━━━━━━━━━━━ API SUCCESS ━━━━━━━━━━━━━━━");
        print("URL: $url");
        print("RESPONSE JSON: $responseJson");
        if (responseJson == null) {
          print("WARNING: Data is NULL but status is 200 SUCCESS");
        }
        print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
        return responseJson;
      case 201:
        var responseJson = json.decode(response.body)["data"];
        return responseJson;
      case 400:
        throw BadRequestException(
            message?.toString() ?? response.request!.url.toString(),
            response.request!.url.toString());
      case 401:
        throw UnAuthorizedException(
            message?.toString() ?? response.request!.url.toString(),
            response.request!.url.toString());
      case 403:
        throw UnAuthorizedException(
            message?.toString() ?? response.request!.url.toString(),
            response.request!.url.toString());
      case 404:
        throw BadRequestException(
            message?.toString() ??
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
            message?.toString() ?? response.request!.url.toString(),
            response.request!.url.toString());
      case 500:
        throw FetchDataException(message?.toString(),
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
