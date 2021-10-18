import 'dart:io';

import 'package:dio/dio.dart';
import 'package:core/core.dart';

class DioClient {
  static const jmapHeader = 'application/json;jmapVersion=rfc-8621';

  final Dio _dio;

  DioClient(this._dio);

  Map<String, dynamic> getHeaders() => Map.from(_dio.options.headers);

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final newOptions = options?.appendHeaders({HttpHeaders.acceptHeader : jmapHeader})
        ?? Options(headers: {HttpHeaders.acceptHeader : jmapHeader}) ;

    return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: newOptions,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress)
      .then((value) => value.data)
      .catchError((error) => throw error);
  }

  Future<dynamic> post(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final newOptions = options?.appendHeaders({HttpHeaders.acceptHeader : jmapHeader})
        ?? Options(headers: {HttpHeaders.acceptHeader : jmapHeader}) ;

    return await _dio.post(path,
        data: data,
        queryParameters: queryParameters,
        options: newOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress)
      .then((value) => value.data)
      .catchError((error) => throw error);
  }

  Future<dynamic> delete(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final newOptions = options?.appendHeaders({HttpHeaders.acceptHeader : jmapHeader})
        ?? Options(headers: {HttpHeaders.acceptHeader : jmapHeader}) ;

    return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: newOptions,
        cancelToken: cancelToken)
      .then((value) => value.data)
      .catchError((error) => throw(error));
  }

  Future<dynamic> put(
      String path, {
        data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        ProgressCallback? onSendProgress,
        ProgressCallback? onReceiveProgress
  }) async {
    final newOptions = options?.appendHeaders({HttpHeaders.acceptHeader : jmapHeader})
        ?? Options(headers: {HttpHeaders.acceptHeader : jmapHeader}) ;

    return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: newOptions,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress)
      .then((value) => value.data)
      .catchError((error) => throw(error));
  }
}