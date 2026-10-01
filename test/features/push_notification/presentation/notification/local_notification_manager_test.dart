import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_config.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/notification/local_notification_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalNotificationManager.buildInboxStyleInformation', () {
    test('escapes an HTML payload in the title', () {
      final style = LocalNotificationManager.buildInboxStyleInformation(
        title: '<img src=x onerror=alert(1)>',
      );

      expect(style.contentTitle, isNot(contains('<img')));
      expect(style.contentTitle, contains('&lt;img'));
    });

    test('escapes an HTML payload in the message', () {
      final style = LocalNotificationManager.buildInboxStyleInformation(
        title: 'Subject',
        message: '<script>alert(1)</script>',
      );

      expect(style.lines.first, isNot(contains('<script>')));
      expect(style.lines.first, contains('&lt;script&gt;'));
    });

    test('shows the sender address before the unaltered display name', () {
      final style = LocalNotificationManager.buildInboxStyleInformation(
        title: 'Subject',
        emailAddress: EmailAddress('IT department', 'attacker@evil.example'),
      );

      expect(style.summaryText, equals('<b>attacker@evil.example (IT department)</b>'));
    });

    test('keeps the sender address first with a long display name', () {
      final style = LocalNotificationManager.buildInboxStyleInformation(
        title: 'Subject',
        emailAddress: EmailAddress(
          'IT Department - Password Reset Required For Your Account',
          'attacker@evil.example',
        ),
      );

      expect(
        style.summaryText,
        equals('<b>attacker@evil.example (IT Department - Password Reset Required For Your Account)</b>'),
      );
    });

    test('does not repeat a display name equal to the address', () {
      final style = LocalNotificationManager.buildInboxStyleInformation(
        title: 'Subject',
        emailAddress: EmailAddress('bob@example.com', 'bob@example.com'),
      );

      expect(style.summaryText, equals('<b>bob@example.com</b>'));
    });

    test('shows the display name alone when there is no address', () {
      final style = LocalNotificationManager.buildInboxStyleInformation(
        title: 'Subject',
        emailAddress: EmailAddress('Bob', null),
      );

      expect(style.summaryText, equals('<b>Bob</b>'));
    });

    test('shows the address alone when there is no display name', () {
      final style = LocalNotificationManager.buildInboxStyleInformation(
        title: 'Subject',
        emailAddress: EmailAddress(null, 'bob@example.com'),
      );

      expect(style.summaryText, equals('<b>bob@example.com</b>'));
    });

    test('leaves the sender line empty without a sender', () {
      final style = LocalNotificationManager.buildInboxStyleInformation(
        title: 'Subject',
      );

      expect(style.summaryText, equals('<b></b>'));
    });

    test('escapes a spoofed display name', () {
      final style = LocalNotificationManager.buildInboxStyleInformation(
        title: 'Subject',
        emailAddress: EmailAddress('<img src=x onerror=alert(1)>', 'attacker@evil.example'),
      );

      expect(style.summaryText, isNot(contains('<img')));
      expect(style.summaryText, contains('&lt;img'));
    });

    test('escapes an ampersand in the title', () {
      final style = LocalNotificationManager.buildInboxStyleInformation(
        title: 'R&D',
      );

      expect(style.contentTitle, equals('R&amp;D'));
    });

    test('gives an empty line without a message', () {
      final style = LocalNotificationManager.buildInboxStyleInformation(
        title: 'Subject',
      );

      expect(style.lines, equals(['']));
    });
  });

  group('LocalNotificationConfig.generateNotificationDetails', () {
    test('uses private lock-screen visibility on Android', () {
      expect(
        LocalNotificationConfig.instance.generateNotificationDetails().android?.visibility,
        NotificationVisibility.private,
      );
    });
  });

  group('LocalNotificationManager.showPushNotification', () {
    const channel = MethodChannel('dexterous.com/flutter/local_notifications');
    final calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return null;
      });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('posts an escaped, private notification', () async {
      await LocalNotificationManager.instance.showPushNotification(
        id: 'e1',
        title: 'R&D <b>',
        message: '<script>x</script>',
        emailAddress: EmailAddress('IT department', 'attacker@evil.example'),
      );

      final android = (calls.single.arguments as Map)['platformSpecifics'] as Map;
      final style = android['styleInformation'] as Map;
      expect(android['visibility'], NotificationVisibility.private.index);
      expect(style['contentTitle'], 'R&amp;D &lt;b&gt;');
      expect(style['lines'], ['<p style="color:#6D7885;">&lt;script&gt;x&lt;&#47;script&gt;</p>']);
      expect(style['summaryText'], '<b>attacker@evil.example (IT department)</b>');
    });
  });
}
