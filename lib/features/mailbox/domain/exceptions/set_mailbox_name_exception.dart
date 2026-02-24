import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:core/domain/exceptions/app_base_exception.dart';

class SetMailboxNameException extends AppBaseException {
  static const emptyMailboxNameDescription =
      'has an empty part within its mailbox name';
  static const mailboxNameContainsInvalidCharactersDescription =
      'contains one of the forbidden characters';

  SetMailboxNameException([super.message]);

  @override
  String get exceptionName => 'SetMailboxNameException';

  static SetMailboxNameException detectMailboxNameException(
      Object exception, MailboxId mailboxId) {
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
      } else if (errorDescription
          .contains(mailboxNameContainsInvalidCharactersDescription)) {
        return ContainsInvalidCharactersMailboxNameException();
      }
      return SetMailboxNameException(errorDescription);
    }
    return SetMailboxNameException();
  }
}

class EmptyMailboxNameException extends SetMailboxNameException {
  EmptyMailboxNameException()
      : super(SetMailboxNameException.emptyMailboxNameDescription);

  @override
  String get exceptionName => 'EmptyMailboxNameException';
}

class ContainsInvalidCharactersMailboxNameException
    extends SetMailboxNameException {
  ContainsInvalidCharactersMailboxNameException()
      : super(SetMailboxNameException
            .mailboxNameContainsInvalidCharactersDescription);

  @override
  String get exceptionName => 'ContainsInvalidCharactersMailboxNameException';
}
