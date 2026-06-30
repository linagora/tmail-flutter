import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class WorkplaceDio {
  static const _timeout = Duration(seconds: 10);
  static Dio _instance = Dio(
    BaseOptions(
      sendTimeout: _timeout,
      receiveTimeout: _timeout,
      connectTimeout: _timeout,
    ),
  );

  @visibleForTesting
  static void setInstance(Dio dio) => _instance = dio;

  static Dio get instance => _instance;
}
