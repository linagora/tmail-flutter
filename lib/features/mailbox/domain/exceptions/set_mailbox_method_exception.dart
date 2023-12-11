
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

class SetMailboxMethodException implements Exception {

  final Map<Id, SetError> mapErrors;

  SetMailboxMethodException(this.mapErrors);
}

class NotFoundMailboxCreatedException implements Exception {}

class NotFoundMailboxUpdatedRoleException implements Exception {}

class NotFoundMailboxByRoleException implements Exception {}

class NotFoundMailboxByNameException implements Exception {}