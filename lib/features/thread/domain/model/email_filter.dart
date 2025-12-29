
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class EmailFilter with EquatableMixin {

  final Filter? filter;
  final FilterMessageOption? filterOption;
  final MailboxId? mailboxId;

  EmailFilter({this.filter, this.filterOption, this.mailboxId});

  EmailFilter copyWith({
    Filter? filter,
    FilterMessageOption? filterOption,
    MailboxId? mailboxId,
  }) {
    return EmailFilter(
      filter: filter ?? this.filter,
      filterOption: filterOption ?? this.filterOption,
      mailboxId: mailboxId ?? this.mailboxId,
    );
  }

  @override
  List<Object?> get props => [filter, filterOption, mailboxId];
}