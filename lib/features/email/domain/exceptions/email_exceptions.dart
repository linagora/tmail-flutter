import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:core/domain/exceptions/app_base_exception.dart';

class NotFoundEmailException extends AppBaseException {
  NotFoundEmailException([super.message]);

  @override
  String get exceptionName => 'NotFoundEmailException';
}

class NotFoundEmailContentException extends AppBaseException {
  NotFoundEmailContentException([super.message]);

  @override
  String get exceptionName => 'NotFoundEmailContentException';
}

class EmptyEmailContentException extends AppBaseException {
  EmptyEmailContentException([super.message]);

  @override
  String get exceptionName => 'EmptyEmailContentException';
}

class NotFoundEmailRecoveryActionException extends AppBaseException {
  NotFoundEmailRecoveryActionException([super.message]);

  @override
  String get exceptionName => 'NotFoundEmailRecoveryActionException';
}

class NotFoundEmailBlobIdException extends AppBaseException {
  NotFoundEmailBlobIdException([super.message]);

  @override
  String get exceptionName => 'NotFoundEmailBlobIdException';
}

class CannotCreateEmailObjectException extends AppBaseException {
  CannotCreateEmailObjectException([super.message]);

  @override
  String get exceptionName => 'CannotCreateEmailObjectException';
}

class NotFoundBlobIdException extends AppBaseException {
  final List<Id> ids;

  NotFoundBlobIdException(this.ids) : super('Blob IDs: $ids');

  @override
  String get exceptionName => 'NotFoundBlobIdException';
}

class NotParsableBlobIdToEmailException extends AppBaseException {
  final List<Id>? ids;

  NotParsableBlobIdToEmailException({this.ids})
      : super(ids != null ? 'Blob IDs: $ids' : null);

  @override
  String get exceptionName => 'NotParsableBlobIdToEmailException';
}

class EmailIdsSuccessIsEmptyException extends AppBaseException {
  EmailIdsSuccessIsEmptyException([super.message]);

  @override
  String get exceptionName => 'EmailIdsSuccessIsEmptyException';
}
