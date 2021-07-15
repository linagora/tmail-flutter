import 'package:equatable/equatable.dart';

class Password with EquatableMixin {
  final String value;

  Password(this.value);

  @override
  List<Object> get props => [value];
}