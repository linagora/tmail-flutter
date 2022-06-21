
import 'package:equatable/equatable.dart';

abstract class RemoteException extends Equatable implements Exception {

  final String? message;

  RemoteException(this.message);
}

class UnknownError extends RemoteException {
  UnknownError(String? message) : super(message);

  @override
  List<Object> get props => [];
}