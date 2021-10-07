
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';

class EmailFilter with EquatableMixin {

  final Filter? filter;
  final MailboxId? mailboxId;

  EmailFilter({this.filter, this.mailboxId});

  @override
  List<Object?> get props => [filter, mailboxId];
}