import 'package:core/domain/exceptions/app_base_exception.dart';
import 'package:equatable/equatable.dart';

class AddressException extends AppBaseException with EquatableMixin {
  const AddressException(super.message);

  @override
  String get exceptionName => 'AddressException';

  @override
  List<Object?> get props => [message, exceptionName];
}
