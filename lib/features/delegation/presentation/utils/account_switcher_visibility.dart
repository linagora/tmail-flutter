import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:tmail_ui_user/features/delegation/domain/extensions/session_delegation_extension.dart';

/// True when delegation is on and the session lists a delegated mailbox.
bool canShowAccountSwitcher({
  required bool delegationEnabled,
  required Session? session,
}) =>
    delegationEnabled && session != null && session.hasDelegatedAccounts;
