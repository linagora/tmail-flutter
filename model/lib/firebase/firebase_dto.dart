import 'package:equatable/equatable.dart';

class FirebaseDto with EquatableMixin {
  final String token;

  FirebaseDto(this.token);

  @override
  List<Object?> get props => [token];
}