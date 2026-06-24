import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class WorkplaceDio {
  static Dio _instance = Dio();

  @visibleForTesting
  static void setInstance(Dio dio) => _instance = dio;

  static Dio get instance => _instance;
}