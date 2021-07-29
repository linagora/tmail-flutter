
import 'package:equatable/equatable.dart';

class PresentationMail with EquatableMixin {

  final String id;
  final String? message;

  PresentationMail(this.id, {this.message});

  factory PresentationMail.createMailEmpty() {
    return PresentationMail('empty');
  }

  @override
  List<Object?> get props => [id, message];
}