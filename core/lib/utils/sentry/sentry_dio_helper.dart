import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:dio/dio.dart';
import 'package:sentry_dio/sentry_dio.dart';

class SentryDioHelper {
  static void addIfAvailable(Dio dio) {
    if (!SentryManager.instance.isSentryAvailable) return;

    final alreadyHasSentry = dio.interceptors.any(
        (i) => i.runtimeType.toString().contains('FailedRequestInterceptor'));
    if (!alreadyHasSentry) {
      dio.addSentry();
    }
  }
}
