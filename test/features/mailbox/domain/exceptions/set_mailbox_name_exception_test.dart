import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/set_mailbox_name_exception.dart';

void main() {
  group('SetMailboxNameException', () {
    final mailboxId = MailboxId(Id('mailboxId'));

    test('should return SetMailboxNameException when exception is not SetMethodException', () {
      final exception = Exception('Some other exception');

      final result = SetMailboxNameException.detectMailboxNameException(exception, mailboxId);
      expect(result, isA<SetMailboxNameException>());
    });

    test('should return SetMailboxNameException when error is SetMailboxException without details', () {
      final setMethodException = SetMethodException({});

      final result = SetMailboxNameException.detectMailboxNameException(setMethodException, mailboxId);
      expect(result, isA<SetMailboxNameException>());
    });

    test('should return SetMailboxException when errorDescription is null', () {
      final setMethodException = SetMethodException({
        mailboxId.id: SetError(SetError.invalidArguments, description: null)
      });

      final result = SetMailboxNameException.detectMailboxNameException(setMethodException, mailboxId);
      expect(result, isA<SetMailboxNameException>());
    });

    test('should return SetMailboxException when errorDescription is empty', () {
      final setMethodException = SetMethodException({
        mailboxId.id: SetError(SetError.invalidArguments, description: '')
      });

      final result = SetMailboxNameException.detectMailboxNameException(setMethodException, mailboxId);
      expect(result, isA<SetMailboxNameException>());
    });

    test('should return EmptyMailboxNameException when errorDescription contains emptyMailboxNameDescription', () {
      final setMethodException = SetMethodException({
        mailboxId.id: SetError(SetError.invalidArguments, description: '    \' has an empty part within its mailbox name considering      as a delimiter')
      });

      final result = SetMailboxNameException.detectMailboxNameException(setMethodException, mailboxId);
      expect(result, isA<EmptyMailboxNameException>());
    });

    test('should return ContainsInvalidCharactersMailboxNameException when errorDescription contains mailboxNameContainsInvalidCharactersDescription', () {
      final setMethodException = SetMethodException({
        mailboxId.id: SetError(SetError.invalidArguments, description: '#hello contains one of the forbidden characters or starts with #')
      });

      final result = SetMailboxNameException.detectMailboxNameException(setMethodException, mailboxId);
      expect(result, isA<ContainsInvalidCharactersMailboxNameException>());
    });

    test('should return SetMailboxNameException when errorDescription does not contain specific descriptions', () {
      final setMethodException = SetMethodException({
        mailboxId.id: SetError(SetError.invalidArguments, description: 'Some other description')
      });

      final result = SetMailboxNameException.detectMailboxNameException(setMethodException, mailboxId);
      expect(result, isA<SetMailboxNameException>());
    });
  });
}