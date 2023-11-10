import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:model/extensions/email_filter_condition_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';

class SearchEmailFilter with EquatableMixin {
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
  final Set<Comparator>? sortOrder;

  factory SearchEmailFilter.initial() => SearchEmailFilter();

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
    this.sortOrder,
  })  : from = from ?? <String>{},
        to = to ?? <String>{},
        notKeyword = notKeyword ?? <String>{},
        hasAttachment = hasAttachment ?? false,
        emailReceiveTimeType =
            emailReceiveTimeType ?? EmailReceiveTimeType.allTime;

  SearchEmailFilter copyWith({
    Option<Set<String>>? fromOption,
    Option<Set<String>>? toOption,
    SearchQuery? text,
    Option<String>? subjectOption,
    Set<String>? notKeyword,
    PresentationMailbox? mailbox,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    Option<UTCDate>? beforeOption,
    Option<UTCDate>? startDateOption,
    Option<UTCDate>? endDateOption,
    Option<Set<Comparator>>? sortOrderOption,
  }) {
    return SearchEmailFilter(
      from: _getOptionParam(fromOption, from),
      to: _getOptionParam(toOption, to),
      text: text ?? this.text,
      subject: _getOptionParam(subjectOption, subject),
      notKeyword: notKeyword ?? this.notKeyword,
      mailbox: mailbox ?? this.mailbox,
      emailReceiveTimeType: emailReceiveTimeType ?? this.emailReceiveTimeType,
      hasAttachment: hasAttachment ?? this.hasAttachment,
      before: _getOptionParam(beforeOption, before),
      startDate: _getOptionParam(startDateOption, startDate),
      endDate: _getOptionParam(endDateOption, endDate),
      sortOrder: _getOptionParam(sortOrderOption, sortOrder),
    );
  }

  T? _getOptionParam<T>(Option<T?>? option, T? defaultValue) {
    if (option != null) {
      return option.toNullable();
    } else {
      return defaultValue;
    }
  }

  Filter? mappingToEmailFilterCondition({EmailFilterCondition? moreFilterCondition}) {
    final emailEmailFilterConditionShared = EmailFilterCondition(
      text: text?.value.trim().isNotEmpty == true
        ? text?.value
        : null,
      inMailbox: mailbox?.mailboxId,
      after: emailReceiveTimeType.getAfterDate(startDate),
      hasAttachment: hasAttachment == false ? null : hasAttachment,
      subject: subject?.trim().isNotEmpty == true
        ? subject
        : null,
      before: emailReceiveTimeType.getBeforeDate(endDate, before)
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
          Operator.NOT,
          notKeyword.map((e) => EmailFilterCondition(text: e)).toSet()),
      if (moreFilterCondition != null && moreFilterCondition.hasCondition)
        moreFilterCondition
    };

    return listEmailCondition.isNotEmpty
      ? LogicFilterOperator(Operator.AND, listEmailCondition)
      : null;
  }

  @override
  List<Object?> get props => [
    from,
    to,
    text,
    subject,
    notKeyword,
    mailbox,
    emailReceiveTimeType,
    hasAttachment,
    before,
    startDate,
    endDate,
    sortOrder,
  ];
}