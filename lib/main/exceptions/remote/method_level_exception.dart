import 'package:jmap_dart_client/jmap/core/error/error_type.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';
import 'package:tmail_ui_user/main/exceptions/remote/remote_exception.dart';

class MethodLevelErrors extends RemoteException {
  final ErrorType type;

  const MethodLevelErrors(
    this.type, {
    String? message,
  }) : super(message: message);

  @override
  String get exceptionName => 'MethodLevelErrors';

  @override
  String toString() {
    return '$exceptionName(type: $type): $message';
  }

  @override
  List<Object?> get props => [type, ...super.props];
}

class CannotCalculateChangesMethodResponseException extends MethodLevelErrors {
  CannotCalculateChangesMethodResponseException({String? message})
      : super(
          ErrorMethodResponse.cannotCalculateChanges,
          message: message,
        );

  @override
  String get exceptionName => 'CannotCalculateChangesMethodResponseException';
}
