
import 'package:equatable/equatable.dart';

abstract class PermissionException with EquatableMixin implements Exception {

  final String? message;

  const PermissionException({this.message});
}

class NotGrantedPermissionStorageException extends PermissionException {
  const NotGrantedPermissionStorageException() : super(message: 'Permission Storage has not been granted access');

  @override
  List<Object?> get props => [super.message];
}