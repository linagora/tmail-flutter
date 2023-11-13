import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dio/dio.dart';
import 'package:tmail_ui_user/features/login/data/network/endpoint.dart';

class TimeOutInterceptors extends InterceptorsWrapper {

  static const Duration _sessionConnectTimeout = Duration(milliseconds: 5000);
  static const Duration _sessionReceiveTimeout = Duration(milliseconds: 5000);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    log('TimeOutInterceptors::onRequest():url: ${options.uri}');
    if (PlatformInfo.isMobile && _validateToGetSession(options.uri)) {
      options.connectTimeout = _sessionConnectTimeout;
      options.receiveTimeout = _sessionReceiveTimeout;
    }
    super.onRequest(options, handler);
  }

  bool _validateToGetSession(Uri uri) => uri.toString().endsWith(Endpoint.sessionPath.path);
}
