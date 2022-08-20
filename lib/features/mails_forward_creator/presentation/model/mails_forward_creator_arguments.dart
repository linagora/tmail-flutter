
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';

class MailsForwardCreatorArguments with EquatableMixin {
  final AccountId accountId;
  final Session? session;
  MailsForwardCreatorArguments(this.accountId, this.session);

  @override
  List<Object?> get props => [accountId, session];
}