import 'package:equatable/equatable.dart';

class UserId with EquatableMixin {
  final String id;

  UserId(this.id);

  @override
  List<Object?> get props => [id];
}