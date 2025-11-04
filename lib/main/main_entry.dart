import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/build_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/main.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';
import 'package:tmail_ui_user/main/utils/asset_preloader.dart';
import 'package:tmail_ui_user/main/utils/cozy_integration.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:worker_manager/worker_manager.dart';

/// The core app runner
Future<void> runTmail() async {
  await runTmailPreload();
  runApp(const TMailApp());
}

Future<void> runTmailPreload() async {
  ThemeUtils.setSystemLightUIStyle();

  await Future.wait([
    MainBindings().dependencies(),
    HiveCacheConfig.instance.setUp(),
    Executor().warmUp(log: BuildUtils.isDebugMode),
    AppUtils.loadEnvFile(),
    if (PlatformInfo.isWeb) AssetPreloader.preloadHtmlEditorAssets(),
  ]);

  await CozyIntegration.integrateCozy();
  await HiveCacheConfig.instance.initializeEncryptionKey();

  setPathUrlStrategy();
}
