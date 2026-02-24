import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:core/domain/exceptions/app_base_exception.dart';

class SetMethodException extends AppBaseException {
  final Map<Id, SetError> mapErrors;

  SetMethodException(this.mapErrors) : super('Errors: $mapErrors');

  @override
  String get exceptionName => 'SetMethodException';
}
