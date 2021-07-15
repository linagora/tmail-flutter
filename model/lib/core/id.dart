import 'package:equatable/equatable.dart';
import 'package:quiver/check.dart';

class Id with EquatableMixin {
  final RegExp _idCharacterConstraint = RegExp(r'^[a-zA-Z0-9]+[a-zA-Z0-9-_]*$');
  final String value;
  
  Id(this.value) {
    checkArgument(value.isNotEmpty, message: 'invalid length');
    checkArgument(value.length < 255, message: 'invalid length');
    checkArgument(_idCharacterConstraint.hasMatch(value));
  }

  @override
  List<Object?> get props => [value];
}