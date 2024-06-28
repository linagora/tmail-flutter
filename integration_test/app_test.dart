import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tmail_ui_user/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  FlutterExceptionHandler? originalOnError;

  setUp(() {
    // Save the original error handler
    originalOnError = FlutterError.onError;
  });

  tearDown(() {
    // Reset FlutterError.onError to the original handler
    FlutterError.onError = originalOnError;
  });

  group('[login]', () {
    testWidgets('login with OIDC', (WidgetTester tester) async {
      await app.main();
      await tester.pumpAndSettle();
    });
  });
}
