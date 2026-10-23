import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:zouhi/app/data/services/session_service.dart';
import 'package:zouhi/app/modules/auth/auth_details.dart';
import 'package:zouhi/app/modules/auth/token_manager.dart';
import 'package:zouhi/constants/app_exceptions.dart';
import 'package:zouhi/constants/constants.dart';
import 'package:zouhi/constants/helper_functions.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Why the last [BasicProvider.getRequest] returned null. Lets callers tell a
/// real connectivity problem apart from a transient server/refresh failure
/// instead of showing "No internet" for everything.
enum RequestFailure { none, offline, guestSkipped, transient }

class BasicProvider extends GetConnect {
  final String custom_url;
  final bool showSnackBar;

  /// Set by [getRequest]; [RequestFailure.none] when a response was obtained.
  RequestFailure lastFailure = RequestFailure.none;

  BasicProvider(this.custom_url, {this.showSnackBar = true});
  var box = GetStorage();

  String fetchUrl() {
    if (kDebugMode) debugPrint("fetchUrl: ${apiURL + custom_url}");
    return apiURL + custom_url;
  }

  /// Endpoints that only make sense for a logged-in user. Guests (skip mode)
  /// would just get a 401, so GETs to these are skipped client-side.
  static const _loginOnlyPrefixes = [
    "auth/customer/profile",
    "wishlist",
    "coupons",
  ];

  // "order" (the history list) only; "order/<id>" may be used by guest checkout.
  bool get _requiresLogin =>
      custom_url == "order" ||
      _loginOnlyPrefixes.any((p) => custom_url.startsWith(p));

  static Future<void>? _refreshInFlight;

  /// Single-flight token refresh: concurrent 401s share one refresh call.
  ///
  /// Only a definitive rejection (no refresh token, or 400/401/403 from the
  /// refresh endpoint) ends the session. Network errors, timeouts and 5xx are
  /// transient: tokens are kept and a [FetchDataException] is thrown.
  /// With [silent] the global expiry flow (logout + redirect) is not run.
  static Future<void> refreshSession({bool silent = false}) {
    return _refreshInFlight ??= _doRefresh(silent: silent).whenComplete(() {
      _refreshInFlight = null;
    });
  }

  static Future<void> _expireSession(String message, {required bool silent}) async {
    if (!silent) await SessionService.expire();
    throw UnAuthorizedException(message, apiURL + "auth/customer/refresh");
  }

  static Future<void> _doRefresh({required bool silent}) async {
    // Guests (skip mode) have no session to refresh or expire.
    if (!AuthDetails.isUserLogin()) {
      throw UnAuthorizedException(
          "Not logged in", apiURL + "auth/customer/refresh");
    }

    final refreshToken = TokenManager.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await _expireSession("No refresh token available", silent: silent);
        return;
    }

    final refreshUrl = apiURL + "auth/customer/refresh";
    try {
      final client = GetConnect()..httpClient.timeout = const Duration(seconds: 30);
      final response = await client.post(refreshUrl, {}, headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'access-key': accessToken,
        'access_key': accessToken,
        'refresh_token': refreshToken,
      });

