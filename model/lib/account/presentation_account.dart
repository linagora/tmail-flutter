
import 'package:equatable/equatable.dart';
import 'package:model/account/account_type.dart';
import 'package:model/email/presentation_email_address.dart';

class PresentationAccount with EquatableMixin {
  final List<PresentationEmailAddress> emails;
  final int preferredEmailIndex;
  final AccountType type;

  PresentationAccount(this.emails, this.preferredEmailIndex, this.type);

  @override
  List<Object?> get props => [emails];
}