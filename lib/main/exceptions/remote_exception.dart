
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
  static const sendTimeout = 'Send data timeout';
  static const receiveTimeout = 'Receive data timeout';

  final Object? message;
  final int? code;

  const RemoteException({this.code, this.message});

  @override
  List<Object?> get props => [message, code];
}

class BadCredentialsException extends RemoteException {
  const BadCredentialsException() : super(message: RemoteException.badCredentials);
}

class UnknownError extends RemoteException {
  const UnknownError({int? code, Object? message}) : super(code: code, message: message);
}

class ConnectionError extends RemoteException {
  const ConnectionError({String? message}) : super(message: message ?? RemoteException.connectionError);
}

class ConnectionTimeout extends RemoteException {
  const ConnectionTimeout({String? message}) : super(message: message ?? RemoteException.connectionTimeout);
}

class SocketError extends RemoteException {
  const SocketError() : super(message: RemoteException.socketException);
}

class InternalServerError extends RemoteException {
  const InternalServerError() : super(message: RemoteException.internalServerError);
}

class MethodLevelErrors extends RemoteException {
  final ErrorType type;

  const MethodLevelErrors(
    this.type,
    {String? message}
  ) : super(message: message);

  @override
  List<Object?> get props => [type, ...super.props];
}

class CannotCalculateChangesMethodResponseException extends MethodLevelErrors {
  CannotCalculateChangesMethodResponseException({String? message}) : super(ErrorMethodResponse.cannotCalculateChanges, message: message);
}

class NoNetworkError extends RemoteException {
  const NoNetworkError() : super(message: RemoteException.noNetworkError);
}