import 'package:tmail_ui_user/features/delegation/data/network/delegate_api.dart';

import 'jmap_test_client.dart';

typedef JmapClientConnector = Future<JmapTestClient> Function();

/// Grants and revokes access to the signed-in mailbox straight through JMAP.
class JmapDelegateProvisioner {
  JmapDelegateProvisioner() : _connect = JmapTestClient.current;

  /// Acts on the mailbox of [email] instead of the signed-in one.
  JmapDelegateProvisioner.signedInAs(String email, String password)
      : _connect = (() => JmapTestClient.signedInAs(email, password));

  final JmapClientConnector _connect;

  Future<void> add(Set<String> delegateAddresses) async {
    final client = await _connect();
    final result = await DelegateApi(client.httpClient).addDelegates(client.accountId, delegateAddresses);
    if (result.rejectedUsernames.isNotEmpty) {
      throw StateError('Delegates rejected: ${result.rejectedUsernames.keys}');
    }
  }

  Future<void> removeAll() async {
    final client = await _connect();
    final api = DelegateApi(client.httpClient);
    for (final delegate in await api.getDelegates(client.accountId)) {
      await api.removeDelegate(client.accountId, delegate);
    }
  }
}
