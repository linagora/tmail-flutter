import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_context_data.dart';
import 'package:tmail_ui_user/main/monitoring/sentry/sentry_manager.dart';

abstract class ExceptionThrower {
  throwException(dynamic error, dynamic stackTrace);

  @protected
  void reportToSentry(
    dynamic error,
    dynamic stackTrace, {
    String? errorType,
    String? errorMessage,
    int? statusCode,
    String? source,
    Map<String, dynamic>? additionalInfo,
  }) {
    final context = SentryContextData(
      source: source,
      errorType: errorType,
      errorMessage: errorMessage,
      statusCode: statusCode,
      additionalInfo: additionalInfo,
    );

    SentryManager.instance.reportError(error, stackTrace, context);
  }
}
