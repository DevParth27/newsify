import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../errors/failures.dart';

class DioClient {
  DioClient._();

  static final Logger _logger = Logger();

  static Dio get dio => _dio;

  static final Dio _dio = _buildDio();

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        responseType: ResponseType.json,
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final query = Map<String, dynamic>.from(options.queryParameters);
          query['apiKey'] = AppConstants.newsApiKey;
          options.queryParameters = query;
          handler.next(options);
        },
      ),
    );

    return dio;
  }

  static Failure mapDioExceptionToFailure(DioException exception) {
    final message = exception.message ?? "Request failed.";
    _logger.e(exception);

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure(message);
      case DioExceptionType.connectionError:
        return NoInternetFailure(message);
      case DioExceptionType.badResponse:
        final statusCode = exception.response?.statusCode;
        final serverMessage = statusCode != null ? "Server error ($statusCode)." : "Server error.";
        return ServerFailure(serverMessage);
      case DioExceptionType.cancel:
        return NetworkFailure("Request cancelled.");
      case DioExceptionType.unknown:
        return NoInternetFailure(message);
      case DioExceptionType.badCertificate:
        return ServerFailure("Bad certificate.");
    }
  }
}

