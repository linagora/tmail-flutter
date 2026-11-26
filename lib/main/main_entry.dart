import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/utils/web_selection/web_selection_coordinator.dart';
import 'package:core/utils/build_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/login/presentation/tab_guard/basic_auth_tab_guard.dart';
import 'package:tmail_ui_user/main.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/utils/asset_preloader.dart';
import 'package:tmail_ui_user/main/utils/child_tab_session_cleaner.dart';
import 'package:tmail_ui_user/main/utils/cozy_integration.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:worker_manager/worker_manager.dart';

Future<void> runTmail() async {
  await runTmailPreload();
  runApp(const TMailApp());
}

Future<void> runTmailPreload() async {
  // Before any binding can restore the drafts copied from the opener tab.
  if (PlatformInfo.isWeb) ChildTabSessionCleaner().run();
  ThemeUtils.setSystemLightUIStyle();

  await Future.wait([
    MainBindings().dependencies(),
    HiveCacheConfig.instance.setUp(),
    if (PlatformInfo.isWeb) AssetPreloader.preloadHtmlEditorAssets(),
  ], eagerError: false);

  if (PlatformInfo.isMobile) {
    await workerManager.init(dynamicSpawning: true);
    workerManager.log = BuildUtils.isDebugMode;
  }
  await CozyIntegration.integrateCozy();
  await HiveCacheConfig.instance.initializeEncryptionKey();

  if (PlatformInfo.isWeb) {
    setPathUrlStrategy();
    WebSelectionCoordinator.instance.start();
    Get.put(BasicAuthTabGuard.forApp()).start();
  }
}
