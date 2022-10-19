import 'dart:async';

import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/reference_id.dart';
import 'package:jmap_dart_client/jmap/core/reference_prefix.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/submission/email_submission_id.dart';
import 'package:jmap_dart_client/jmap/mdn/mdn.dart';
import 'package:jmap_dart_client/jmap/mdn/send/mdn_send_method.dart';
import 'package:jmap_dart_client/jmap/mdn/send/mdn_send_response.dart';
import 'package:tmail_ui_user/features/email/domain/model/send_receipt_to_sender_request.dart';

class MdnAPI {

  final HttpClient _httpClient;

  MdnAPI(this._httpClient);

  Future<MDN?> sendReceiptToSender(
      AccountId accountId,
      SendReceiptToSenderRequest request,
  ) async {
    final mdnSendMethod = MDNSendMethod(
        accountId,
        {request.sendId: request.mdn},
        request.identityId
    )..addOnSuccessUpdateEmail({
      EmailSubmissionId(ReferenceId(ReferencePrefix.defaultPrefix, request.sendId)): PatchObject({
        KeyWordIdentifier.mdnSent.toPatchObjectJson(): true
      })
    });

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final mdnSendInvocation = requestBuilder.invocation(mdnSendMethod);
    final response = await (requestBuilder
        ..usings(mdnSendMethod.requiredCapabilities))
      .build()
      .execute();

    final mdnSendResponse = response.parse<MDNSendResponse>(
        mdnSendInvocation.methodCallId,
        MDNSendResponse.deserialize);

    return mdnSendResponse?.sent?[request.sendId];
  }
}