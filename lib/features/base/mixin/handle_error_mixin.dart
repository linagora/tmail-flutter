import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/response/set_response.dart';
import 'package:model/error_type_handler/set_method_error_handler_mixin.dart';

mixin HandleSetErrorMixin {
  void handleSetErrors({
    SetMethodErrors? notDestroyedError,
    SetMethodErrors? notUpdatedError,
    SetMethodErrors? notCreatedError,
    Set<SetMethodErrorHandler>? notDestroyedHandlers,
    Set<SetMethodErrorHandler>? notUpdatedHandlers,
    Set<SetMethodErrorHandler>? notCreatedHandlers,
    SetMethodErrorHandler? unCatchErrorHandler
  }) {
    if (notDestroyedError != null && notDestroyedError.isNotEmpty) {
      notDestroyedError.entries
        .map((e) => _handleInChain(e, notDestroyedHandlers))
        .map((optionError) => _handleRemainedError(unCatchErrorHandler, optionError))
        .toSet();
    }

    if (notCreatedError != null && notCreatedError.isNotEmpty) {
      notCreatedError.entries
        .map((e) => _handleInChain(e, notCreatedHandlers))
        .map((optionError) => _handleRemainedError(unCatchErrorHandler, optionError))
        .toSet();
    }

    if (notUpdatedError != null && notUpdatedError.isNotEmpty) {
      notUpdatedError.entries
        .map((e) => _handleInChain(e, notUpdatedHandlers))
        .map((optionError) => _handleRemainedError(unCatchErrorHandler, optionError))
        .toSet();
    }
  }

  Option<MapEntry<Id, SetError>> _handleInChain(MapEntry<Id, SetError> setError, Set<SetMethodErrorHandler>? handlers) {
    try {
      handlers!.firstWhere((handler) => handler.call(setError));
      return const None<MapEntry<Id, SetError>>();
    } catch (e) {
      logError('HandleSetErrorMixin::chainHandle(): [Exception] $e');
      return Some<MapEntry<Id, SetError>>(setError);
    }
  }

  void _handleRemainedError(SetMethodErrorHandler? unCatchErrorHandler, Option<MapEntry<Id, SetError>> optionError) {
    final remainedError = optionError.toNullable();
    if (remainedError != null) {
      logError('HandleSetErrorMixin::_handleRemainedError(): $remainedError');
      unCatchErrorHandler?.call(remainedError);
    }
  }

  Map<Id, SetError> handleSetResponse(List<SetResponse?> listSetResponse) {
    final listSetResponseNotNull = listSetResponse.nonNulls.toList();
    if (listSetResponseNotNull.isEmpty) {
      return <Id, SetError>{};
    }

    final Map<Id, SetError> remainedErrors = <Id, SetError>{};
    for (var response in listSetResponseNotNull) {
      handleSetErrors(
        notDestroyedError: response.notDestroyed,
        notUpdatedError: response.notUpdated,
        notCreatedError: response.notCreated,
        unCatchErrorHandler: (setErrorEntry) {
          remainedErrors.addEntries({setErrorEntry});
          return false;
        }
      );
    }
    logError('HandleSetErrorMixin::handleSetResponse():remainedErrors: $remainedErrors');
    return remainedErrors;
  }
}
