import 'dart:async';
import 'dart:io';

class AppException implements Exception {
  final String? message;
  final String? prefix;
  final String? url;
  final int? statusCode;

  AppException([this.message, this.prefix, this.url, this.statusCode]);

  @override
  String toString() {
    return (prefix != null ? "$prefix: " : "") + (message ?? "");
  }
}

class BadRequestException extends AppException {
  BadRequestException([String? message, String? url])
      : super(message, 'Bad Request', url);
}

class FetchDataException extends AppException {
  FetchDataException([String? message, String? url, int? statusCode])
      : super(message, 'Unable to process', url, statusCode);
}

class ApiNotRespondingException extends AppException {
  ApiNotRespondingException(
      [String? message, String? url, String? prefix, int? statusCode])
      : super(message, prefix, url, statusCode);

  dynamic sendError() {
    return {
      "message": message,
      "status": statusCode,
      "url": url,
      "prefix": prefix
    };
  }
}

class UnAuthorizedException extends AppException {
  UnAuthorizedException([String? message, String? url])
      : super(message, 'UnAuthorized request', url);
}

/// Converts any error thrown by the API layer (AppException, String, Map,
/// socket/timeout errors, ...) into a user-facing message. Never throws.
String errorMessageOf(Object? err,
    {String fallback = "Something went wrong. Please try again."}) {
  if (err == null) return fallback;
  if (err is AppException) {
    final msg = err.message;
    return (msg != null && msg.trim().isNotEmpty) ? msg : fallback;
  }
  if (err is SocketException) {
    return "Please check if your internet connection is stable!";
  }
  if (err is TimeoutException) {
    return "Connection timed out. Please try again later.";
  }
  if (err is String) return err.trim().isNotEmpty ? err : fallback;
  if (err is Map) {
    if (err.containsKey("errors") && err["errors"] != null) {
      final errors = err["errors"];
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
    final rawData = err["data"] ?? err["message"] ?? err["error"];
    if (rawData is String && rawData.trim().isNotEmpty) {
      return rawData;
    } else if (rawData is Map && rawData.isNotEmpty) {
      final firstVal = rawData.values.first;
      if (firstVal is List && firstVal.isNotEmpty) {
        return firstVal.first.toString();
      }
      if (firstVal != null) return firstVal.toString();
    } else if (rawData is List && rawData.isNotEmpty) {
      return rawData.first.toString();
    }
  }
  return fallback;
}
