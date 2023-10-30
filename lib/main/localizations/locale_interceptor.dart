import 'dart:io';

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

class LocaleInterceptor extends InterceptorsWrapper {

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final currentLocale = LocalizationService.getLocaleFromLanguage();
    log('LocaleInterceptor::onRequest:currentLocale: $currentLocale');
    options.headers[HttpHeaders.acceptLanguageHeader] = LocalizationService.supportedLocalesToLanguageTags();
    options.headers[HttpHeaders.contentLanguageHeader] = currentLocale.toLanguageTag();
    super.onRequest(options, handler);
  }
}