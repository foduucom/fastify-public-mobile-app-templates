class AppException implements Exception {
  final String? message;
  final String? prefix;
  final String? url;
  final int? statusCode;

  AppException([this.message, this.prefix, this.url, this.statusCode]);
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
  var statusCode;
  var prefix;
  var url;
  var message;

  ApiNotRespondingException(
      [String? message, String? url, String? prefix, int? statusCode]) {
    this.message = message;
    this.url = url;
    this.prefix = prefix;
    this.statusCode = statusCode;
  }

  dynamic sendError() {
    return {
      "message": this.message,
      "status": this.statusCode,
      "url": this.url,
      "prefix": this.prefix
    };
  }
}

class UnAuthorizedException extends AppException {
  UnAuthorizedException([String? message, String? url])
      : super(message, 'UnAuthorized request', url);
}
