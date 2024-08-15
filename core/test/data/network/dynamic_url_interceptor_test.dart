import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('setJmapUrl test', () {
    test('should set jmapUrl to the full URI', () {
      final dynamicUrlInterceptors = DynamicUrlInterceptors();
      const fullUri = 'https://example.com/basicauth';

      dynamicUrlInterceptors.setJmapUrl(fullUri);

      expect(dynamicUrlInterceptors.jmapUrl, equals(fullUri));
    });

    test('should set jmapUrl to the full URI when url have multiple sub-paths', () {
      final dynamicUrlInterceptors = DynamicUrlInterceptors();
      const fullUri = 'https://example.com/basicauth/jmap';

      dynamicUrlInterceptors.setJmapUrl(fullUri);

      expect(dynamicUrlInterceptors.jmapUrl, equals(fullUri));
    });

    test('should set jmapUrl to the full URI when url have no sub-paths', () {
      final dynamicUrlInterceptors = DynamicUrlInterceptors();
      const fullUri = 'https://example.com';

      dynamicUrlInterceptors.setJmapUrl(fullUri);

      expect(dynamicUrlInterceptors.jmapUrl, equals(fullUri));
    });

    test('should set jmapUrl to the full URI when url have port and sub-paths', () {
      final dynamicUrlInterceptors = DynamicUrlInterceptors();
      const fullUri = 'https://example.com:8080/basicauth/jmap/';

      dynamicUrlInterceptors.setJmapUrl(fullUri);

      expect(dynamicUrlInterceptors.jmapUrl, equals(fullUri));
    });
  });

  group('changeBaseUrl test', () {
    test('should set baseUrl to the full URI', () {
      final dynamicUrlInterceptors = DynamicUrlInterceptors();
      const fullUri = 'https://example.com/basicauth';

      dynamicUrlInterceptors.changeBaseUrl(fullUri);

      expect(dynamicUrlInterceptors.baseUrl, equals(fullUri));
    });

    test('should set baseUrl to the full URI when url have multiple sub-paths', () {
      final dynamicUrlInterceptors = DynamicUrlInterceptors();
      const fullUri = 'https://example.com/basicauth/jmap';

      dynamicUrlInterceptors.changeBaseUrl(fullUri);

      expect(dynamicUrlInterceptors.baseUrl, equals(fullUri));
    });

    test('should set baseUrl to the full URI when url have no sub-paths', () {
      final dynamicUrlInterceptors = DynamicUrlInterceptors();
      const fullUri = 'https://example.com';

      dynamicUrlInterceptors.changeBaseUrl(fullUri);

      expect(dynamicUrlInterceptors.baseUrl, equals(fullUri));
    });

    test('should set baseUrl to the full URI when url have port and sub-paths', () {
      final dynamicUrlInterceptors = DynamicUrlInterceptors();
      const fullUri = 'https://example.com:8080/basicauth/jmap/';

      dynamicUrlInterceptors.changeBaseUrl(fullUri);

      expect(dynamicUrlInterceptors.baseUrl, equals(fullUri));
    });
  });
}