
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

class SetMethodException implements Exception {

  final Map<Id, SetError> mapErrors;

  SetMethodException(this.mapErrors);
}