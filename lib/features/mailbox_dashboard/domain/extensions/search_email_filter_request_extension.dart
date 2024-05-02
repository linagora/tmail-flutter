
import 'package:jmap_dart_client/jmap/core/utc_date.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/search_email_filter_request.dart';

extension SearchEmailFilterRequestExtension on SearchEmailFilterRequest {

  SearchEmailFilterRequest updateBeforeDate(UTCDate? newBeforeDate) {
    return SearchEmailFilterRequest(
      from,
      to,
      text,
      subject,
      notKeyword,
      mailboxId,
      hasAttachment,
      receiveTimeType,
      newBeforeDate,
      startDate,
      endDate,
      moreFilterCondition
    );
  }
}