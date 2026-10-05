import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:foduu_ecommerce/app/modules/auth/auth_details.dart';
import 'package:get/get.dart' as get_x;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../constants/app_exceptions.dart';
import '../../constants/constants.dart';
import '../../constants/helper_functions.dart';
import '../../constants/resilience_strings.dart';
import '../../services/api_cache.dart';
import '../../services/api_health_service.dart';
import 'package:get_storage/get_storage.dart';

class BasicProvider {
  final String custom_url;

  BasicProvider(this.custom_url);
  var box = GetStorage();

  String fetchUrl() {
    return apiURL + custom_url;
  }

  /// True when the last [getRequest] was answered from the local cache
  /// because the server could not be reached.
  bool servedFromCache = false;

  static const _transientStatuses = {502, 503, 504};
  static const _backoff = [
    Duration(seconds: 1),
    Duration(seconds: 2),
    Duration(seconds: 4),
    Duration(seconds: 8),
    Duration(seconds: 8),
  ];
  static final Map<String, Future<http.Response>> _inFlightGets = {};
  static final Random _random = Random();

  /// GET with automatic retry (502/503/504, timeouts, connection errors) and a
  /// stale-while-revalidate cache fallback. Never retries 4xx.
  Future<dynamic> getRequest({
    final queryParams,
    bool useCache = true,
    bool retry = true,
  }) async {
    servedFromCache = false;
    var uri = Uri.parse(fetchUrl());
    if (queryParams != null && queryParams is Map) {
      final Map<String, dynamic> normalizedParams = {};
      queryParams.forEach((key, value) {
        if (value == null) return;
        if (value is Iterable) {
          normalizedParams[key.toString()] =
              value.map((e) => e.toString()).toList();
        } else {
          normalizedParams[key.toString()] = value.toString();
        }
      });
      uri = uri.replace(queryParameters: normalizedParams);
    }

    final cacheable = useCache && ApiCache.isCacheable(custom_url);
    final cacheKey = ApiCache.keyFor(uri, AuthDetails.getToken());
    final cached = cacheable ? ApiCache.read(cacheKey) : null;

    try {
      final response = await _fetchWithRetry(uri,
          hasCache: cached != null, retry: retry);
      final result = _processResponse(response, fetchUrl());
      if (cacheable && (response.statusCode == 200 || response.statusCode == 201)) {
        ApiCache.write(cacheKey, result);
      }
      return result;
    } on ServiceUnavailableException {
      return _fallbackToCache(cached);
    } on SocketException {
      return _fallbackToCache(cached);
    } on TimeoutException {
      return _fallbackToCache(cached);
    } on http.ClientException {
      return _fallbackToCache(cached);
    } on UnAuthorizedException {
      rethrow;
    } catch (e) {
      print(e.toString());
      rethrow;
    }
  }

  dynamic _fallbackToCache(dynamic cached) {
    final health = ApiHealthService.maybe;
    health?.reportTransientFailure();
    if (cached != null) {
      servedFromCache = true;
      health?.reportStale();
      return cached;
    }
    throw ServiceUnavailableException(null, fetchUrl());
  }

  Future<http.Response> _fetchWithRetry(Uri uri,
      {required bool hasCache, required bool retry}) {
    // Several widgets asking for the same URL while the server is restarting
    // share one retry loop instead of hammering it.
    final key = '$uri|${AuthDetails.getToken()}|$retry';
    final existing = _inFlightGets[key];
    if (existing != null) return existing;
    final future = _doFetch(uri, hasCache: hasCache, retry: retry);
    _inFlightGets[key] = future;
    future.whenComplete(() => _inFlightGets.remove(key)).ignore();
    return future;
  }

  Future<http.Response> _doFetch(Uri uri,
      {required bool hasCache, required bool retry}) async {
    // With a cached copy to show we only wait briefly; without one we keep
    // trying long enough to ride out a ~30s deploy.
    final budget = hasCache ? const Duration(seconds: 8) : const Duration(seconds: 35);
    final attemptTimeout =
        hasCache ? const Duration(seconds: 6) : const Duration(seconds: 15);
    final watch = Stopwatch()..start();
    var attempt = 0;
    Object? error;
    http.Response? response;

    while (true) {
      error = null;
      response = null;
      try {
        response =
            await http.get(uri, headers: headerType()).timeout(attemptTimeout);
        if (!_transientStatuses.contains(response.statusCode)) {
          // Any real answer means the backend is up.
          ApiHealthService.maybe?.reportSuccess();
          return response;
        }
      } on SocketException catch (e) {
        error = e;
      } on TimeoutException catch (e) {
        error = e;
      } on http.ClientException catch (e) {
        error = e;
      }

      ApiHealthService.maybe?.reportTransientFailure();

      if (!retry || attempt >= _backoff.length) break;
      var delay = _backoff[attempt];
      final retryAfter = int.tryParse(response?.headers['retry-after'] ?? '');
      if (retryAfter != null) {
        final hinted = Duration(seconds: retryAfter.clamp(1, 10));
        if (hinted > delay) delay = hinted;
      }
      delay = Duration(
          milliseconds:
              (delay.inMilliseconds * (0.75 + _random.nextDouble() * 0.5)).round());
      if (watch.elapsed + delay >= budget) break;
      await Future.delayed(delay);
      attempt++;
    }

    // Retries exhausted: hand back the last bad response so it is classified
    // as ServiceUnavailable, or rethrow the network error.
    if (response != null) return response;
    throw error ?? const SocketException('Backend unreachable');
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

      return _processResponse(response, fetchUrl());
    } on ServiceUnavailableException {
      // Writes are never auto-retried (they may not be idempotent); tell the
      // user plainly and let them retry.
      HelperFunctions().showSnackBarError(_writeFailedMessage());
      rethrow;
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
    } on ServiceUnavailableException {
      // Writes are never auto-retried (they may not be idempotent); tell the
      // user plainly and let them retry.
      HelperFunctions().showSnackBarError(_writeFailedMessage());
      rethrow;
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
    } on ServiceUnavailableException {
      // Writes are never auto-retried (they may not be idempotent); tell the
      // user plainly and let them retry.
      HelperFunctions().showSnackBarError(_writeFailedMessage());
      rethrow;
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

  String _writeFailedMessage() {
    final p = custom_url.toLowerCase();
    return (p.contains('checkout') || p.contains('payment') || p.contains('order'))
        ? ResilienceStrings.checkoutFailed
        : ResilienceStrings.writeFailed;
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

      return userHeader;
    } catch (e) {
      print('header error $e');
      return {'': ''};
    }
  }

  dynamic _processResponse(http.Response response, url) {
    print('url === $url ${response.statusCode}');

    if (_transientStatuses.contains(response.statusCode)) {
      throw ServiceUnavailableException(null, url.toString(), response.statusCode);
    }

    var responseBody;
    if (response.body.isNotEmpty && !response.body.trimLeft().startsWith('<')) {
      try {
        responseBody = json.decode(response.body);
      } catch (e) {
        print("JSON decode error: $e");
      }
    }

    var message;
    if (responseBody is Map) {
      message = responseBody['data'] ?? responseBody['message'];
    }

    switch (response.statusCode) {
      case 200:
      case 201:
        if (responseBody is Map) {
          final data = responseBody["data"];
          if (data is Map || data is List) {
            return data;
          }
        }
        return responseBody;
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
          "message": responseBody is Map ? responseBody["data"] : responseBody,
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