      final status = response.statusCode;
      if (status == 200) {
        var data = response.body;
        if (data is String) data = json.decode(data);
        await TokenManager.setAccessToken(data['access_token']);
        await TokenManager.setRefreshToken(data['refresh_token']);
        return;
      }
      if (status == 400 || status == 401 || status == 403) {
        await _expireSession("Session expired", silent: silent);
        return;
      }
      // null (offline/timeout), 5xx, 429...: transient, keep the session.
      throw FetchDataException(
          "Unable to refresh session right now. Please try again.",
          refreshUrl,
          status);
    } on SocketException {
      throw FetchDataException(
          "Connection error during session refresh.", refreshUrl, null);
    } on TimeoutException {
      throw FetchDataException(
          "Timeout error during session refresh.", refreshUrl, null);
    } catch (e) {
      if (e is AppException) rethrow;
      throw FetchDataException(
          "Unexpected error during session refresh: $e", refreshUrl, null);
    }
  }

  /// Refreshes the access token ahead of time when its JWT `exp` has passed,
  /// so the request below doesn't have to fail with a 401 first. Transient
  /// failures are ignored (the 401 path remains the source of truth); a
  /// definitive rejection tears the session down via [SessionService.expire].
  Future<void> _ensureFreshToken() async {
    if (!AuthDetails.isUserLogin()) return;
    if (custom_url.startsWith("auth/customer/refresh")) return;
    final refresh = TokenManager.refreshToken;
    if (refresh == null || refresh.isEmpty) return;
    if (!TokenManager.isAccessTokenExpired()) return;
    try {
      await refreshSession();
    } on UnAuthorizedException {
      rethrow;
    } catch (_) {}
  }

  /// Refreshes the session after a 401. Returns true when the request should
  /// be retried; false when the refresh failed transiently (error surfaced).
  /// Rethrows [UnAuthorizedException] when the session is really over.
  Future<bool> _refreshForRetry({bool? showSnackBar}) async {
    final effectiveShowSnackBar = showSnackBar ?? this.showSnackBar;
    try {
      await refreshSession();
      return true;
    } on UnAuthorizedException {
      rethrow;
    } catch (e) {
      if (effectiveShowSnackBar) {
        HelperFunctions().showSnackBarError(errorMessageOf(e));
      }
      return false;
    }
  }

  Future<dynamic> getRequest({
    final queryParams,
    bool isRetry = false,
    bool? showSnackBar,
  }) async {
    final effectiveShowSnackBar = showSnackBar ?? this.showSnackBar;
    lastFailure = RequestFailure.none;
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        lastFailure = RequestFailure.offline;
        return null;
      }

      // Skip login-only endpoints for guests (Skip Mode) to prevent 401s.
      if (_requiresLogin && !AuthDetails.isUserLogin()) {
        lastFailure = RequestFailure.guestSkipped;
        return null;
      }

      if (!isRetry) await _ensureFreshToken();

      httpClient.timeout = const Duration(seconds: 60);
      final response = await get(fetchUrl(),
              contentType: "application/json",
              headers: headerType(),
              query: queryParams)
          .catchError((error, stackTrace) {
        if (effectiveShowSnackBar) {
          HelperFunctions().showSnackBarError(error);
        }
      });

      return _processResponse(response, showSnackBar: effectiveShowSnackBar);
    } on SocketException {
      lastFailure = RequestFailure.offline;
      if (effectiveShowSnackBar) {
        HelperFunctions().showSnackBarError(
            "Please check if your internet connection is stable!");
      }
    } on TimeoutException {
      lastFailure = RequestFailure.transient;
      if (effectiveShowSnackBar) {
        HelperFunctions().showSnackBarError(
            "Please check if your internet connection is stable!");
      }
    } on UnAuthorizedException {
      if (isRetry) rethrow;
      if (!await _refreshForRetry(showSnackBar: effectiveShowSnackBar)) {
        lastFailure = RequestFailure.transient;
        return null;
      }
      return await getRequest(
        queryParams: queryParams,
        isRetry: true,
        showSnackBar: effectiveShowSnackBar,
      );
    } catch (e) {
      lastFailure = RequestFailure.transient;
      print(e.toString());
      if (effectiveShowSnackBar) {
        HelperFunctions().showSnackBarError(errorMessageOf(e));
      }
    }
  }

  Future<dynamic> postRequest(form, {bool isRetry = false}) async {
    form ??= {};
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw "No internet connection!";
      }

      // Short-circuit profile updates if user is not logged in
      if (custom_url.startsWith("auth/customer/profile") &&
          !AuthDetails.isUserLogin()) {
        return null;
      }

      httpClient.timeout = const Duration(seconds: 120);

      Response response;

      if (form is FormData) {
        response = await post(
          fetchUrl(),
          form,
          headers: headerType(isFormData: true),
        );
      } else {
        response = await post(
          fetchUrl(),
          form,
          contentType: "application/json",
          headers: headerType(),
        );
      }
      // print('Post Response Status ${response.status}');
      // print('POST API RESPONSE ${response.body}');

      return _processResponse(response);
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw "No internet connection!";
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw "Timeout : API is not responding!";
    } on UnAuthorizedException {
      if (isRetry) rethrow;
      if (!await _refreshForRetry()) return null;
      return await postRequest(form, isRetry: true);
    } catch (e) {
      print("POST request failed with error: $e");
      rethrow;
    }
  }

  Future<dynamic> patchRequest(form, {bool isRetry = false}) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Future.error("No internet connection!");
      }

      httpClient.timeout = Duration(seconds: 120);
      final bool isFormData = form is FormData;
      final response = await patch(
        fetchUrl(),
        form,
        contentType: isFormData ? null : "application/json",
        headers: headerType(isFormData: isFormData),
      );
      return _processResponse(response);
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw Future.error("No internet connection!");
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw Future.error("Timeout : API is not responding!");
    } on UnAuthorizedException {
      if (isRetry) rethrow;
      if (!await _refreshForRetry()) return null;
      return await patchRequest(form, isRetry: true);
    }
  }

  Future<dynamic> deleteRequest({dynamic body, bool isRetry = false}) async {
    httpClient.timeout = const Duration(seconds: 60);
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Future.error("No internet connection!");
      }

      final response = await request(
        fetchUrl(),
        'DELETE',
        headers: headerType(),
        body: body ?? {},
      );
      return _processResponse(response);
    } on SocketException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw Future.error("No internet connection!");
    } on TimeoutException {
      HelperFunctions().showSnackBarError(
          "Please check if your internet connection is stable!");
      throw Future.error("Timeout : API is not responding!");
    } on UnAuthorizedException {
      if (isRetry) rethrow;
      if (!await _refreshForRetry()) return null;
      return await deleteRequest(body: body, isRetry: true);
    }
  }

  Map<String, String> headerType({bool isFormData = false}) {
    try {
      Map<String, String> userHeader = {
        "Accept": "application/json",
        "access-key": accessToken,
        "access_key": accessToken,
      };

      if (!isFormData) {
        userHeader["Content-Type"] = "application/json";
      }

      if (AuthDetails.isUserLogin()) {
        var userToken = TokenManager.accessToken;
        if (userToken != null && userToken.isNotEmpty) {
          userHeader["Authorization"] = "Bearer $userToken";
        }
      }
      return userHeader;
    } catch (e) {
      print('headerType error $e');
      return {
        "Accept": "application/json",
        "access-key": accessToken,
        "access_key": accessToken,
      };
    }
  }

  String _errorMessage(dynamic body) {
    if (body == null) return "Unknown error";
    if (body is String) {
      if (body.trim().isEmpty) return "Unknown error";
      try {
        final decoded = json.decode(body);
        if (decoded is Map || decoded is List) {
          return _errorMessage(decoded);
        }
      } catch (_) {}
      return body;
    }
    if (body is Map) {
      // 1. Check if 'errors' contains field validation errors (e.g. {"email": ["The email has already been taken."]})
      if (body.containsKey("errors") && body["errors"] != null) {
        final errors = body["errors"];
        if (errors is Map && errors.isNotEmpty) {
          final firstVal = errors.values.first;
          if (firstVal is List && firstVal.isNotEmpty) {
            return firstVal.first.toString();
          }
          if (firstVal != null) return firstVal.toString();
        } else if (errors is List && errors.isNotEmpty) {
          final firstItem = errors.first;
          if (firstItem is Map && firstItem.containsKey("message")) {
            return firstItem["message"].toString();
          }
          return firstItem.toString();
        } else if (errors is String && errors.trim().isNotEmpty) {
          return errors;
        }
      }

      // 2. Check if 'data' is a string or an error object
      if (body.containsKey("data") && body["data"] != null) {
        final data = body["data"];
        if (data is String && data.trim().isNotEmpty) {
          return data;
        } else if (data is Map && data.isNotEmpty) {
          final firstVal = data.values.first;
          if (firstVal is List && firstVal.isNotEmpty) {
            return firstVal.first.toString();
          }
          if (firstVal != null) return firstVal.toString();
        } else if (data is List && data.isNotEmpty) {
          return data.first.toString();
        }
      }

      // 3. Check if 'message' is a string
      if (body.containsKey("message") && body["message"] != null) {
        final message = body["message"];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }

      // 4. Check if 'error' is a string
      if (body.containsKey("error") && body["error"] != null) {
        final error = body["error"];
        if (error is String && error.trim().isNotEmpty) {
          return error;
        }
      }

      return body.toString();
    }
    if (body is List && body.isNotEmpty) {
      return _errorMessage(body.first);
    }
    return body.toString();
  }

  dynamic _processResponse(response, {bool? showSnackBar}) async {
    final effectiveShowSnackBar = showSnackBar ?? this.showSnackBar;
    if (response == null || response.statusCode == null) {
      if (response != null && effectiveShowSnackBar) {
        final statusText = response.statusText.toString();
        if (statusText.contains("SocketException") ||
            statusText.contains("unreachable")) {
          HelperFunctions().showSnackBarError(
              "Unable to connect. Please check your internet connection.");
        } else if (statusText.contains("TimeoutException") ||
            statusText.contains("timeout")) {
          HelperFunctions()
              .showSnackBarError("Connection timed out. Please try again later.");
        } else {
          HelperFunctions()
              .showSnackBarError("Connection error. Please try again.");
        }
      }
      return null;
    }

    if (response.statusCode != null &&
        (response.statusCode! < 200 || response.statusCode! >= 300)) {
      debugPrint(
          'API Error [${response.statusCode}] on ${response.request?.url}: ${response.body}');
    }

    switch (response.statusCode) {
      case 200:
        var body = response.body;
        if (body is String) {
          try {
            body = json.decode(body);
          } catch (_) {}
        }
        if (body is Map && body['status'] == 'error') {
          throw BadRequestException(
              body['data']?.toString() ??
                  body['message']?.toString() ??
                  'Error',
              response.request!.url.toString());
        }
        var responseJson =
            (body is Map && body.containsKey("data")) ? body["data"] : body;
        return responseJson;
      case 201:
        var body = response.body;
        if (body is String) {
          try {
            body = json.decode(body);
          } catch (_) {}
        }
        if (body is Map && body['status'] == 'error') {
          throw BadRequestException(
              body['data']?.toString() ??
                  body['message']?.toString() ??
                  'Error',
              response.request!.url.toString());
        }
        var responseJson =
            (body is Map && body.containsKey("data")) ? body["data"] : body;

        return responseJson;
      case 400:
        throw BadRequestException(
            _errorMessage(response.body), response.request!.url.toString());
      case 401:
        throw UnAuthorizedException(
            _errorMessage(response.body), response.request!.url.toString());
      case 403:
        throw UnAuthorizedException(
            _errorMessage(response.body), response.request!.url.toString());
      case 404:
        final msg = _errorMessage(response.body);
        final isGeneric404 = msg.isEmpty ||
            msg == "Unknown error" ||
            msg.contains("Cannot POST") ||
            msg.contains("Cannot GET") ||
            msg.contains("404");
        throw BadRequestException(
            isGeneric404
                ? "Service temporarily unavailable. Please try again later."
                : msg,
            response.request!.url.toString());
      case 409:
        return {
          "access_token": null,
          "message": response.body["data"],
          "status": response.statusCode
        };
      case 422:
        throw BadRequestException(
            _errorMessage(response.body), response.request!.url.toString());
      case 500:
        throw FetchDataException(
            "Something went wrong on our end. Please try again later.",
            response.request!.url.toString(),
            response.statusCode);
      case 502:
      case 503:
      case 504:
        throw FetchDataException(
            "Service temporarily unavailable. Please try again in a moment.",
            response.request?.url.toString(),
            response.statusCode);
      default:
        throw ApiNotRespondingException(
            'Error occured with code : ${response.statusCode}',
            response.request?.url.toString(),
            null,
            response.statusCode);
    }
  }
}
