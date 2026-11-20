import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/delegates/dashboard_provider_listener_delegate.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/features/push_notification/domain/usecases/store_delegated_notification_baselines_interactor.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notifier/fcm_bindings_registration_notifier.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/model/state_change_account_filter.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

typedef StoreDelegatedNotificationBaselines = Future<bool> Function(Session session, Map<AccountId, String> ownerNames);

/// Gives each notified delegated mailbox a push cursor, so its first push lists only new emails (ADR-0114 Sync).
class DelegatedNotificationBaselineProviderListenerDelegate implements DashboardProviderListenerDelegate {
  final StoreDelegatedNotificationBaselines _store;
  final List<ProviderSubscription<Object?>> _subscriptions = [];
  String? _storedFor;
  Future<void> _lastStore = Future.value();

  DelegatedNotificationBaselineProviderListenerDelegate({StoreDelegatedNotificationBaselines? store})
      : _store = store ?? _storeWithInteractor;

  @override
  void setup(WidgetRef ref, BuildContext Function() contextOf) {
    if (!PlatformInfo.isMobile) return;
    void store() {
      // A cold start applies the session before the saved settings load, and the defaults would stop every delegated mailbox.
      if (!ref.read(localSettingsLoadedProvider)) return;
      _storeIfChanged(ref.read(activeAccountProvider)?.session, ref.read(localSettingsProvider));
    }
    _subscriptions
      ..add(ref.listenManual(activeAccountProvider.select((account) => account?.session), (_, __) => store()))
      ..add(ref.listenManual(localSettingsProvider, (_, __) => store()))
      ..add(ref.listenManual(localSettingsLoadedProvider, (_, __) => store()))
      ..add(ref.listenManual(fcmBindingsRegistrationProvider, (_, __) {
        // A store queued before the binding existed may not have reset the key yet.
        _storedFor = null;
        store();
      }));
    store();
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.close();
    }
    _subscriptions.clear();
  }

  /// A session re-read on resume keeps the cursors the pushes already moved.
  void _storeIfChanged(Session? session, PreferencesSetting settings) {
    if (session == null) return;
    final accountIds = notifiedDelegatedAccountIds(session, settings);
    final key = (accountIds.map((id) => id.id.value).toList()..sort()).join(',');
    if (key == _storedFor) return;
    _storedFor = key;
    final ownerNames = {
      for (final accountId in accountIds) accountId: session.accounts[accountId]!.name.value,
    };
    // Queued so a slow earlier store cannot overwrite a newer list.
    _lastStore = _lastStore.then((_) => _store(session, ownerNames)).then((stored) {
      if (!stored) _forgetStored(key);
    }).catchError((Object e, StackTrace st) {
      _forgetStored(key);
      logWarning('DelegatedNotificationBaselineProviderListenerDelegate::_storeIfChanged: $e | $st');
    });
  }

  /// Lets the next trigger with the same accounts store them again.
  void _forgetStored(String key) {
    if (_storedFor == key) _storedFor = null;
  }

  static Future<bool> _storeWithInteractor(Session session, Map<AccountId, String> ownerNames) async {
    final interactor = getBinding<StoreDelegatedNotificationBaselinesInteractor>();
    if (interactor == null) return false;
    final result = await interactor.execute(session, ownerNames).last;
    return result.isRight();
  }
}
