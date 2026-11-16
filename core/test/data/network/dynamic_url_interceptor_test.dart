import 'package:dio/dio.dart';
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

  group('onRequest test', () {
    const jmapUrl = 'https://example.com/basicauth';
    const apiUrl = 'https://example.com/basicauth/jmap';

    RequestOptions sendThrough(DynamicUrlInterceptors interceptors, String path) {
      final options = RequestOptions(path: path, baseUrl: 'https://unset.example.com');
      interceptors.onRequest(options, RequestInterceptorHandler());
      return options;
    }

    DynamicUrlInterceptors interceptorsAfterSessionLoad() => DynamicUrlInterceptors()
      ..setJmapUrl(jmapUrl)
      ..changeBaseUrl(apiUrl);

    test('should send the session request to the jmap url after the base moved to the api url', () {
      expect(sendThrough(interceptorsAfterSessionLoad(), '/.well-known/jmap').baseUrl, jmapUrl);
    });

    test('should send any other request to the api url', () {
      expect(sendThrough(interceptorsAfterSessionLoad(), '/upload').baseUrl, apiUrl);
    });

    test('should send the session request to the base url when no jmap url is set', () {
      final interceptors = DynamicUrlInterceptors()..changeBaseUrl(apiUrl);

      expect(sendThrough(interceptors, '/.well-known/jmap').baseUrl, apiUrl);
    });

    test('should keep the request base url when no url is set', () {
      expect(sendThrough(DynamicUrlInterceptors(), '/.well-known/jmap').baseUrl, 'https://unset.example.com');
    });
  });
}
