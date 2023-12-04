
import 'package:equatable/equatable.dart';

class FcmToken with EquatableMixin {

  final String value;

  FcmToken(this.value);

  @override
  List<Object?> get props => [value];
}