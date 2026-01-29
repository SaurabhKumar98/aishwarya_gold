class AppException implements Exception {
  final String? message;
  final String? prefix;

  AppException(this.message, this.prefix);

  @override
  String toString() {
    return "$prefix: $message";
  }

  String get userFriendlyMessage {
    return message ?? 'Something went wrong. Please try again.';
  }
}

class FetchDataException extends AppException {
  FetchDataException(String message) : super(message, "Fetch Data Exception");
}

class BadRequestException extends AppException {
  BadRequestException(String message) : super(message, "Bad Request");
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, "Unauthorized");
}

class InvalidInputException extends AppException {
  InvalidInputException(String message) : super(message, "Invalid Input");
}
