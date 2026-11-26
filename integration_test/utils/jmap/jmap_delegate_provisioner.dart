import 'package:tmail_ui_user/features/delegation/data/network/delegate_api.dart';

import 'jmap_test_client.dart';

/// Grants and revokes access to the signed-in mailbox straight through JMAP.
class JmapDelegateProvisioner {
  Future<void> add(Set<String> delegateAddresses) async {
    final client = await JmapTestClient.current();
    final result = await DelegateApi(client.httpClient).addDelegates(client.accountId, delegateAddresses);
    if (result.rejectedUsernames.isNotEmpty) {
      throw StateError('Delegates rejected: ${result.rejectedUsernames.keys}');
    }
  }

  Future<void> removeAll() async {
    final client = await JmapTestClient.current();
    final api = DelegateApi(client.httpClient);
    for (final delegate in await api.getDelegates(client.accountId)) {
      await api.removeDelegate(client.accountId, delegate);
    }
  }
}
