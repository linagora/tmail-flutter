import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundForwardException extends AppBaseException {
  NotFoundForwardException([super.message]);

  @override
  String get exceptionName => 'NotFoundForwardException';
}

class UpdateForwardException extends AppBaseException {
  UpdateForwardException([super.message]);

  @override
  String get exceptionName => 'UpdateForwardException';
}

class RecipientListIsEmptyException extends AppBaseException {
  RecipientListIsEmptyException([super.message]);

  @override
  String get exceptionName => 'RecipientListIsEmptyException';
}

class RecipientListWithInvalidEmailsException extends AppBaseException {
  RecipientListWithInvalidEmailsException([super.message]);

  @override
  String get exceptionName => 'RecipientListWithInvalidEmailsException';
}
