import 'package:core/utils/option_param_mixin.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_filter_condition_extension.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

class SearchEmailFilter with EquatableMixin, OptionParamMixin {
  final Set<String> from;
  final Set<String> to;
  final SearchQuery? text;
  final String? subject;
  final Set<String> notKeyword;
  final Set<String> hasKeyword;
  final PresentationMailbox? mailbox;
  final EmailReceiveTimeType emailReceiveTimeType;
  final bool hasAttachment;
  final UTCDate? before;
  final UTCDate? startDate;
  final UTCDate? endDate;
  final Set<Comparator>? sortOrder;
  final int? position;

  factory SearchEmailFilter.initial() => SearchEmailFilter(
    sortOrder: EmailSortOrderType.mostRecent.getSortOrder().toNullable()
  );

  SearchEmailFilter({
    Set<String>? from,
    Set<String>? to,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    this.text,
    this.subject,
    Set<String>? notKeyword,
    Set<String>? hasKeyword,
    this.mailbox,
    this.before,
    this.startDate,
    this.endDate,
    this.sortOrder,
    this.position,
  })  : from = from ?? <String>{},
        to = to ?? <String>{},
        notKeyword = notKeyword ?? <String>{},
        hasKeyword = hasKeyword ?? <String>{},
        hasAttachment = hasAttachment ?? false,
        emailReceiveTimeType =
            emailReceiveTimeType ?? EmailReceiveTimeType.allTime;

  SearchEmailFilter copyWith({
    Option<Set<String>>? fromOption,
    Option<Set<String>>? toOption,
    Option<SearchQuery>? textOption,
    Option<String>? subjectOption,
    Option<Set<String>>? notKeywordOption,
    Option<Set<String>>? hasKeywordOption,
    Option<PresentationMailbox>? mailboxOption,
    Option<EmailReceiveTimeType>? emailReceiveTimeTypeOption,
    Option<bool>? hasAttachmentOption,
    Option<UTCDate>? beforeOption,
    Option<UTCDate>? startDateOption,
    Option<UTCDate>? endDateOption,
    Option<Set<Comparator>>? sortOrderOption,
    Option<int>? positionOption,
  }) {
    return SearchEmailFilter(
      from: getOptionParam(fromOption, from),
      to: getOptionParam(toOption, to),
      text: getOptionParam(textOption, text),
      subject: getOptionParam(subjectOption, subject),
      notKeyword: getOptionParam(notKeywordOption, notKeyword),
      hasKeyword: getOptionParam(hasKeywordOption, hasKeyword),
      mailbox: getOptionParam(mailboxOption, mailbox),
      emailReceiveTimeType: getOptionParam(emailReceiveTimeTypeOption, emailReceiveTimeType),
      hasAttachment: getOptionParam(hasAttachmentOption, hasAttachment),
      before: getOptionParam(beforeOption, before),
      startDate: getOptionParam(startDateOption, startDate),
      endDate: getOptionParam(endDateOption, endDate),
      sortOrder: getOptionParam(sortOrderOption, sortOrder),
      position: getOptionParam(positionOption, position),
    );
  }

  Filter? mappingToEmailFilterCondition({
    required EmailSortOrderType sortOrderType,
    EmailFilterCondition? moreFilterCondition
  }) {
    final emailEmailFilterConditionShared = EmailFilterCondition(
      text: text?.value.trim().isNotEmpty == true
        ? text?.value
        : null,
      inMailbox: mailbox?.mailboxId,
      after: sortOrderType.isScrollByPosition()
        ? null
        : emailReceiveTimeType.getAfterDate(startDate),
      hasAttachment: hasAttachment == false ? null : hasAttachment,
      subject: subject?.trim().isNotEmpty == true
        ? subject
        : null,
      before: sortOrderType.isScrollByPosition()
        ? null
        : emailReceiveTimeType.getBeforeDate(endDate, before)
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
      if (hasKeyword.isNotEmpty)
        LogicFilterOperator(
          Operator.AND,
          hasKeyword.map((e) => EmailFilterCondition(hasKeyword: e)).toSet()),
      if (moreFilterCondition != null && moreFilterCondition.hasCondition)
        moreFilterCondition
    };

    return listEmailCondition.isNotEmpty
      ? LogicFilterOperator(Operator.AND, listEmailCondition)
      : null;
  }

  Set<String> getContactApplied(PrefixEmailAddress prefixEmailAddress) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.from:
        return from;
      case PrefixEmailAddress.to:
        return to;
      default:
        return {};
    }
  }

  @override
  List<Object?> get props => [
    from,
    to,
    text,
    subject,
    notKeyword,
    hasKeyword,
    mailbox,
    emailReceiveTimeType,
    hasAttachment,
    before,
    startDate,
    endDate,
    sortOrder,
    position,
  ];
}