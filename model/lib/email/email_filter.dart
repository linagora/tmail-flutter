
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/filter_message_option.dart';

class EmailFilter with EquatableMixin {

  final Filter? filter;
  final FilterMessageOption? filterOption;
  final MailboxId? mailboxId;

  EmailFilter({this.filter, this.filterOption, this.mailboxId});

  @override
  List<Object?> get props => [filter, filterOption, mailboxId];
}