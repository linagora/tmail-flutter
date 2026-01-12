import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:dio/dio.dart';
import 'package:sentry_dio/sentry_dio.dart';

class SentryDioHelper {
  static void addIfAvailable(Dio dio) {
    if (!SentryManager.instance.isSentryAvailable) return;
    dio.addSentry();
  }
}
