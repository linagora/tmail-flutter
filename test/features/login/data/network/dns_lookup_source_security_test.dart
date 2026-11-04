import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:super_dns_client/super_dns_client.dart';
import 'package:tmail_ui_user/features/login/data/network/dns_lookup/dns_lookup_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/dns_lookup/dns_lookup_priority.dart';

import 'dns_lookup_manager_test.mocks.dart';

const _record = SrvRecord(
  name: '_jmap._tcp.corp.example',
  port: 443,
  priority: 10,
  weight: 5,
  ttl: 3600,
  target: 'mail.corp.example',
);

class _ManagerWithClients extends DnsLookupManager {
  _ManagerWithClients(this.clients);

  final Map<DnsLookupPriority, DnsClient> clients;

  @override
  DnsClient createClient(DnsLookupPriority priority) => clients[priority]!;
}

void main() {
  late Map<DnsLookupPriority, MockDnsClient> clients;

  setUp(() {
    clients = {
      for (final priority in DnsLookupPriority.values) priority: MockDnsClient(),
    };
    for (final client in clients.values) {
      when(client.timeout).thenReturn(const Duration(seconds: 3));
      when(client.lookupSrv(any)).thenAnswer((_) async => []);
    }
  });

  Future<bool> sourceIsEncrypted(DnsLookupPriority answering) async {
    when(clients[answering]!.lookupSrv(any)).thenAnswer((_) async => [_record]);
    final result = await _ManagerWithClients(clients).lookupJmapTarget('bob@corp.example');
    expect(result.target, 'mail.corp.example');
    return result.isEncrypted;
  }

  test('SHOULD mark an answer from public DNS-over-HTTPS as encrypted', () async {
    expect(await sourceIsEncrypted(DnsLookupPriority.publicDoh), isTrue);
  });

  test('SHOULD mark an answer from the system resolver as plaintext', () async {
    expect(await sourceIsEncrypted(DnsLookupPriority.system), isFalse);
  });

  test('SHOULD mark an answer from public UDP resolvers as plaintext', () async {
    expect(await sourceIsEncrypted(DnsLookupPriority.publicUdp), isFalse);
  });

  test('SHOULD mark an answer from cloud DNS-over-HTTPS as encrypted', () async {
    expect(await sourceIsEncrypted(DnsLookupPriority.cloud), isTrue);
  });
}
