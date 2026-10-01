import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/data/network/dns_lookup/dns_lookup_priority.dart';

void main() {
  test('tries public DoH first, then system DNS, public UDP and cloud, in a fixed order', () {
    final ordered = List.of(DnsLookupPriority.values)
      ..sort((a, b) => a.priority.compareTo(b.priority));

    expect(ordered, [
      DnsLookupPriority.publicDoh,
      DnsLookupPriority.system,
      DnsLookupPriority.publicUdp,
      DnsLookupPriority.cloud,
    ]);
  });
}
