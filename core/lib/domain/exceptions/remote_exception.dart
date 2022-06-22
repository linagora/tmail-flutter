
import 'package:equatable/equatable.dart';

abstract class RemoteException extends Equatable implements Exception {
  static final connectError = 'Connect error';

  final String? message;
  final int? code;

  RemoteException({this.code, this.message});
}

class UnknownError extends RemoteException {
  UnknownError({int? code, String? message}) : super(code: code, message: message);

  @override
  List<Object> get props => [];
}

class ConnectError extends RemoteException {
  ConnectError() : super(message: RemoteException.connectError);

  @override
  List<Object> get props => [];
}