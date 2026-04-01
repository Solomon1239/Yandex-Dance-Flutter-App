class AppException implements Exception {
  const AppException({
    required this.message,
    this.type = AppExceptionType.unknown,
  });

  const AppException.auth(this.message) : type = AppExceptionType.auth;
  const AppException.cancelled(this.message)
      : type = AppExceptionType.cancelled;
  const AppException.unknown(this.message) : type = AppExceptionType.unknown;

  final String message;
  final AppExceptionType type;

  @override
  String toString() => 'AppException(type: $type, message: $message)';
}

enum AppExceptionType {
  auth,
  cancelled,
  unknown,
}
