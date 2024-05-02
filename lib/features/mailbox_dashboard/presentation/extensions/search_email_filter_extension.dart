
import 'package:jmap_dart_client/jmap/mail/email/email_filter_condition.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/search_email_filter_request.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/search/search_email_filter.dart';

extension SearchEmailFilterExtension on SearchEmailFilter {

  SearchEmailFilterRequest toSearchEmailFilterRequest({EmailFilterCondition? moreFilterCondition}) {
    return SearchEmailFilterRequest(
      from,
      to,
      text?.value.trim().isNotEmpty == true
        ? text?.value
        : null,
      subject,
      notKeyword,
      mailbox?.id,
      hasAttachment,
      emailReceiveTimeType,
      before,
      startDate,
      endDate,
      moreFilterCondition
    );
  }
}