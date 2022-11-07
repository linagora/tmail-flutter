import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';

mixin ErrorHandleMixin {
  void remoteHandleError({
    required Map<Id,SetError> errors,
    Function(Map<Id,SetError>)? handleNotFoundError,
    Function(Map<Id,SetError>)? handleUnKnowErrorNotFound,
  }) {

    final errorTypes = errors.values.map((e) => e.type);

    if (errorTypes.contains(SetError.notFound)) {
      handleNotFoundError?.call(errors);
      return;
    } else {
      handleUnKnowErrorNotFound?.call(errors);
      return;
    }
  }
}
