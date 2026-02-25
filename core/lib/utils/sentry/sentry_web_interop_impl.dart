import 'dart:js_interop';

import 'package:core/utils/app_logger.dart';

@JS('Sentry.init')
external void _initSentryJs(JSAny? options);

void initSentryWeb(
  String dsn,
  String environment,
  String release,
  double tracesSampleRate,
  bool isDebug,
) {
  try {
    final jsOptions = {
      'dsn': dsn,
      'environment': environment,
      'release': release,
      'tracesSampleRate': tracesSampleRate,
      'debug': isDebug,
    }.jsify();

    _initSentryJs(jsOptions);
    logWarning('[SentryWebInterop] Sentry JS SDK initialized locally.');
  } catch (e) {
    logWarning('[SentryWebInterop] Error initializing Sentry JS SDK: $e');
  }
}
