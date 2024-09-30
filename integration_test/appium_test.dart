import 'package:appium_flutter_server/appium_flutter_server.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/main.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:worker_manager/worker_manager.dart';

void main() {
  initializeTest(
    callback: (WidgetTester tester) async {
      WidgetsFlutterBinding.ensureInitialized();
      if (PlatformInfo.isWeb) {
        SemanticsBinding.instance.ensureSemantics();
      }
      ThemeUtils.setSystemLightUIStyle();

      await Future.wait([
        MainBindings().dependencies(),
        HiveCacheConfig.instance.setUp(),
        Executor().warmUp(),
        AppUtils.loadEnvFile()
      ]);
      await HiveCacheConfig.instance.initializeEncryptionKey();

      setPathUrlStrategy();
      await tester.pumpWidget(const TMailApp());
    },
  );
}