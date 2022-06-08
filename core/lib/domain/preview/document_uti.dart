import 'package:equatable/equatable.dart';

class DocumentUti with EquatableMixin{
  final String? value;

  DocumentUti(this.value);

  @override
  List<Object?> get props => [value];
}
