import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

class SimpleSearchFilter with EquatableMixin {
  final Set<String> from;
  final SearchQuery? text;
  final PresentationMailbox? mailbox;
  final EmailReceiveTimeType emailReceiveTimeType;
  final bool hasAttachment;
  final UTCDate? before;

  SimpleSearchFilter({
    Set<String>? from,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    this.text,
    this.before,
    this.mailbox,
  })  : from = from ?? <String>{},
        hasAttachment = hasAttachment ?? false,
        emailReceiveTimeType = emailReceiveTimeType ?? EmailReceiveTimeType.allTime;

  SimpleSearchFilter copyWith({
    Set<String>? from,
    SearchQuery? text,
    PresentationMailbox? mailbox,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    UTCDate? before,
  }) {
    return SimpleSearchFilter(
      from: from ?? this.from,
      text: text ?? this.text,
      mailbox: mailbox ?? this.mailbox,
      emailReceiveTimeType: emailReceiveTimeType ?? this.emailReceiveTimeType,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      before: before ?? this.before,
    );
  }

  Filter? mappingToEmailFilterCondition() {
    final emailEmailFilterConditionShared = EmailFilterCondition(
      text: text?.value.trim().isNotEmpty == true
        ? text?.value
        : null,
      inMailbox: mailbox?.id,
      after: emailReceiveTimeType.toUTCDate(),
      hasAttachment: hasAttachment == false ? null : hasAttachment,
      before: before,
    );

    final listEmailCondition = {
      if (emailEmailFilterConditionShared.hasCondition)
        emailEmailFilterConditionShared,
      if (from.isNotEmpty)
        LogicFilterOperator(
            Operator.AND,
            from.map((e) => EmailFilterCondition(from: e)).toSet()),
    };

    return listEmailCondition.isNotEmpty
      ? LogicFilterOperator(Operator.AND, listEmailCondition)
      : null;
  }

  @override
  List<Object?> get props => [from, text, mailbox, emailReceiveTimeType, hasAttachment, before];
}

extension SearchEmailFilterExtension on SimpleSearchFilter {

  SimpleSearchFilter toSimpleSearchFilterByBefore({UTCDate? newBefore}) {
    return SimpleSearchFilter(
      from: from,
      text: text,
      mailbox: mailbox,
      emailReceiveTimeType: emailReceiveTimeType,
      hasAttachment: hasAttachment,
      before: newBefore,
    );
  }

  SimpleSearchFilter toSimpleSearchFilterByMailbox({PresentationMailbox? newMailbox}) {
    return SimpleSearchFilter(
      from: from,
      text: text,
      mailbox: newMailbox,
      emailReceiveTimeType: emailReceiveTimeType,
      hasAttachment: hasAttachment,
      before: before,
    );
  }

  bool get searchFilterByMailboxApplied => mailbox != null;

  String get mailboxName => mailbox?.name?.name ?? '';
}