import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_dns_client/super_dns_client.dart';
import 'package:tmail_ui_user/features/login/data/network/dns_lookup/dns_lookup_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/dns_lookup/dns_lookup_priority.dart';

// Generate mock class for DnsClient
@GenerateMocks([DnsClient])
import 'dns_lookup_manager_test.mocks.dart';

void main() {
  late MockDnsClient mockSystemClient;
  late MockDnsClient mockPublicClient;
  late MockDnsClient mockDohClient;
  late MockDnsClient mockCloudClient;

  setUp(() {
    mockSystemClient = MockDnsClient();
    mockPublicClient = MockDnsClient();
    mockDohClient = MockDnsClient();
    mockCloudClient = MockDnsClient();
  });

  group('DnsLookupManager.lookupJmapUrl', () {
    test('✅ should return target when system resolver succeeds', () async {
      // Arrange
      when(mockSystemClient.lookupSrv(any)).thenAnswer((_) async => [
            const SrvRecord(
              name: '_jmap._tcp.example.com',
              port: 443,
              priority: 10,
              weight: 5,
              ttl: 3600,
              target: 'mail.example.com',
            )
          ]);

      final manager = _TestableDnsLookupManager({
        DnsLookupPriority.system: mockSystemClient,
        DnsLookupPriority.publicUdp: mockPublicClient,
        DnsLookupPriority.publicDoh: mockDohClient,
        DnsLookupPriority.cloud: mockCloudClient,
      });

      // Act
      final result = await manager.lookupJmapUrl('user@example.com');

      // Assert
      expect(result, equals('mail.example.com'));
      verify(mockSystemClient.lookupSrv('_jmap._tcp.example.com')).called(1);
      verifyNever(mockPublicClient.lookupSrv(any));
    });

    test('✅ should fall back when previous resolver fails', () async {
      // Arrange
      when(mockSystemClient.lookupSrv(any))
          .thenThrow(Exception('System failed'));
      when(mockPublicClient.lookupSrv(any)).thenAnswer((_) async => [
            const SrvRecord(
              name: '_jmap._tcp.example.com',
              port: 443,
              priority: 20,
              weight: 5,
              ttl: 3600,
              target: 'mail-backup.example.com',
            )
          ]);

      final manager = _TestableDnsLookupManager({
        DnsLookupPriority.system: mockSystemClient,
        DnsLookupPriority.publicUdp: mockPublicClient,
        DnsLookupPriority.publicDoh: mockDohClient,
        DnsLookupPriority.cloud: mockCloudClient,
      });

      // Act
      final result = await manager.lookupJmapUrl('user@example.com');

      // Assert
      expect(result, equals('mail-backup.example.com'));
      verifyInOrder([
        mockSystemClient.lookupSrv(any),
        mockPublicClient.lookupSrv(any),
      ]);
    });

    test('✅ should skip to next resolver when previous returns empty list',
        () async {
      // Arrange
      when(mockSystemClient.lookupSrv(any)).thenAnswer((_) async => []);
      when(mockPublicClient.lookupSrv(any)).thenAnswer((_) async => [
            const SrvRecord(
              name: '_jmap._tcp.example.com',
              port: 443,
              priority: 15,
              weight: 5,
              ttl: 3600,
              target: 'mail-fallback.example.com',
            )
          ]);

      final manager = _TestableDnsLookupManager({
        DnsLookupPriority.system: mockSystemClient,
        DnsLookupPriority.publicUdp: mockPublicClient,
        DnsLookupPriority.publicDoh: mockDohClient,
        DnsLookupPriority.cloud: mockCloudClient,
      });

      // Act
      final result = await manager.lookupJmapUrl('user@example.com');

      // Assert
      expect(result, equals('mail-fallback.example.com'));
      verifyInOrder([
        mockSystemClient.lookupSrv(any),
        mockPublicClient.lookupSrv(any),
      ]);
    });

    test('⚠️ should continue when some resolvers throw exceptions', () async {
      // Arrange
      when(mockSystemClient.lookupSrv(any))
          .thenThrow(Exception('System crashed'));
      when(mockPublicClient.lookupSrv(any))
          .thenThrow(Exception('Network down'));
      when(mockDohClient.lookupSrv(any)).thenAnswer((_) async => [
            const SrvRecord(
              name: '_jmap._tcp.example.com',
              port: 443,
              priority: 5,
              weight: 5,
              ttl: 3600,
              target: 'mail-doh.example.com',
            )
          ]);

      final manager = _TestableDnsLookupManager({
        DnsLookupPriority.system: mockSystemClient,
        DnsLookupPriority.publicUdp: mockPublicClient,
        DnsLookupPriority.publicDoh: mockDohClient,
        DnsLookupPriority.cloud: mockCloudClient,
      });

      // Act
      final result = await manager.lookupJmapUrl('user@example.com');

      // Assert
      expect(result, equals('mail-doh.example.com'));
      verify(mockDohClient.lookupSrv(any)).called(1);
    });

    test('⏱️ should return empty string when all resolvers timeout', () async {
      // Arrange: simulate all resolvers hanging
      when(mockSystemClient.lookupSrv(any)).thenAnswer(
          (_) => Future.delayed(const Duration(seconds: 10), () => []));
      when(mockPublicClient.lookupSrv(any)).thenAnswer(
          (_) => Future.delayed(const Duration(seconds: 10), () => []));
      when(mockDohClient.lookupSrv(any)).thenAnswer(
          (_) => Future.delayed(const Duration(seconds: 10), () => []));
      when(mockCloudClient.lookupSrv(any)).thenAnswer(
          (_) => Future.delayed(const Duration(seconds: 10), () => []));

      final manager = _TestableDnsLookupManager({
        DnsLookupPriority.system: mockSystemClient,
        DnsLookupPriority.publicUdp: mockPublicClient,
        DnsLookupPriority.publicDoh: mockDohClient,
        DnsLookupPriority.cloud: mockCloudClient,
      });

      // Act
      final result = await manager.lookupJmapUrl('user@example.com');

      // Assert
      expect(result, isEmpty);
    });

    test('❌ should throw ArgumentError when email is invalid', () async {
      final manager = _TestableDnsLookupManager({});
      expect(
        () => manager.lookupJmapUrl('invalid-email'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('DnsLookupManager._buildJmapHostName', () {
    test('✅ should build correct host name from email', () {
      final manager = DnsLookupManager();
      final result = manager.buildJmapHostNameForTest('user@domain.com');
      expect(result, equals('_jmap._tcp.domain.com'));
    });

    test('❌ should throw ArgumentError for malformed email', () {
      final manager = DnsLookupManager();
      expect(
        () => manager.buildJmapHostNameForTest('invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

/// Test helper subclass that injects mock DNS clients.
class _TestableDnsLookupManager extends DnsLookupManager {
  final Map<DnsLookupPriority, DnsClient> clients;

  _TestableDnsLookupManager(this.clients);

  @override
  DnsClient createClient(DnsLookupPriority priority) {
    final client = clients[priority];
    if (client == null) {
      throw StateError('No mock client provided for $priority');
    }
    return client;
  }
}

/// Extends real DnsLookupManager only for testing private helpers.
extension DnsLookupManagerTestable on DnsLookupManager {
  String buildJmapHostNameForTest(String email) => buildJmapHostName(email);
}
