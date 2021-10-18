import 'package:dio/dio.dart';

extension OptionsExtension on Options {
  Options appendHeaders(Map<String, dynamic> additionalHeaders) {
    if (this.headers != null) {
      this.headers?.addAll(additionalHeaders);
    } else {
      this.headers = additionalHeaders;
    }
    return this;
  }
}