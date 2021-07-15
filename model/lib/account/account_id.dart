import 'package:equatable/equatable.dart';
import 'package:model/core/id.dart';

class AccountId with EquatableMixin {
  final Id id;

  AccountId(this.id);

  @override
  List<Object?> get props => [id];
}