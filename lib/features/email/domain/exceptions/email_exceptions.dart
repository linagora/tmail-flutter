import 'package:jmap_dart_client/jmap/core/id.dart';

class NotFoundEmailException implements Exception {}

class NotFoundEmailContentException implements Exception {}

class EmptyEmailContentException implements Exception {}

class NotFoundEmailRecoveryActionException implements Exception {}

class NotFoundEmailBlobIdException implements Exception {}

class CannotCreateEmailObjectException implements Exception {}

class NotFoundBlobIdException implements Exception {
  final List<Id> ids;

  NotFoundBlobIdException(this.ids);
}

class NotParsableBlobIdToEmailException implements Exception {
  final List<Id>? ids;

  NotParsableBlobIdToEmailException({this.ids});
}