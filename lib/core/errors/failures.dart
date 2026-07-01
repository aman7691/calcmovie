/// Base class for all failures in the application
abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection. Please check your network.']);
}

/// Server-related failures (4xx, 5xx)
class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({String message = 'Server error. Please try again later.', this.statusCode})
      : super(message);
}

/// API key invalid failure
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([super.message = 'Invalid API key. Please check your configuration.']);
}

/// Timeout failures
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = 'Request timed out. Please try again.']);
}

/// Cache/local storage failures
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to load cached data.']);
}

/// Not found failure
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Content not found.']);
}

/// General/unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'An unexpected error occurred. Please try again.']);
}
