import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:model/extensions/email_filter_condition_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/email_sort_order_type.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class SimpleSearchFilter with EquatableMixin {
  final Set<String> from;
  final Set<String> to;
  final SearchQuery? text;
  final PresentationMailbox? mailbox;
  final EmailReceiveTimeType emailReceiveTimeType;
  final bool hasAttachment;
  final UTCDate? before;
  final UTCDate? startDate;
  final UTCDate? endDate;
  final Set<Comparator>? sortOrder;
  final int? position;

  SimpleSearchFilter({
    Set<String>? from,
    Set<String>? to,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    this.text,
    this.before,
    this.mailbox,
    this.startDate,
    this.endDate,
    this.sortOrder,
    this.position,
  })  : from = from ?? <String>{},
        to = to ?? <String>{},
        hasAttachment = hasAttachment ?? false,
        emailReceiveTimeType = emailReceiveTimeType ?? EmailReceiveTimeType.allTime;

  SimpleSearchFilter copyWith({
    Option<Set<String>>? fromOption,
    Option<Set<String>>? toOption,
    Option<SearchQuery>? textOption,
    Option<PresentationMailbox>? mailboxOption,
    Option<EmailReceiveTimeType>? emailReceiveTimeTypeOption,
    Option<bool>? hasAttachmentOption,
    Option<UTCDate>? beforeOption,
    Option<UTCDate>? startDateOption,
    Option<UTCDate>? endDateOption,
    Option<Set<Comparator>>? sortOrderOption,
    Option<int>? positionOption,
  }) {
    return SimpleSearchFilter(
      from: _getOptionParam(fromOption, from),
      to: _getOptionParam(toOption, to),
      text: _getOptionParam(textOption, text),
      mailbox: _getOptionParam(mailboxOption, mailbox),
      emailReceiveTimeType: _getOptionParam(emailReceiveTimeTypeOption, emailReceiveTimeType),
      hasAttachment: _getOptionParam(hasAttachmentOption, hasAttachment),
      before: _getOptionParam(beforeOption, before),
      startDate: _getOptionParam(startDateOption, startDate),
      endDate: _getOptionParam(endDateOption, endDate),
      sortOrder: _getOptionParam(sortOrderOption, sortOrder),
      position: _getOptionParam(positionOption, position),
    );
  }

  T? _getOptionParam<T>(Option<T?>? option, T? defaultValue) {
    if (option != null) {
      return option.toNullable();
    } else {
      return defaultValue;
    }
  }

  Filter? mappingToEmailFilterCondition({required EmailSortOrderType sortOrderType}) {
    final emailEmailFilterConditionShared = EmailFilterCondition(
      text: text?.value.trim().isNotEmpty == true
        ? text?.value
        : null,
      inMailbox: mailbox?.id,
      after: sortOrderType.isScrollByPosition()
        ? null
        : emailReceiveTimeType.getAfterDate(startDate),
      hasAttachment: hasAttachment == false ? null : hasAttachment,
      before: sortOrderType.isScrollByPosition()
        ? null
        : emailReceiveTimeType.getBeforeDate(endDate, before)
    );

    final listEmailCondition = {
      if (emailEmailFilterConditionShared.hasCondition)
        emailEmailFilterConditionShared,
      if (from.isNotEmpty)
        LogicFilterOperator(
            Operator.AND,
            from.map((e) => EmailFilterCondition(from: e)).toSet()),
      if (to.isNotEmpty)
        LogicFilterOperator(
            Operator.AND,
            to.map((e) => EmailFilterCondition(to: e)).toSet()),
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

extension SearchEmailFilterExtension on SimpleSearchFilter {
  bool get searchFilterByMailboxApplied => mailbox != null;

  bool get searchFilterByFromApplied => from.isNotEmpty;

  bool get searchFilterByToApplied => to.isNotEmpty;

  bool searchFilterByContactApplied(PrefixEmailAddress prefixEmailAddress) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.from:
        return searchFilterByFromApplied;
      case PrefixEmailAddress.to:
        return searchFilterByToApplied;
      default:
        return false;
    }
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

  String getNameContactApplied(BuildContext context, PrefixEmailAddress prefixEmailAddress) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.from:
        return '${AppLocalizations.of(context).from_email_address_prefix} ${from.first}';
      case PrefixEmailAddress.to:
        return '${AppLocalizations.of(context).to_email_address_prefix} ${to.first}';
      default:
        return '';
    }
  }

  String getNameContactDefault(BuildContext context, PrefixEmailAddress prefixEmailAddress) {
    switch(prefixEmailAddress) {
      case PrefixEmailAddress.from:
        return AppLocalizations.of(context).from_email_address_prefix;
      case PrefixEmailAddress.to:
        return AppLocalizations.of(context).to_email_address_prefix;
      default:
        return '';
    }
  }

  String getMailboxName(BuildContext context) => mailbox?.getDisplayName(context) ?? '';
}