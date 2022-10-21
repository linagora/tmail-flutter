import 'package:dio/dio.dart';

extension OptionsExtension on Options {
  Options appendHeaders(Map<String, dynamic> additionalHeaders) {
    if (headers != null) {
      headers?.addAll(additionalHeaders);
    } else {
      headers = additionalHeaders;
    }
    return this;
  }
}