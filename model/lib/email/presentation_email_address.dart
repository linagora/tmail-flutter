
import 'package:equatable/equatable.dart';

class PresentationEmailAddress with EquatableMixin {
  final String email;

  PresentationEmailAddress(this.email);

  @override
  List<Object?> get props => [email];
}