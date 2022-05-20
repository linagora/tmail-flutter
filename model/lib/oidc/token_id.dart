
import 'package:equatable/equatable.dart';

class TokenId with EquatableMixin {
  final String uuid;

  TokenId(this.uuid);

  @override
  List<Object> get props => [uuid];
}
