import 'package:dio/dio.dart';

class DynamicUrlInterceptors extends InterceptorsWrapper {
  String? _jmapUrl;
  String? _baseUrl;

  void changeBaseUrl(String? url) {
    _baseUrl = url;
  }

  void setJmapUrl(String? url) {
    _jmapUrl = url;
  }

  String? get jmapUrl => _jmapUrl;

  String? get baseUrl => _baseUrl;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_baseUrl != null) {
      options.baseUrl = _baseUrl!;
    }
    super.onRequest(options, handler);
  }
}