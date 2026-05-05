class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class AuthException extends AppException {
  AuthException(super.message, {super.code});
}

class StorageException extends AppException {
  StorageException(super.message);
}

class ValidationException extends AppException {
  ValidationException(super.message);
}
