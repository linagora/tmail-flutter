import 'package:equatable/equatable.dart';

abstract class PermissionException with EquatableMixin implements Exception {
  final String? message;

  const PermissionException({this.message});

  String get exceptionName;

  @override
  String toString() {
    if (message != null) {
      return '$exceptionName: $message';
    }
    return exceptionName;
  }
}

class NotGrantedPermissionStorageException extends PermissionException {
  const NotGrantedPermissionStorageException()
      : super(message: 'Permission Storage has not been granted access');

  @override
  String get exceptionName => 'NotGrantedPermissionStorageException';

  @override
  List<Object?> get props => [message];
}
