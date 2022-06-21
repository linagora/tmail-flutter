import 'package:jmap_dart_client/jmap/core/filter/filter.dart';
import 'package:jmap_dart_client/jmap/core/filter/filter_operator.dart';
import 'package:jmap_dart_client/jmap/core/filter/operator/logic_filter_operator.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/email_receive_time_type.dart';
import 'package:tmail_ui_user/features/thread/domain/model/search_query.dart';

enum HasAttachment {
  yes,
  no,
  all,
}

extension HasAttachmentExtension on HasAttachment {
  bool? getValue() {
    switch (this) {
      case HasAttachment.yes:
        return true;
      case HasAttachment.no:
        return false;
      case HasAttachment.all:
        return null;
    }
  }
}

class SearchEmailFilter {
  final Set<String> from;
  final Set<String> to;
  final SearchQuery? text;
  final String? subject;
  final String? hasKeyword;
  final String? notKeyword;
  final MailboxId? mailBoxId;
  final EmailReceiveTimeType? emailReceiveTimeType;
  final HasAttachment? hasAttachment;

  SearchEmailFilter({
    Set<String>? from,
    Set<String>? to,
    this.text,
    this.subject,
    this.hasKeyword,
    this.notKeyword,
    this.mailBoxId,
    this.emailReceiveTimeType,
    this.hasAttachment,
  })  : from = from ?? <String>{},
        to = to ?? <String>{};

  SearchEmailFilter copyWith({
    Set<String>? from,
    Set<String>? to,
    SearchQuery? text,
    String? subject,
    String? hasKeyword,
    String? notKeyword,
    MailboxId? mailBoxId,
    EmailReceiveTimeType? emailReceiveTimeType,
    HasAttachment? hasAttachment,
  }) {
    return SearchEmailFilter(
      from: from ?? this.from,
      to: to ?? this.to,
      text: text ?? this.text,
      subject: subject ?? this.subject,
      hasKeyword: hasKeyword ?? this.hasKeyword,
      notKeyword: notKeyword ?? this.notKeyword,
      mailBoxId: mailBoxId ?? this.mailBoxId,
      emailReceiveTimeType: emailReceiveTimeType ?? this.emailReceiveTimeType,
      hasAttachment: hasAttachment ?? this.hasAttachment,
    );
  }

  Filter? mappingToEmailFilterCondition() {
    final emailEmailFilterConditionShared = EmailFilterCondition(
      text: text?.value,
      inMailbox: mailBoxId,
      after: emailReceiveTimeType?.toUTCDate(),
      hasKeyword: hasKeyword,
      notKeyword: notKeyword,
      hasAttachment: hasAttachment?.getValue(),
      subject: subject,
    );

    return LogicFilterOperator(Operator.AND, {
      emailEmailFilterConditionShared,
      LogicFilterOperator(
          Operator.AND, to.map((e) => EmailFilterCondition(to: e)).toSet()),
      LogicFilterOperator(
          Operator.AND, from.map((e) => EmailFilterCondition(from: e)).toSet()),
    });
  }
}
