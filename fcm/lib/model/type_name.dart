
import 'package:equatable/equatable.dart';

class TypeName with EquatableMixin {
  static const mailboxType = TypeName('Mailbox');
  static const emailType = TypeName('Email');
  static const emailDelivery = TypeName('EmailDelivery');

  final String value;

  const TypeName(this.value);

  @override
  List<Object?> get props => [value];
}