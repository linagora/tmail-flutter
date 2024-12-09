
import 'package:core/data/network/config/service_path.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/data/extensions/service_path_extension.dart';

void main() {
  group('ServicePathExtension::test', () {
    test('Should correctly combines baseUrl and path without trailing or leading slashes', () {
      final servicePath = ServicePath('/api/v1/resource');
      final result = servicePath.usingBaseUrl('https://example.com');
      expect(result.path, 'https://example.com/api/v1/resource');
    });

    test('Should handles baseUrl with trailing slash', () {
      final servicePath = ServicePath('/api/v1/resource');
      final result = servicePath.usingBaseUrl('https://example.com/');
      expect(result.path, 'https://example.com/api/v1/resource');
    });

    test('Should handles path without leading slash', () {
      final servicePath = ServicePath('api/v1/resource');
      final result = servicePath.usingBaseUrl('https://example.com');
      expect(result.path, 'https://example.com/api/v1/resource');
    });

    test('Should handles both baseUrl with trailing slash and path without leading slash', () {
      final servicePath = ServicePath('api/v1/resource');
      final result = servicePath.usingBaseUrl('https://example.com/');
      expect(result.path, 'https://example.com/api/v1/resource');
    });

    test('Should handles both baseUrl without trailing slash and path with leading slash', () {
      final servicePath = ServicePath('/api/v1/resource');
      final result = servicePath.usingBaseUrl('https://example.com');
      expect(result.path, 'https://example.com/api/v1/resource');
    });

    test('Should handles empty path', () {
      final servicePath = ServicePath('');
      final result = servicePath.usingBaseUrl('https://example.com');
      expect(result.path, 'https://example.com/');
    });

    test('Should handles empty baseUrl', () {
      final servicePath = ServicePath('/api/v1/resource');
      final result = servicePath.usingBaseUrl('');
      expect(result.path, '/api/v1/resource');
    });

    test('Should handles both baseUrl and path being empty', () {
      final servicePath = ServicePath('');
      final result = servicePath.usingBaseUrl('');
      expect(result.path, '/');
    });
  });
}
