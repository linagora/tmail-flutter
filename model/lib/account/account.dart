import 'package:equatable/equatable.dart';
import 'package:model/account/authentication_type.dart';

class Account with EquatableMixin {
  final String id;
  final AuthenticationType authenticationType;
  final bool isSelected;

  Account(this.id, this.authenticationType, {required this.isSelected});

  @override
  List<Object?> get props => [id, authenticationType, isSelected];
}