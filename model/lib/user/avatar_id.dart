
import 'package:equatable/equatable.dart';

class AvatarId with EquatableMixin {
  final String id;

  AvatarId(this.id);

  factory AvatarId.initial() {
    return AvatarId('');
  }

  @override
  List<Object?> get props => [id];
}