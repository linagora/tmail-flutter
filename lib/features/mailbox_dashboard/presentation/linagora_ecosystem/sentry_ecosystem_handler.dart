import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';

typedef SetUpSentry = Future<void> Function(SentryConfigLinagoraEcosystem);
typedef ClearSentry = Future<void> Function();

class SentryEcosystemHandler implements LinagoraEcosystemHandler {
  final SetUpSentry _setUpSentry;
  final ClearSentry _clearSentry;

  const SentryEcosystemHandler({
    required SetUpSentry setUpSentry,
    required ClearSentry clearSentry,
  })  : _setUpSentry = setUpSentry,
        _clearSentry = clearSentry;

  @override
  void onEcosystemCleared() {
    unawaited(_clearSentry().catchError((e, st) {
      logError(
        'SentryEcosystemHandler::onEcosystemCleared: Cannot clear Sentry configuration',
        exception: e,
        stackTrace: st,
      );
    }));
  }

  @override
  void onEcosystemLoaded(LinagoraEcosystem ecosystem) {
    if (PlatformInfo.isWeb) return;
    final config = ecosystem.sentryConfigEcosystem;
    if (config != null) {
      unawaited(_setUpSentry(config).catchError((e, st) {
        logError(
          'SentryEcosystemHandler::onEcosystemLoaded: Cannot set up Sentry configuration',
          exception: e,
          stackTrace: st,
        );
      }));
    } else {
      logWarning('SentryEcosystemHandler::onEcosystemLoaded: Sentry config is null');
      onEcosystemCleared();
    }
  }
}
