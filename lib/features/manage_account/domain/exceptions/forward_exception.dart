import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundForwardException extends AppBaseException {
  const NotFoundForwardException([super.message]);

  @override
  String get exceptionName => 'NotFoundForwardException';
}

class UpdateForwardException extends AppBaseException {
  const UpdateForwardException([super.message]);

  @override
  String get exceptionName => 'UpdateForwardException';
}

class RecipientListIsEmptyException extends AppBaseException {
  const RecipientListIsEmptyException([super.message]);

  @override
  String get exceptionName => 'RecipientListIsEmptyException';
}

class RecipientListWithInvalidEmailsException extends AppBaseException {
  const RecipientListWithInvalidEmailsException([super.message]);

  @override
  String get exceptionName => 'RecipientListWithInvalidEmailsException';
}
