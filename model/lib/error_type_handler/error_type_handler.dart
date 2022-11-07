import 'package:jmap_dart_client/jmap/core/error/error_type.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
typedef Error = Map<Id, SetError>;

class ErrorTypeHandler {
  final ErrorType errorType;
  final Function(Error) handler;

  ErrorTypeHandler(
    this.errorType,
    this.handler,
  );
}

class NotFoundErrorTypeHandler extends ErrorTypeHandler {
  NotFoundErrorTypeHandler({required Function(Error) handler}) : super(SetError.notFound, handler);
}
