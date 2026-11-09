import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';
import 'package:tmail_ui_user/features/delegation/presentation/notifier/active_account_notifier.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/preferences/preferences_setting.dart';
import 'package:tmail_ui_user/main/providers/settings/local_settings_notifier.dart';

part 'delegation_enabled_provider.g.dart';

/// Delegation is on when the session supports it and the local "Delegation" preference is on (ADR-0114).
bool isDelegationEnabled(Session? session, PreferencesSetting settings) =>
    session?.supportsDelegation == true && settings.delegationConfig.isEnabled;

@riverpod
bool delegationEnabled(Ref ref) => isDelegationEnabled(
      ref.watch(activeAccountProvider)?.session,
      ref.watch(localSettingsProvider),
    );
