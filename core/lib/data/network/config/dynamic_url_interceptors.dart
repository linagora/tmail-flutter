import 'package:dio/dio.dart';

class DynamicUrlInterceptors extends InterceptorsWrapper {
  static const _sessionPath = '/.well-known/jmap';

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
    // The session lives at the server root, not under the session's apiUrl the base switches to after the first load.
    final requestBaseUrl = options.path == _sessionPath ? (_jmapUrl ?? _baseUrl) : _baseUrl;
    if (requestBaseUrl != null) {
      options.baseUrl = requestBaseUrl;
    }
    super.onRequest(options, handler);
  }
}