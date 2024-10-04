import 'package:flutter/foundation.dart';
import 'package:tmail_ui_user/main.dart' as app;

class TestBase {
  Future<void> runTestApp() async {
    await app.runTmail();
    // https://github.com/leancodepl/patrol/issues/1602#issuecomment-1665317814
    final originalOnError = FlutterError.onError!;
    FlutterError.onError = (FlutterErrorDetails details) {
      originalOnError(details);
    };
  }
}