import 'package:core/utils/option_param_mixin.dart';
import 'package:equatable/equatable.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/email_filter_condition_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/email_receive_time_type.dart';

class SearchEmailFilterRequest with EquatableMixin, OptionParamMixin {
  final Set<String> from;
  final Set<String> to;
  final String? text;
  final String? subject;
  final Set<String> notKeyword;
  final MailboxId? mailboxId;
  final bool hasAttachment;
  final EmailReceiveTimeType receiveTimeType;
  final UTCDate? before;
  final UTCDate? startDate;
  final UTCDate? endDate;
  final EmailFilterCondition? moreFilterCondition;

  SearchEmailFilterRequest(
    this.from,
    this.to,
    this.text,
    this.subject,
    this.notKeyword,
    this.mailboxId,
    this.hasAttachment,
    this.receiveTimeType,
    this.before,
    this.startDate,
    this.endDate,
    this.moreFilterCondition,
  );

  Filter? toEmailFilterConditionByMostRecentSortOrder() {
    final emailEmailFilterConditionShared = EmailFilterCondition(
      text: text,
      inMailbox: mailboxId,
      after: receiveTimeType.getAfterDate(startDate),
      hasAttachment: !hasAttachment ? null : hasAttachment,
      subject: subject?.trim().isNotEmpty == true
        ? subject
        : null,
      before: receiveTimeType.getBeforeDate(endDate, before)
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
      if (moreFilterCondition != null && moreFilterCondition?.hasCondition == true)
        moreFilterCondition!
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
    mailboxId,
    hasAttachment,
    receiveTimeType,
    before,
    startDate,
    endDate,
    moreFilterCondition,
  ];
}