
import 'package:equatable/equatable.dart';

class NewNameRequest with EquatableMixin {
  final String? value;

  NewNameRequest(this.value);

  @override
  List<Object?> get props => [value];
}