
import 'package:equatable/equatable.dart';

class TypeName with EquatableMixin {
  static final mailboxType = TypeName('Mailbox');
  static final emailType = TypeName('Email');
  static final emailDelivery = TypeName('EmailDelivery');

  final String value;

  TypeName(this.value);

  @override
  List<Object?> get props => [value];
}