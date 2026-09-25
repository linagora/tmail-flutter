import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_handler.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/sentry_config_linagora_ecosystem.dart';

typedef SetUpSentry = Future<void> Function(SentryConfigLinagoraEcosystem);
typedef ClearSentry = Future<void> Function();
typedef ResetSentryReportingConsent = void Function();

/// Handles ecosystem-owned Sentry configuration on non-web platforms.
class SentryEcosystemHandler
    implements
        LinagoraEcosystemHandler,
        AccountAwareLinagoraEcosystemHandler {
  final SetUpSentry _setUpSentry;
  final ClearSentry _clearSentry;
  final ResetSentryReportingConsent _resetSentryReportingConsent;

  const SentryEcosystemHandler({
    required SetUpSentry setUpSentry,
    required ClearSentry clearSentry,
    required ResetSentryReportingConsent resetSentryReportingConsent,
  })  : _setUpSentry = setUpSentry,
        _clearSentry = clearSentry,
        _resetSentryReportingConsent = resetSentryReportingConsent;

  @override
  void onAccountChanged() {
    _resetSentryReportingConsent();
  }

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
      logTrace(
        'SentryEcosystemHandler::onEcosystemLoaded: Sentry config is not provided',
      );
      onEcosystemCleared();
    }
  }
}
