import 'package:dio/dio.dart';

extension ObjectExtensions on Object? {
  DioException toDioException({
    required RequestOptions requestOptions,
    DioExceptionType type = DioExceptionType.unknown,
    String? message,
  }) {
    return DioException(
      requestOptions: requestOptions,
      error: this,
      type: type,
      message: message,
    );
  }
}
