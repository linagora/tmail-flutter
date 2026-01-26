import 'dart:math' hide log;

import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/method/response/set_response.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_response.dart';
import 'package:model/extensions/list_id_extension.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/mail_api_mixin.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

typedef OnGeneratePatchObjectUpdates = Map<Id, PatchObject> Function(
  List<EmailId> batchIds,
);

mixin BatchSetEmailProcessingMixin on HandleSetErrorMixin, MailAPIMixin {
  Future<
      ({
        List<EmailId> emailIdsSuccess,
        Map<Id, SetError> mapErrors,
      })> executeBatchSetEmail({
    required Session session,
    required AccountId accountId,
    required List<EmailId> emailIds,
    required HttpClient httpClient,
    required OnGeneratePatchObjectUpdates onGenerateUpdates,
    String debugLabel = 'executeBatchSetEmail',
  }) async {
    if (emailIds.isEmpty) {
      return (emailIdsSuccess: <EmailId>[], mapErrors: <Id, SetError>{});
    }

    final maxObjects = getMaxObjectsInSetMethod(session, accountId);
    final totalEmails = emailIds.length;
    final batchSize = min(totalEmails, maxObjects);

    final List<EmailId> updatedEmailIds = List.empty(growable: true);
    final List<SetResponse> listSetResponse = List.empty(growable: true);

    for (int start = 0; start < totalEmails; start += batchSize) {
      int end =
          (start + batchSize < totalEmails) ? start + batchSize : totalEmails;

      log('EmailAPI::$debugLabel:emails from ${start + 1} to $end');

      final currentListEmailIds = emailIds.sublist(start, end);

      final setEmailMethod = SetEmailMethod(accountId)
        ..addUpdates(onGenerateUpdates(currentListEmailIds));

      final requestBuilder = JmapRequestBuilder(
        httpClient,
        ProcessingInvocation(),
      );
      final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

      final capabilities = setEmailMethod.requiredCapabilities
          .toCapabilitiesSupportTeamMailboxes(session, accountId);

      final response =
          await (requestBuilder..usings(capabilities)).build().execute();

      SetEmailResponse? setEmailResponse;
      try {
        setEmailResponse = response.parse<SetEmailResponse>(
          setEmailInvocation.methodCallId,
          SetEmailResponse.deserialize,
        );
      } catch (e) {
        log('EmailAPI::$debugLabel: Failed to parse response: $e');
        setEmailResponse = null;
      }

      if (setEmailResponse == null) {
        log('EmailAPI::$debugLabel: Batch from ${start + 1} to $end returned null response');
        continue;
      }

      final listEmailIds = setEmailResponse.updated?.keys.toEmailIds() ?? [];
      updatedEmailIds.addAll(listEmailIds);
      listSetResponse.add(setEmailResponse);
    }

    Map<Id, SetError> mapErrors = <Id, SetError>{};
    if (listSetResponse.isNotEmpty) {
      mapErrors = handleSetResponse(listSetResponse);
    }

    return (emailIdsSuccess: updatedEmailIds, mapErrors: mapErrors);
  }
}
