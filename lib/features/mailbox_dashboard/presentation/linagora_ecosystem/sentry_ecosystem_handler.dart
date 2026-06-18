import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';

class SentryEcosystemHandler implements LinagoraEcosystemHandler {
  final Future<void> Function(SentryConfigLinagoraEcosystem) _setUpSentry;

  const SentryEcosystemHandler({
    required Future<void> Function(SentryConfigLinagoraEcosystem) setUpSentry,
  }) : _setUpSentry = setUpSentry;

  @override
  void onEcosystemCleared() {}

  @override
  void onEcosystemLoaded(LinagoraEcosystem ecosystem) {
    if (PlatformInfo.isWeb) return;
    final config = ecosystem.sentryConfigEcosystem;
    if (config != null) {
      _setUpSentry(config);
    } else {
      logWarning('SentryEcosystemHandler::onEcosystemLoaded: Sentry config is null');
    }
  }
}
