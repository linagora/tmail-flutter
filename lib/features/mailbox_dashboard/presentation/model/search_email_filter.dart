import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

class SearchEmailFilter {
  final Set<String> from;
  final Set<String> to;
  final SearchQuery? text;
  final String? subject;
  final String? hasKeyword;
  final String? notKeyword;
  final PresentationMailbox? mailbox;
  final EmailReceiveTimeType emailReceiveTimeType;
  final bool hasAttachment;

  SearchEmailFilter({
    Set<String>? from,
    Set<String>? to,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    this.text,
    this.subject,
    this.hasKeyword,
    this.notKeyword,
    this.mailbox,
  })  : from = from ?? <String>{},
        to = to ?? <String>{},
        hasAttachment = hasAttachment ?? false,
        emailReceiveTimeType =
            emailReceiveTimeType ?? EmailReceiveTimeType.anyTime;

  SearchEmailFilter copyWith({
    Set<String>? from,
    Set<String>? to,
    SearchQuery? text,
    String? subject,
    Wrapped<String?>? hasKeyword,
    Wrapped<String?>? notKeyword,
    PresentationMailbox? mailbox,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
  }) {
    return SearchEmailFilter(
      from: from ?? this.from,
      to: to ?? this.to,
      text: text ?? this.text,
      subject: subject ?? this.subject,
      hasKeyword: hasKeyword != null ? hasKeyword.value : this.hasKeyword,
      notKeyword: notKeyword !=null ? notKeyword.value : this.notKeyword,
      mailbox: mailbox ?? this.mailbox,
      emailReceiveTimeType: emailReceiveTimeType ?? this.emailReceiveTimeType,
      hasAttachment: hasAttachment ?? this.hasAttachment,
    );
  }

  Filter? mappingToEmailFilterCondition() {
    final emailEmailFilterConditionShared = EmailFilterCondition(
      from: from.firstOrNull,
      to: to.firstOrNull,
      text: text?.value,
      inMailbox: mailbox?.id,
      after: emailReceiveTimeType.toUTCDate(),
      hasKeyword: hasKeyword,
      notKeyword: notKeyword,
      hasAttachment: hasAttachment == false ? null : hasAttachment,
      subject: subject,
    );

    return emailEmailFilterConditionShared;

    return LogicFilterOperator(Operator.AND, {
      emailEmailFilterConditionShared,
      LogicFilterOperator(
          Operator.AND, to.map((e) => EmailFilterCondition(to: e)).toSet()),
      LogicFilterOperator(
          Operator.AND, from.map((e) => EmailFilterCondition(from: e)).toSet()),
    });
  }
}
