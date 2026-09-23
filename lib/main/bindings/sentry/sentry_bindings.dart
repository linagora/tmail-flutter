import 'package:core/utils/platform_info.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/sentry_session_cleanup.dart';
import 'package:tmail_ui_user/features/caching/manager/sentry_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/sentry_ecosystem.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class SentryBindings extends Bindings {
  @override
  void dependencies() {
    final sentryEcosystem = _getOrCreateSentryEcosystem();
    if (!Get.isRegistered<SentrySessionCleanup>()) {
      Get.put<SentrySessionCleanup>(
        sentryEcosystem,
        permanent: true,
      );
    }
  }

  SentryEcosystem _getOrCreateSentryEcosystem() {
    if (Get.isRegistered<SentryEcosystem>()) {
      return Get.find<SentryEcosystem>();
    }

    return Get.put<SentryEcosystem>(
      SentryEcosystem(
        PlatformInfo.isMobile
            ? Get.find<SentryConfigurationCacheManager>()
            : null,
        PlatformInfo.isIOS ? Get.find<IOSSharingManager>() : null,
      ),
      permanent: true,
    );
  }
}
