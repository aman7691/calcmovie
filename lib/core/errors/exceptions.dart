/// Base exception class
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when network is unavailable
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

/// Thrown when server returns error status codes
class ServerException extends AppException {
  final int? statusCode;
  const ServerException({String message = 'Server error.', this.statusCode}) : super(message);
}

/// Thrown when API key is invalid (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException([super.message = 'Unauthorized: Invalid API key.']);
}

/// Thrown when request times out
class TimeoutException extends AppException {
  const TimeoutException([super.message = 'Request timed out.']);
}

/// Thrown when local cache operations fail
class CacheException extends AppException {
  const CacheException([super.message = 'Cache error.']);
}
