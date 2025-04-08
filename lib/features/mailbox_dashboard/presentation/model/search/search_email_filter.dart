import 'package:core/utils/option_param_mixin.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
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
  final int? position;
  final EmailSortOrderType sortOrderType;

  factory SearchEmailFilter.initial() => SearchEmailFilter();

  SearchEmailFilter({
    this.text,
    this.subject,
    this.mailbox,
    this.before,
    this.startDate,
    this.endDate,
    this.position,
    Set<String>? from,
    Set<String>? to,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    Set<String>? notKeyword,
    Set<String>? hasKeyword,
    EmailSortOrderType? sortOrderType,
  })  : from = from ?? <String>{},
        to = to ?? <String>{},
        notKeyword = notKeyword ?? <String>{},
        hasKeyword = hasKeyword ?? <String>{},
        hasAttachment = hasAttachment ?? false,
        emailReceiveTimeType =
          emailReceiveTimeType ?? EmailReceiveTimeType.allTime,
        sortOrderType = sortOrderType ?? EmailSortOrderType.mostRecent;

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
    Option<int>? positionOption,
    Option<EmailSortOrderType>? sortOrderTypeOption,
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
      position: getOptionParam(positionOption, position),
      sortOrderType: getOptionParam(sortOrderTypeOption, sortOrderType),
    );
  }

  Filter? mappingToEmailFilterCondition({
    EmailFilterCondition? moreFilterCondition
  }) {
    final emailEmailFilterConditionShared = EmailFilterCondition(
      text: text?.value.trim().isNotEmpty == true
        ? text?.value.trim()
        : null,
      inMailbox: mailbox?.mailboxId,
      after: emailReceiveTimeType.getAfterDate(startDate),
      hasAttachment: !hasAttachment ? null : hasAttachment,
      subject: subject?.trim().isNotEmpty == true
        ? subject?.trim()
        : null,
      before: emailReceiveTimeType.getBeforeDate(endDate, before),
      from: from.length == 1
        ? from.first
        : null,
      hasKeyword: hasKeyword.length == 1
        ? hasKeyword.first
        : null,
    );

    final listEmailCondition = {
      if (emailEmailFilterConditionShared.hasCondition)
        emailEmailFilterConditionShared,
      if (to.isNotEmpty)
        ..._generateFilterFromToField(),
      if (from.length > 1)
        LogicFilterOperator(
          Operator.OR,
          from.map((e) => EmailFilterCondition(from: e)).toSet(),
        ),
      if (notKeyword.isNotEmpty)
        LogicFilterOperator(
          Operator.NOT,
          notKeyword.map((e) => EmailFilterCondition(text: e)).toSet(),
        ),
      if (hasKeyword.length > 1)
        LogicFilterOperator(
          Operator.AND,
          hasKeyword.map((e) => EmailFilterCondition(hasKeyword: e)).toSet(),
        ),
      if (moreFilterCondition != null && moreFilterCondition.hasCondition)
        moreFilterCondition
    };

    if (listEmailCondition.isEmpty) {
      return null;
    } else if (listEmailCondition.length == 1) {
      return listEmailCondition.first;
    } else {
      return LogicFilterOperator(Operator.AND, listEmailCondition);
    }
  }

  @visibleForTesting
  List<Filter> generateFilterFromToField() => _generateFilterFromToField();

  List<Filter> _generateFilterFromToField() {
    if (to.length == 1) {
      return [
        _generateFilterFromAValueOfToField(to.first),
      ];
    }

    return to.map(_generateFilterFromAValueOfToField).toList();
  }

  Filter _generateFilterFromAValueOfToField(String value) {
    return LogicFilterOperator(
      Operator.OR,
      {
        EmailFilterCondition(to: value),
        EmailFilterCondition(cc: value),
        EmailFilterCondition(bcc: value),
      },
    );
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

  bool get isApplied => from.isNotEmpty ||
    to.isNotEmpty ||
    text?.value.trim().isNotEmpty == true ||
    subject?.trim().isNotEmpty == true ||
    hasKeyword.isNotEmpty == true ||
    notKeyword.isNotEmpty == true ||
    emailReceiveTimeType != EmailReceiveTimeType.allTime ||
    sortOrderType != EmailSortOrderType.mostRecent ||
    (mailbox != null && mailbox?.id != PresentationMailbox.unifiedMailbox.id) ||
    hasAttachment;

  bool get isContainFlagged => hasKeyword.contains(KeyWordIdentifier.emailFlagged.value);

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
    position,
    sortOrderType
  ];
}