import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';

class SetMailboxNameException implements Exception {
  static const emptyMailboxNameDescription = 'has an empty part within its mailbox name';
  static const mailboxNameContainsInvalidCharactersDescription = 'contains one of the forbidden characters';

  static SetMailboxNameException detectMailboxNameException(Object exception, MailboxId mailboxId) {
    if (exception is SetMethodException) {
      final setError = exception.mapErrors[mailboxId.id];
      if (setError == null) {
        return SetMailboxNameException();
      }

      final errorDescription = setError.description;
      if (errorDescription == null || errorDescription.isEmpty) {
        return SetMailboxNameException();
      }

      if (errorDescription.contains(emptyMailboxNameDescription)) {
        return EmptyMailboxNameException();
      } else if (errorDescription.contains(mailboxNameContainsInvalidCharactersDescription)) {
        return ContainsInvalidCharactersMailboxNameException();
      }
      return SetMailboxNameException();
    }
    return SetMailboxNameException();
  }
}

class EmptyMailboxNameException implements SetMailboxNameException {}

class ContainsInvalidCharactersMailboxNameException implements SetMailboxNameException {}
