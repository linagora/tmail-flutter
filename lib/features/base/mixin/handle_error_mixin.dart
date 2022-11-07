import 'package:model/error_type_handler/error_type_handler.dart';

mixin HandleErrorMixin {
  void handleError({
    required Error error,
    required Set<ErrorTypeHandler> errorDefineHandlers,
    Function(Error error)? errorUndefineHandlers,
  }) {
    final errorTypesNeedHandle = error.values.map((e) => e.type).toSet();
    final errorTypesUnHandle = errorTypesNeedHandle.difference(errorDefineHandlers.map((e) => e.errorType).toSet());

    if (errorTypesUnHandle.isNotEmpty) {
      errorUndefineHandlers?.call(error);
    } else {
      final errorCanHandle = errorDefineHandlers.where((e) => (errorTypesNeedHandle.contains(e.errorType))).toList();
      for (final e in errorCanHandle) {
        e.handler.call(error);
      }
    }
  }
}
