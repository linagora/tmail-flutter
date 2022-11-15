
import 'package:equatable/equatable.dart';

class FirebaseToken with EquatableMixin {

  final String value;

  FirebaseToken(this.value);

  @override
  List<Object?> get props => [value];
}