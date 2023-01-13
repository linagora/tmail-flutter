import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/request/reference_path.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_method.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/get/get_mailbox_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox_filter_condition.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/query/query_mailbox_method.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/model/unread_spam_emails_response.dart';

class SpamReportApi {
  final HttpClient _httpClient;
  static const int _deafaultLimit = 1; 

  SpamReportApi(this._httpClient);

  Future<UnreadSpamEmailsResponse> getUnreadSpamEmailbox(
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
    final result = await (requestBuilder
            ..usings(getMailBoxMethod.requiredCapabilities))
          .build()
          .execute();

    final _mailboxResponse = result
        .parse<GetMailboxResponse>(getMailboxInvocation.methodCallId, GetMailboxResponse.deserialize);

     return Future.sync(() async {
      final _unreadSpamMailbox = _mailboxResponse?.list.first;
      return UnreadSpamEmailsResponse(unreadSpamMailbox: _unreadSpamMailbox);
    }).catchError((error) {
      throw error;
    });
  }
}