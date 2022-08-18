
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';

class MailsForwardCreatorArguments with EquatableMixin {
  final AccountId accountId;

  MailsForwardCreatorArguments(this.accountId);

  @override
  List<Object?> get props => [accountId];
}