import 'package:equatable/equatable.dart';

class WorkplaceActionConfig with EquatableMixin {
  final String? label;

  const WorkplaceActionConfig({this.label});

  @override
  List<Object?> get props => [label];
}
