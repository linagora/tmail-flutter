import 'package:equatable/equatable.dart';

class HexColor with EquatableMixin {
  final String value;

  HexColor(this.value);

  @override
  List<Object> get props => [value];
}
