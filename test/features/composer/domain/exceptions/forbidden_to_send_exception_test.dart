import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/forbidden_to_send_exception.dart';

void main() {
  group('ForbiddenToSendException', () {
    test('SHOULD be named for logs', () {
      expect(ForbiddenToSendException().exceptionName, 'ForbiddenToSendException');
    });

    test('SHOULD tell exceptions apart by the email the server created', () {
      expect(
        ForbiddenToSendException(createdEmailId: EmailId(Id('email-1'))),
        ForbiddenToSendException(createdEmailId: EmailId(Id('email-1'))),
      );
      expect(
        ForbiddenToSendException(createdEmailId: EmailId(Id('email-1'))),
        isNot(ForbiddenToSendException()),
      );
    });
  });
}
