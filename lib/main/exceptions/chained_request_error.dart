import 'package:dio/dio.dart';

class ChainedRequestError extends DioError {
  /// Error from the first request
  final DioError primaryError;

  /// Error from the second request (retry/refresh)
  final Object? secondaryError;

  ChainedRequestError({
    required super.requestOptions,
    required this.primaryError,
    this.secondaryError,
  });
}
