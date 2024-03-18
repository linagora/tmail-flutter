import 'package:equatable/equatable.dart';

class AddressException with EquatableMixin implements Exception {
  final String message;

  AddressException(this.message);

  @override
  String toString() => message;

  @override
  List<Object> get props => [message];
}
