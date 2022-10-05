import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

class SearchEmailFilter {
  final Set<String> from;
  final Set<String> to;
  final SearchQuery? text;
  final String? subject;
  final Set<String> notKeyword;
  final PresentationMailbox? mailbox;
  final EmailReceiveTimeType emailReceiveTimeType;
  final bool hasAttachment;
  final UTCDate? before;
  final UTCDate? startDate;
  final UTCDate? endDate;

  SearchEmailFilter({
    Set<String>? from,
    Set<String>? to,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    this.text,
    this.subject,
    Set<String>? notKeyword,
    this.mailbox,
    this.before,
    this.startDate,
    this.endDate,
  })  : from = from ?? <String>{},
        to = to ?? <String>{},
        notKeyword = notKeyword ?? <String>{},
        hasAttachment = hasAttachment ?? false,
        emailReceiveTimeType =
            emailReceiveTimeType ?? EmailReceiveTimeType.allTime;

  SearchEmailFilter copyWith({
    Set<String>? from,
    Set<String>? to,
    SearchQuery? text,
    String? subject,
    Set<String>? notKeyword,
    PresentationMailbox? mailbox,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    UTCDate? before,
    UTCDate? startDate,
    UTCDate? endDate,
  }) {
    return SearchEmailFilter(
      from: from ?? this.from,
      to: to ?? this.to,
      text: text ?? this.text,
      subject: subject ?? this.subject,
      notKeyword: notKeyword ?? this.notKeyword,
      mailbox: mailbox ?? this.mailbox,
      emailReceiveTimeType: emailReceiveTimeType ?? this.emailReceiveTimeType,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      before: before ?? this.before,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }

  Filter? mappingToEmailFilterCondition({EmailFilterCondition? moreFilterCondition}) {
    final emailEmailFilterConditionShared = EmailFilterCondition(
      text: text?.value.trim().isNotEmpty == true
        ? text?.value
        : null,
      inMailbox: mailbox == PresentationMailbox.unifiedMailbox
          ? null
          : mailbox?.id,
      after: emailReceiveTimeType == EmailReceiveTimeType.customRange
        ? startDate
        : emailReceiveTimeType.toUTCDate(),
      hasAttachment: hasAttachment == false ? null : hasAttachment,
      subject: subject,
      before: emailReceiveTimeType == EmailReceiveTimeType.customRange
        ? endDate
        : before,
    );

    final listEmailCondition = {
      if (emailEmailFilterConditionShared.hasCondition)
        emailEmailFilterConditionShared,
      if (to.isNotEmpty)
        LogicFilterOperator(
            Operator.AND,
            to.map((e) => EmailFilterCondition(to: e)).toSet()),
      if (from.isNotEmpty)
        LogicFilterOperator(
            Operator.AND,
            from.map((e) => EmailFilterCondition(from: e)).toSet()),
      if (notKeyword.isNotEmpty)
        LogicFilterOperator(
            Operator.AND,
            notKeyword.map((e) => EmailFilterCondition(notKeyword: e)).toSet()),
      if (moreFilterCondition != null && moreFilterCondition.hasCondition)
        moreFilterCondition
    };

    return listEmailCondition.isNotEmpty
      ? LogicFilterOperator(Operator.AND, listEmailCondition)
      : null;
  }
}

extension SearchEmailFilterExtension on SearchEmailFilter {

  SearchEmailFilter toSearchEmailFilter({UTCDate? newBefore}) {
    return SearchEmailFilter(
      from: from,
      to: to,
      text: text,
      subject: subject,
      notKeyword: notKeyword,
      mailbox: mailbox,
      emailReceiveTimeType: emailReceiveTimeType,
      hasAttachment: hasAttachment,
      before: newBefore,
    );
  }

  SearchEmailFilter withDateRange({UTCDate? startDate, UTCDate? endDate}) {
    return SearchEmailFilter(
      from: from,
      to: to,
      text: text,
      subject: subject,
      notKeyword: notKeyword,
      mailbox: mailbox,
      emailReceiveTimeType: emailReceiveTimeType,
      hasAttachment: hasAttachment,
      before: before,
      startDate: startDate,
      endDate: endDate,
    );
  }
}