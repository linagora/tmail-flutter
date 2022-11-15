
import 'package:equatable/equatable.dart';

class TypeName with EquatableMixin {

  final String value;

  TypeName(this.value);

  @override
  List<Object?> get props => [value];
}