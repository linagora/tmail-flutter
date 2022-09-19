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
  final EmailReceiveTimeType emailReceiveTimeType;
  final bool hasAttachment;
  final UTCDate? before;

  SimpleSearchFilter({
    Set<String>? from,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    this.text,
    this.before,
  })  : from = from ?? <String>{},
        hasAttachment = hasAttachment ?? false,
        emailReceiveTimeType =emailReceiveTimeType ?? EmailReceiveTimeType.allTime;

  SimpleSearchFilter copyWith({
    Set<String>? from,
    SearchQuery? text,
    EmailReceiveTimeType? emailReceiveTimeType,
    bool? hasAttachment,
    UTCDate? before,
  }) {
    return SimpleSearchFilter(
      from: from ?? this.from,
      text: text ?? this.text,
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
  List<Object?> get props => [from, text, emailReceiveTimeType, hasAttachment, before];
}

extension SearchEmailFilterExtension on SimpleSearchFilter {

  SimpleSearchFilter toSimpleSearchFilter({UTCDate? newBefore}) {
    return SimpleSearchFilter(
      from: from,
      text: text,
      emailReceiveTimeType: emailReceiveTimeType,
      hasAttachment: hasAttachment,
      before: newBefore,
    );
  }
}