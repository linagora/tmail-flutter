import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_utils.dart';

void main() {
  group('parseMapMailtoFromUri test', () {
    test('should parse a valid mailto URI', () {
      const mailtoUri = 'mailto:test@example.com?subject=Hello';
      final result = RouteUtils.parseMapMailtoFromUri(mailtoUri);

      expect(result[RouteUtils.paramRouteName], equals(AppRoutes.mailtoURL));
      expect(result[RouteUtils.paramMailtoAddress], equals('test@example.com'));
      expect(result[RouteUtils.paramSubject], equals('Hello'));
    });

    test('should parse a valid mailto URI encoded', () {
      const mailtoUri = 'mailto:test%40example.com%3Fsubject=Hello';
      final result = RouteUtils.parseMapMailtoFromUri(mailtoUri);

      expect(result[RouteUtils.paramRouteName], equals(AppRoutes.mailtoURL));
      expect(result[RouteUtils.paramMailtoAddress], equals('test@example.com'));
      expect(result[RouteUtils.paramSubject], equals('Hello'));
    });

    test('should handle a mailto URI without subject', () {
      const mailtoUri = 'mailto:test@example.com';
      final result = RouteUtils.parseMapMailtoFromUri(mailtoUri);

      expect(result[RouteUtils.paramRouteName], equals(AppRoutes.mailtoURL));
      expect(result[RouteUtils.paramMailtoAddress], equals('test@example.com'));
      expect(result[RouteUtils.paramSubject], isNull);
    });

    test('should handle a mailto URI without subject encoded', () {
      const mailtoUri = 'mailto:test%40example.com';
      final result = RouteUtils.parseMapMailtoFromUri(mailtoUri);

      expect(result[RouteUtils.paramRouteName], equals(AppRoutes.mailtoURL));
      expect(result[RouteUtils.paramMailtoAddress], equals('test@example.com'));
      expect(result[RouteUtils.paramSubject], isNull);
    });

    test('should handle a non-mailto URI', () {
      const nonMailtoUri = 'test@example.com';
      final result = RouteUtils.parseMapMailtoFromUri(nonMailtoUri);

      expect(result[RouteUtils.paramRouteName], equals(AppRoutes.mailtoURL));
      expect(result[RouteUtils.paramMailtoAddress], equals(nonMailtoUri));
      expect(result[RouteUtils.paramSubject], isNull);
    });

    test('should handle a non-mailto URI encoded', () {
      const nonMailtoUri = 'test%40example.com';
      final result = RouteUtils.parseMapMailtoFromUri(nonMailtoUri);

      expect(result[RouteUtils.paramRouteName], equals(AppRoutes.mailtoURL));
      expect(result[RouteUtils.paramMailtoAddress], equals('test@example.com'));
      expect(result[RouteUtils.paramSubject], isNull);
    });

    test('should handle null input', () {
      final result = RouteUtils.parseMapMailtoFromUri(null);

      expect(result[RouteUtils.paramRouteName], equals(AppRoutes.mailtoURL));
      expect(result[RouteUtils.paramMailtoAddress], isNull);
      expect(result[RouteUtils.paramSubject], isNull);
    });

    test('should parse a valid mailto URI encoded contains multiple recipients', () {
      const mailtoUri = 'mailto:test%40example.com%2Ctest2%40example.com%2Ctest3%40example.com%3Fsubject=Hello';
      final result = RouteUtils.parseMapMailtoFromUri(mailtoUri);

      expect(result[RouteUtils.paramRouteName], equals(AppRoutes.mailtoURL));
      expect(result[RouteUtils.paramMailtoAddress], containsAll(['test@example.com', 'test2@example.com', 'test3@example.com']));
      expect(result[RouteUtils.paramSubject], equals('Hello'));
    });

    test('should parse a valid mailto URI contains multiple recipients', () {
      const mailtoUri = 'mailto:test@example.com,test2@example.com,test3@example.com?subject=Hello';
      final result = RouteUtils.parseMapMailtoFromUri(mailtoUri);

      expect(result[RouteUtils.paramRouteName], equals(AppRoutes.mailtoURL));
      expect(result[RouteUtils.paramMailtoAddress], containsAll(['test@example.com', 'test2@example.com', 'test3@example.com']));
      expect(result[RouteUtils.paramSubject], equals('Hello'));
    });
  });
}