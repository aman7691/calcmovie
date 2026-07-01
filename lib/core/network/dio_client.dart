import 'package:dio/dio.dart';
import 'package:secret_vault_app/core/constants/app_constants.dart';
import 'package:secret_vault_app/core/errors/exceptions.dart'
    as app_exceptions;

/// Dio HTTP client configured for TMDB API calls.
/// Uses interceptors for: logging, error handling, and API key injection.
class DioClient {
  static Dio? _dio;

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        queryParameters: {
          'api_key': AppConstants.apiKey,
        },
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    dio.interceptors.addAll([
      _ErrorInterceptor(),
      // Uncomment below for debug logging:
      // LogInterceptor(requestBody: true, responseBody: true),
    ]);

    return dio;
  }
}

/// Converts Dio errors into typed AppExceptions
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw app_exceptions.TimeoutException();
      case DioExceptionType.connectionError:
        throw app_exceptions.NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401) {
          throw app_exceptions.UnauthorizedException();
        } else if (statusCode == 404) {
          throw app_exceptions.ServerException(
            message: 'Content not found.',
            statusCode: statusCode,
          );
        } else {
          throw app_exceptions.ServerException(
            message: 'Server error ($statusCode).',
            statusCode: statusCode,
          );
        }
      default:
        throw app_exceptions.NetworkException('Network error occurred.');
    }
  }
}
