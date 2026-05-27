import 'dart:math' hide log;

import 'package:core/utils/app_logger.dart';
import 'package:dio/dio.dart';
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
import 'package:tmail_ui_user/features/base/mixin/session_mixin.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';

typedef OnGeneratePatchObjectUpdates = Map<Id, PatchObject> Function(
  List<EmailId> batchIds,
);

mixin BatchSetEmailProcessingMixin
    on HandleSetErrorMixin, SessionMixin, MailAPIMixin {
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
    final batchSize = max(1, min(totalEmails, maxObjects));

    final List<EmailId> updatedEmailIds = List.empty(growable: true);
    final List<SetResponse> listSetResponse = List.empty(growable: true);

    for (int start = 0; start < totalEmails; start += batchSize) {
      int end =
          (start + batchSize < totalEmails) ? start + batchSize : totalEmails;
      final currentListEmailIds = emailIds.sublist(start, end);

      log('BatchSetEmailProcessingMixin::$debugLabel: processing batch ${start + 1} to $end');

      try {
        final response = await _executeSetEmailBatch(
          session: session,
          accountId: accountId,
          httpClient: httpClient,
          emailIds: currentListEmailIds,
          onGenerateUpdates: onGenerateUpdates,
        );

        if (response != null) {
          final listEmailIds = response.updated?.keys.toEmailIds() ?? [];
          updatedEmailIds.addAll(listEmailIds);
          listSetResponse.add(response);
        } else {
          throw Exception('SetEmailResponse is null');
        }
      } catch (e, stackTrace) {
        _handleBatchSetEmailErrors(
          e,
          stackTrace,
          '$debugLabel: batch ${start + 1}-$end',
        );
      }
    }

    Map<Id, SetError> finalMapErrors = <Id, SetError>{};
    if (listSetResponse.isNotEmpty) {
      finalMapErrors = handleSetResponse(listSetResponse);
    }

    return (emailIdsSuccess: updatedEmailIds, mapErrors: finalMapErrors);
  }

  bool _isSessionTerminatedError(Object error) {
    return error is DioException &&
        (error.response?.statusCode == 401 ||
            error.error is RefreshTokenFailedException);
  }

  void _handleBatchSetEmailErrors(
    Object error,
    StackTrace stackTrace,
    String batchContext,
  ) {
    if (_isSessionTerminatedError(error)) {
      logError(
        'BatchSetEmailProcessingMixin::$batchContext: session terminated: $error',
        exception: error,
        stackTrace: stackTrace,
      );
      throw error;
    } else {
      logWarning(
        'BatchSetEmailProcessingMixin::$batchContext: Error processing batch: $error',
      );
    }
  }

  Future<SetEmailResponse?> _executeSetEmailBatch({
    required Session session,
    required AccountId accountId,
    required HttpClient httpClient,
    required List<EmailId> emailIds,
    required OnGeneratePatchObjectUpdates onGenerateUpdates,
  }) async {
    final setEmailMethod = SetEmailMethod(accountId)
      ..addUpdates(onGenerateUpdates(emailIds));

    final requestBuilder = JmapRequestBuilder(
      httpClient,
      ProcessingInvocation(),
    );

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

    final capabilities = setEmailMethod.requiredCapabilities
        .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response =
        await (requestBuilder..usings(capabilities)).build().execute();

    return response.parse<SetEmailResponse>(
      setEmailInvocation.methodCallId,
      SetEmailResponse.deserialize,
    );
  }
}
