import 'package:dio/dio.dart';
import 'package:secret_vault_app/core/constants/app_constants.dart';
import 'package:secret_vault_app/core/errors/exceptions.dart' as app_exceptions;

/// Dio HTTP client configured for TMDB API calls.
/// Uses base options for API key injection and shared request settings.
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

    // Uncomment below for debug logging:
    // dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

    return dio;
  }

  /// Converts Dio errors into typed app exceptions.
  static app_exceptions.AppException toAppException(DioException exception) {
    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const app_exceptions.TimeoutException();
      case DioExceptionType.connectionError:
        return const app_exceptions.NetworkException();
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        if (statusCode == 401) {
          return const app_exceptions.UnauthorizedException();
        }
        if (statusCode == 404) {
          return app_exceptions.ServerException(
            message: 'Content not found.',
            statusCode: statusCode,
          );
        }
        return app_exceptions.ServerException(
          message: 'Server error ($statusCode).',
          statusCode: statusCode,
        );
      default:
        return const app_exceptions.NetworkException('Network error occurred.');
    }
  }
}
