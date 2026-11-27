import 'dart:async';

import 'package:core/presentation/utils/app_toast.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/presentation/cleanup_ended_delegations.dart';
import 'package:tmail_ui_user/features/delegation/presentation/model/session_reload.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/session_reload_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/dashboard_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/web_socket_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef ReenablePush = void Function();

/// Re-reads the session on resume and hands each re-read to the dashboard and Settings. See ADR-0114 §Sync.
class SessionReloadProviderListenerDelegate implements DashboardProviderListenerDelegate {
  final ReenablePush _reenablePush;
  ProviderSubscription<SessionReload?>? _subscription;
  AppLifecycleListener? _lifecycleListener;

  SessionReloadProviderListenerDelegate({ReenablePush? reenablePush})
      : _reenablePush = reenablePush ?? (() => WebSocketController.instance.reenablePush());

  @override
  void setup(WidgetRef ref, BuildContext Function() contextOf) {
    final notifier = ref.read(sessionReloadProvider.notifier);
    _lifecycleListener = AppLifecycleListener(onResume: notifier.reloadOnResume);
    _subscription = ref.listenManual<SessionReload?>(sessionReloadProvider, (_, reload) {
      if (reload != null) _apply(reload, contextOf);
    });
  }

  @override
  void dispose() {
    _lifecycleListener?.dispose();
    _lifecycleListener = null;
    _subscription?.close();
    _subscription = null;
  }

  void _apply(SessionReload reload, BuildContext Function() contextOf) {
    final dashboard = getBinding<MailboxDashBoardController>();
    if (dashboard == null) return;
    final previousSession = dashboard.sessionCurrent;
    dashboard.sessionCurrent = reload.session;
    getBinding<ManageAccountDashBoardController>()?.applyReloadedSession(reload.session);
    if (!_listsSameAccounts(previousSession, reload.session)) {
      _reenablePush();
    }
    if (reload.couldNotReturnToMine) {
      // The error toast must stay, a lost-items warning would replace it.
      unawaited(cleanupEndedDelegations(reload.session, fromCache: false));
      _showCouldNotReturnToMine(contextOf(), reload);
      return;
    }
    unawaited(cleanupEndedDelegationsAndWarn(reload.session, fromCache: false, reload: reload));
  }

  bool _listsSameAccounts(Session? previous, Session next) {
    final previousIds = previous?.accounts.keys.toSet() ?? const {};
    final nextIds = next.accounts.keys.toSet();
    return previousIds.length == nextIds.length && previousIds.containsAll(nextIds);
  }

  void _showCouldNotReturnToMine(BuildContext context, SessionReload reload) {
    final appToast = getBinding<AppToast>();
    if (appToast == null || !context.mounted) return;
    final l10n = AppLocalizations.of(context);
    appToast.showToastErrorMessage(
      context,
      [l10n.couldNotReturnToYourMailbox, ...keptWorkMessages(l10n, reload)].join(' '),
    );
  }
}
