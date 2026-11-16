import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_cache_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_extension.dart';

void main() {
  test('toEmailCache().toEmail() keeps the raw List-Unsubscribe', () {
    final email = Email.fromJson({
      'id': 'e1',
      'header:List-Unsubscribe': ' <mailto:unsub@list.example.com>',
    });

    final restored = email.toEmailCache().toEmail();

    expect(restored.listUnsubscribe, contains('mailto:unsub@list.example.com'));
  });
}
