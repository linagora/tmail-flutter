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

    test(
      'should parse a valid mailto URI encoded contains every possible parameters',
    () {
      // arrange
      const to1 = 'to1@example.com';
      const to2 = 'to2@example.com';
      const to3 = 'to3@example.com';
      const cc1 = 'cc1@example.com';
      const cc2 = 'cc2@example.com';
      const bcc1 = 'bcc1@example.com';
      const bcc2 = 'bcc2@example.com';
      const subject = 'Hello';
      const body = 'Bye';
      const mailtoSchemeUri = 'mailto:$to1,$to2'
        '?to=$to2,$to3'
        '&cc=$cc1,$cc2'
        '&bcc=$bcc1,$bcc2'
        '&subject=$subject'
        '&body=$body';

      const mailtoPathUri = 'https://example.com/mailto'
        '?uri=$to1,$to2'
        '&to=$to2,$to3'
        '&cc=$cc1,$cc2'
        '&bcc=$bcc1,$bcc2'
        '&subject=$subject'
        '&body=$body';

      const mailtoPathWithNestedMailtoUri = 'https://example.com/mailto/'
        '?uri=mailto:$to1,$to2'
        '&to=$to2,$to3'
        '&cc=$cc1,$cc2'
        '&bcc=$bcc1,$bcc2'
        '&subject=$subject'
        '&body=$body';

      // act
      final mailtoSchemeResult = RouteUtils.parseMapMailtoFromUri(
        Uri.encodeFull(mailtoSchemeUri));
      final mailtoPathResult = RouteUtils.parseMapMailtoFromUri(
        Uri.encodeFull(mailtoPathUri));
      final mailtoPathWithNestedMailtoResult = RouteUtils.parseMapMailtoFromUri(
        Uri.encodeFull(mailtoPathWithNestedMailtoUri));

      // assert
      expect(mailtoSchemeResult, equals(mailtoPathResult));
      expect(mailtoSchemeResult, equals(mailtoPathWithNestedMailtoResult));
      expect(mailtoPathResult, equals(mailtoPathWithNestedMailtoResult));

      expect(
        mailtoSchemeResult[RouteUtils.paramMailtoAddress],
        containsAll([to1, to2, to3,])
      );
      expect(
        mailtoSchemeResult[RouteUtils.paramCc],
        containsAll([cc1, cc2])
      );
      expect(
        mailtoSchemeResult[RouteUtils.paramBcc],
        containsAll([bcc1, bcc2])
      );
      expect(
        mailtoSchemeResult[RouteUtils.paramSubject],
        equals(subject)
      );
      expect(
        mailtoSchemeResult[RouteUtils.paramBody],
        equals(body)
      );
    });

    test(
      'should parse a valid mailto URI contains every possible parameters',
    () {
      // arrange
      const to1 = 'to1@example.com';
      const to2 = 'to2@example.com';
      const to3 = 'to3@example.com';
      const cc1 = 'cc1@example.com';
      const cc2 = 'cc2@example.com';
      const bcc1 = 'bcc1@example.com';
      const bcc2 = 'bcc2@example.com';
      const subject = 'Hello';
      const body = 'Bye';
      const mailtoSchemeUri = 'mailto:$to1,$to2'
        '?to=$to2,$to3'
        '&cc=$cc1,$cc2'
        '&bcc=$bcc1,$bcc2'
        '&subject=$subject'
        '&body=$body';

      const mailtoPathUri = 'https://example.com/mailto'
        '?uri=$to1,$to2'
        '&to=$to2,$to3'
        '&cc=$cc1,$cc2'
        '&bcc=$bcc1,$bcc2'
        '&subject=$subject'
        '&body=$body';

      const mailtoPathWithNestedMailtoUri = 'https://example.com/mailto/'
        '?uri=mailto:$to1,$to2'
        '&to=$to2,$to3'
        '&cc=$cc1,$cc2'
        '&bcc=$bcc1,$bcc2'
        '&subject=$subject'
        '&body=$body';

      // act
      final mailtoSchemeResult = RouteUtils.parseMapMailtoFromUri(
        mailtoSchemeUri);
      final mailtoPathResult = RouteUtils.parseMapMailtoFromUri(mailtoPathUri);
      final mailtoPathWithNestedMailtoResult = RouteUtils.parseMapMailtoFromUri(
        mailtoPathWithNestedMailtoUri);

      // assert
      expect(mailtoSchemeResult, equals(mailtoPathResult));
      expect(mailtoSchemeResult, equals(mailtoPathWithNestedMailtoResult));
      expect(mailtoPathResult, equals(mailtoPathWithNestedMailtoResult));

      expect(
        mailtoSchemeResult[RouteUtils.paramMailtoAddress],
        containsAll([to1, to2, to3,])
      );
      expect(
        mailtoSchemeResult[RouteUtils.paramCc],
        containsAll([cc1, cc2])
      );
      expect(
        mailtoSchemeResult[RouteUtils.paramBcc],
        containsAll([bcc1, bcc2])
      );
      expect(
        mailtoSchemeResult[RouteUtils.paramSubject],
        equals(subject)
      );
      expect(
        mailtoSchemeResult[RouteUtils.paramBody],
        equals(body)
      );
    });
  });
}