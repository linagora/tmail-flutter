import 'dart:async';

import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/reference_id.dart';
import 'package:jmap_dart_client/jmap/core/reference_prefix.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/submission/address.dart';
import 'package:jmap_dart_client/jmap/mail/email/submission/email_submission.dart';
import 'package:jmap_dart_client/jmap/mail/email/submission/email_submission_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/submission/envelope.dart';
import 'package:jmap_dart_client/jmap/mail/email/submission/set/set_email_submission_method.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:model/model.dart';

class EmailAPI {

  final HttpClient httpClient;

  EmailAPI(this.httpClient);

  Future<Email> getEmailContent(AccountId accountId, EmailId emailId) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(httpClient, processingInvocation);

    final getEmailMethod = GetEmailMethod(accountId)
      ..addIds({emailId.id})
      ..addProperties(Properties({'bodyValues', 'htmlBody', 'attachments'}))
      ..addFetchHTMLBodyValues(true);

    final getEmailInvocation = jmapRequestBuilder.invocation(getEmailMethod);

    final result = await (jmapRequestBuilder
        ..usings(getEmailMethod.requiredCapabilities))
      .build()
      .execute();

    final resultList = result.parse<GetEmailResponse>(
        getEmailInvocation.methodCallId, GetEmailResponse.deserialize);

    return Future.sync(() async {
      return resultList!.list.first;
    }).catchError((error) {
      throw error;
    });
  }

  Future<bool> sendEmail(AccountId accountId, EmailRequest emailRequest) async {
    final mailboxIdSaved = emailRequest.mailboxIdSaved ?? emailRequest.email.mailboxIds?.keys.first;

    final setEmailMethod = SetEmailMethod(accountId)
      ..addCreate(emailRequest.email.id.id, emailRequest.email);

    final setEmailSubmissionMethod = SetEmailSubmissionMethod(accountId)
      ..addCreate(
          emailRequest.submissionCreateId,
          EmailSubmission(
              emailId: EmailId(ReferenceId(ReferencePrefix.defaultPrefix, emailRequest.email.id.id)),
              envelope: Envelope(
                  Address(emailRequest.email.from?.first.email ?? ''),
                  emailRequest.email.getRecipientEmailAddressList().map((emailAddress) => Address(emailAddress)).toSet()
              )
          ))
      ..addOnSuccessUpdateEmail({
          EmailSubmissionId(ReferenceId(ReferencePrefix.defaultPrefix, emailRequest.submissionCreateId)): PatchObject({
            PatchObject.mailboxIdsProperty: {
              mailboxIdSaved?.id.value: true
            }
        })
      });

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);
    final setEmailSubmissionInvocation = requestBuilder.invocation(setEmailSubmissionMethod);

    final response = await (requestBuilder
        ..usings(setEmailSubmissionMethod.requiredCapabilities))
      .build()
      .execute();

    final setEmailResponse = response.parse<SetEmailResponse>(
      setEmailInvocation.methodCallId,
      SetEmailResponse.deserialize);

    final setEmailSubmissionResponse = response.parse<SetEmailResponse>(
      setEmailSubmissionInvocation.methodCallId,
      SetEmailResponse.deserialize,
      methodName: setEmailInvocation.methodName);

    return Future.sync(() async {
      final emailCreated = setEmailResponse!.created![emailRequest.email.id.id];
      return setEmailSubmissionResponse!.updated![emailCreated!.id.id] == null;
    }).catchError((error) {
      throw error;
    });
  }

  Future<bool> markAsRead(AccountId accountId, EmailId emailId, ReadActions readAction) async {
    final setEmailMethod = SetEmailMethod(accountId)
      ..addUpdates({
        emailId.id: KeyWordIdentifier.emailSeen.generateReadActionPath(readAction)
      });

    final requestBuilder = JmapRequestBuilder(httpClient, ProcessingInvocation());

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

    final response = await (requestBuilder
        ..usings(setEmailMethod.requiredCapabilities))
      .build()
      .execute();

    final setEmailResponse = response.parse<SetEmailResponse>(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize);

    return Future.sync(() async {
      final emailUpdated = setEmailResponse!.updated![emailId.id];
      return emailUpdated == null;
    }).catchError((error) {
      throw error;
    });
  }
}