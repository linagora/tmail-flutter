import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/cache/linagora_ecosystem_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_identifier.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/linagora_ecosystem/linagora_ecosystem_properties.dart';

void main() {
  group('LinagoraEcosystemCache Test', () {
    const testBaseUrl = 'https://example.com';
    const differentBaseUrl = 'https://different.com';
    
    final testEcosystem = LinagoraEcosystem({
      LinagoraEcosystemIdentifier.linShareApiUrl: ApiUrlLinagoraEcosystem('https://linshare.com/api'),
    });
    
    final differentEcosystem = LinagoraEcosystem({
      LinagoraEcosystemIdentifier.twakeApiUrl: ApiUrlLinagoraEcosystem('https://twake.com/api'),
    });

    tearDown(() {
      // Clear cache after each test
      LinagoraEcosystemCache().clearCache();
    });

    test('should cache and retrieve ecosystem correctly', () {
      // Cache the ecosystem
      LinagoraEcosystemCache().cacheEcosystem(testEcosystem, testBaseUrl);
      
      // Retrieve from cache
      final cachedEcosystem = LinagoraEcosystemCache().getCachedEcosystem(testBaseUrl);
      
      expect(cachedEcosystem, isNotNull);
      expect(cachedEcosystem, equals(testEcosystem));
    });

    test('should return null for different base URL', () {
      // Cache the ecosystem for one base URL
      LinagoraEcosystemCache().cacheEcosystem(testEcosystem, testBaseUrl);
      
      // Try to retrieve for different base URL
      final cachedEcosystem = LinagoraEcosystemCache().getCachedEcosystem(differentBaseUrl);
      
      expect(cachedEcosystem, isNull);
    });

    test('should return null when cache is empty', () {
      final cachedEcosystem = LinagoraEcosystemCache().getCachedEcosystem(testBaseUrl);
      
      expect(cachedEcosystem, isNull);
    });

    test('should clear cache correctly', () {
      // Cache the ecosystem
      LinagoraEcosystemCache().cacheEcosystem(testEcosystem, testBaseUrl);
      
      // Verify it's cached
      var cachedEcosystem = LinagoraEcosystemCache().getCachedEcosystem(testBaseUrl);
      expect(cachedEcosystem, isNotNull);
      
      // Clear cache
      LinagoraEcosystemCache().clearCache();
      
      // Verify it's cleared
      cachedEcosystem = LinagoraEcosystemCache().getCachedEcosystem(testBaseUrl);
      expect(cachedEcosystem, isNull);
    });

    test('should handle multiple base URLs correctly', () {
      // Cache ecosystems for different base URLs
      LinagoraEcosystemCache().cacheEcosystem(testEcosystem, testBaseUrl);
      LinagoraEcosystemCache().cacheEcosystem(differentEcosystem, differentBaseUrl);
      
      // Verify each base URL gets its own ecosystem
      final cachedTestEcosystem = LinagoraEcosystemCache().getCachedEcosystem(testBaseUrl);
      final cachedDifferentEcosystem = LinagoraEcosystemCache().getCachedEcosystem(differentBaseUrl);
      
      expect(cachedTestEcosystem, equals(testEcosystem));
      expect(cachedDifferentEcosystem, equals(differentEcosystem));
    });

    test('hasCachedEcosystem should return correct boolean', () {
      // Initially should be false
      expect(LinagoraEcosystemCache().hasCachedEcosystem(testBaseUrl), isFalse);
      
      // After caching should be true
      LinagoraEcosystemCache().cacheEcosystem(testEcosystem, testBaseUrl);
      expect(LinagoraEcosystemCache().hasCachedEcosystem(testBaseUrl), isTrue);
      
      // After clearing should be false again
      LinagoraEcosystemCache().clearCache();
      expect(LinagoraEcosystemCache().hasCachedEcosystem(testBaseUrl), isFalse);
    });
  });
}

class ApiUrlLinagoraEcosystem extends LinagoraEcosystemProperties {
  final String value;
  
  ApiUrlLinagoraEcosystem(this.value);
  
  @override
  List<Object?> get props => [value];
  
  @override
  bool? get stringify => true;
}