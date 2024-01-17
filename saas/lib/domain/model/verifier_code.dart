
import 'package:equatable/equatable.dart';

class VerifierCode with EquatableMixin {
  final String value;

  const VerifierCode(this.value);

  @override
  List<Object?> get props => [value];
}