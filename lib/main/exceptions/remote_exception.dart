import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/error/error_type.dart';
import 'package:jmap_dart_client/jmap/core/error/method/error_method_response.dart';

abstract class RemoteException with EquatableMixin implements Exception {
  static const connectionTimeout = 'Connection Timeout';
  static const connectionError = 'Connection error';
  static const internalServerError = 'Internal Server Error';
  static const noNetworkError = 'No network error';
  static const badCredentials = 'Bad credentials';
  static const socketException = 'Socket exception';

  final Object? message;
  final int? code;

  const RemoteException({this.code, this.message});

  String get exceptionName;

  @override
  String toString() {
    if (code != null) {
      return '$exceptionName(code: $code): $message';
    }
    return '$exceptionName: $message';
  }

  @override
  List<Object?> get props => [message, code];
}

class BadCredentialsException extends RemoteException {
  const BadCredentialsException()
      : super(message: RemoteException.badCredentials);

  @override
  String get exceptionName => 'BadCredentialsException';
}

class UnknownError extends RemoteException {
  const UnknownError({int? code, Object? message})
      : super(code: code, message: message);

  @override
  String get exceptionName => 'UnknownError';
}

class ConnectionError extends RemoteException {
  const ConnectionError({String? message})
      : super(message: message ?? RemoteException.connectionError);

  @override
  String get exceptionName => 'ConnectionError';
}

class ConnectionTimeout extends RemoteException {
  const ConnectionTimeout({String? message})
      : super(message: message ?? RemoteException.connectionTimeout);

  @override
  String get exceptionName => 'ConnectionTimeout';
}

class SocketError extends RemoteException {
  const SocketError() : super(message: RemoteException.socketException);

  @override
  String get exceptionName => 'SocketError';
}

class InternalServerError extends RemoteException {
  const InternalServerError()
      : super(message: RemoteException.internalServerError);

  @override
  String get exceptionName => 'InternalServerError';
}

class MethodLevelErrors extends RemoteException {
  final ErrorType type;

  const MethodLevelErrors(this.type, {String? message})
      : super(message: message);

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
      : super(ErrorMethodResponse.cannotCalculateChanges, message: message);

  @override
  String get exceptionName => 'CannotCalculateChangesMethodResponseException';
}

class NoNetworkError extends RemoteException {
  const NoNetworkError() : super(message: RemoteException.noNetworkError);

  @override
  String get exceptionName => 'NoNetworkError';
}

class RefreshTokenFailedException extends RemoteException {

  RefreshTokenFailedException({
    int code = 400,
    Object? message
  }) : super(
    code: code,
    message: message ?? 
      'Refresh Token failed with status $code. The session is invalid/revoked.',
);

  @override
  String get exceptionName => 'RefreshTokenFailedException';

  @override
  String toString() => "$exceptionName(status: $code): $message";
}
