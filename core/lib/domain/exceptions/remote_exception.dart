
import 'package:equatable/equatable.dart';

abstract class RemoteException extends Equatable implements Exception {
  static const connectError = 'Connect error';

  final String? message;
  final int? code;

  const RemoteException({this.code, this.message});
}

class UnknownError extends RemoteException {
  const UnknownError({int? code, String? message}) : super(code: code, message: message);

  @override
  List<Object> get props => [];
}

class ConnectError extends RemoteException {
  const ConnectError() : super(message: RemoteException.connectError);

  @override
  List<Object> get props => [];
}