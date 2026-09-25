import 'dart:async';

import 'package:core/utils/app_logger.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_handler.dart';

class WebSentryEcosystemHandler
    implements
        LinagoraEcosystemHandler,
        AccountAwareLinagoraEcosystemHandler {
  final SentryManager _sentryManager;

  WebSentryEcosystemHandler({
    SentryManager? sentryManager,
  }) : _sentryManager = sentryManager ?? SentryManager.instance;

  @override
  void onAccountChanged() {
    _sentryManager.setSentryReportingConsent(null);
  }

  @override
  void onEcosystemCleared() {
    unawaited(_suspendReporting().catchError((e, st) {
      logError(
        'WebSentryEcosystemHandler::onEcosystemCleared: Cannot suspend Sentry reporting',
        exception: e,
        stackTrace: st,
      );
    }));
  }

  @override
  void onEcosystemLoaded(LinagoraEcosystem ecosystem) {
    final config = ecosystem.sentryConfigEcosystem;
    if (config != null) {
      unawaited(_applyReportingDefault(
        config.isSentryReportingAllowedByDefault,
      ).catchError((e, st) {
        logError(
          'WebSentryEcosystemHandler::onEcosystemLoaded: Cannot apply Sentry reporting default',
          exception: e,
          stackTrace: st,
        );
      }));
    } else {
      logTrace(
        'WebSentryEcosystemHandler::onEcosystemLoaded: Sentry config is not provided',
      );
      unawaited(_applyReportingDefault(false).catchError((e, st) {
        logError(
          'WebSentryEcosystemHandler::onEcosystemLoaded: Cannot disable Sentry reporting by default',
          exception: e,
          stackTrace: st,
        );
      }));
    }
  }

  Future<void> _applyReportingDefault(
    bool isReportingAllowedByDefault,
  ) async {
    _sentryManager.setSentryReportingDefault(isReportingAllowedByDefault);
    _sentryManager.resumeSentryReporting();
    await _sentryManager.pendingLifecycleTransition;
  }

  Future<void> _suspendReporting() async {
    _sentryManager.suspendSentryReporting();
    await _sentryManager.pendingLifecycleTransition;
  }
}
