import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/request/reference_path.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/query/query_mailbox_method.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/spam_report_exception.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/unread_spam_emails_response.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class SpamReportApi {
  final HttpClient _httpClient;
  static const int _deafaultLimit = 1; 

  SpamReportApi(this._httpClient);

  Future<UnreadSpamEmailsResponse> getUnreadSpamEmailbox(
    Session session,
    AccountId accountId,
    {
      MailboxFilterCondition? mailboxFilterCondition,
      UnsignedInt? limit
    }
  ) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);
    final spamReportQueryMethod = QueryMailboxMethod(accountId)..addLimit(limit ?? UnsignedInt(_deafaultLimit));

    if(mailboxFilterCondition != null) spamReportQueryMethod.addFilters(mailboxFilterCondition);

    final spamReportQueryMethodInvocation = requestBuilder.invocation(spamReportQueryMethod);
    final getMailBoxMethod = GetMailboxMethod(accountId)
        ..addReferenceIds(processingInvocation.createResultReference(
          spamReportQueryMethodInvocation.methodCallId,
          ReferencePath.idsPath,
        ));
    final getMailboxInvocation = requestBuilder.invocation(getMailBoxMethod);

    final capabilities = getMailBoxMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (requestBuilder
            ..usings(capabilities))
          .build()
          .execute();

    final mailboxResponse = result
        .parse<GetMailboxResponse>(getMailboxInvocation.methodCallId, GetMailboxResponse.deserialize);

    if (mailboxResponse?.list.isNotEmpty == true) {
      return UnreadSpamEmailsResponse(unreadSpamMailbox: mailboxResponse!.list.first);
    } else {
      throw NotFoundSpamMailboxException();
    }
  }
}