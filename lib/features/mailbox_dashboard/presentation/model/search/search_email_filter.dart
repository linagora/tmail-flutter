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
  final Set<String> hasKeyword;
  final Set<String> notKeyword;
  final PresentationMailbox? mailbox;
  final EmailReceiveTimeType emailReceiveTimeType;
  final bool hasAttachment;
  final UTCDate? before;

  SearchEmailFilter({
    Set<String>? from,
    Set<String>? to,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    this.text,
    this.subject,
    Set<String>? hasKeyword,
    Set<String>? notKeyword,
    this.mailbox,
    this.before,
  })  : from = from ?? <String>{},
        to = to ?? <String>{},
        hasKeyword = hasKeyword ?? <String>{},
        notKeyword = notKeyword ?? <String>{},
        hasAttachment = hasAttachment ?? false,
        emailReceiveTimeType =
            emailReceiveTimeType ?? EmailReceiveTimeType.allTime;

  SearchEmailFilter copyWith({
    Set<String>? from,
    Set<String>? to,
    SearchQuery? text,
    String? subject,
    Set<String>? hasKeyword,
    Set<String>? notKeyword,
    PresentationMailbox? mailbox,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    UTCDate? before,
  }) {
    return SearchEmailFilter(
      from: from ?? this.from,
      to: to ?? this.to,
      text: text ?? this.text,
      subject: subject ?? this.subject,
      hasKeyword: hasKeyword ?? this.hasKeyword,
      notKeyword: notKeyword ?? this.notKeyword,
      mailbox: mailbox ?? this.mailbox,
      emailReceiveTimeType: emailReceiveTimeType ?? this.emailReceiveTimeType,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      before: before ?? this.before,
    );
  }

  Filter mappingToEmailFilterCondition({Filter? moreFilterCondition}) {
    final emailEmailFilterConditionShared = EmailFilterCondition(
      text: text?.value,
      inMailbox: mailbox?.id,
      after: emailReceiveTimeType.toUTCDate(),
      hasAttachment: hasAttachment == false ? null : hasAttachment,
      subject: subject,
      before: before,
    );
    return LogicFilterOperator(Operator.AND, {
      emailEmailFilterConditionShared,
      LogicFilterOperator(
          Operator.AND, to.map((e) => EmailFilterCondition(to: e)).toSet()),
      LogicFilterOperator(
          Operator.AND, from.map((e) => EmailFilterCondition(from: e)).toSet()),
      LogicFilterOperator(
          Operator.AND, hasKeyword.map((e) => EmailFilterCondition(hasKeyword: e)).toSet()),
      LogicFilterOperator(
          Operator.AND, notKeyword.map((e) => EmailFilterCondition(notKeyword: e)).toSet()),
      if(moreFilterCondition !=null) moreFilterCondition
    });
  }
}
