import 'dart:async';
import 'dart:io';

import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
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
import 'package:path_provider/path_provider.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';

class EmailAPI {

  final HttpClient _httpClient;
  final DownloadManager _downloadManager;

  EmailAPI(this._httpClient, this._downloadManager);

  Future<Email> getEmailContent(AccountId accountId, EmailId emailId) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

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

    if (emailRequest.emailIdDestroyed != null) {
      setEmailMethod
        ..addDestroy({emailRequest.emailIdDestroyed!.id});
    }

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
            },
            KeyWordIdentifier.emailSeen.generatePath(): true
        })
      });

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

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
      final emailCreated = setEmailResponse?.created?[emailRequest.email.id.id];
      if (emailCreated != null) {
        return setEmailSubmissionResponse?.updated?[emailCreated.id.id] == null;
      }
      return false;
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<Email>> markAsRead(AccountId accountId, List<Email> emails, ReadActions readActions) async {
    final emailIds = emails.map((email) => email.id).toList();

    final setEmailMethod = SetEmailMethod(accountId)
      ..addUpdates(emailIds.generateMapUpdateObjectMarkAsRead(readActions));

    final getEmailMethod = GetEmailMethod(accountId)
      ..addIds(emailIds.toIds().toSet())
      ..addProperties(Properties({'keywords'}));

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    requestBuilder.invocation(setEmailMethod);

    final getEmailInvocation = requestBuilder.invocation(getEmailMethod);

    final response = await (requestBuilder
        ..usings(setEmailMethod.requiredCapabilities))
      .build()
      .execute();

    final getEmailResponse = response.parse<GetEmailResponse>(
      getEmailInvocation.methodCallId,
      GetEmailResponse.deserialize);

    return Future.sync(() async {
      return getEmailResponse!.list;
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<DownloadTaskId>> downloadAttachments(
      List<Attachment> attachments,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest
  ) async {
    var externalStorageDirPath;
    if (Platform.isAndroid) {
      externalStorageDirPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    } else {
      throw DeviceNotSupportedException();
    }

    final taskIds = await Future.wait(
      attachments.map((attachment) async => await FlutterDownloader.enqueue(
        url: attachment.getDownloadUrl(baseDownloadUrl, accountId),
        savedDir: externalStorageDirPath,
        headers: {
          HttpHeaders.authorizationHeader: accountRequest.basicAuth,
          HttpHeaders.acceptHeader: DioClient.jmapHeader
        },
        fileName: attachment.name,
        showNotification: true,
        openFileFromNotification: true)));

    return taskIds
      .where((taskId) => taskId != null)
      .map((taskId) => DownloadTaskId(taskId!))
      .toList();
  }

  Future<String> exportAttachment(
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest,
      CancelToken cancelToken
  ) async {
    return _downloadManager.downloadFile(
      attachment.getDownloadUrl(baseDownloadUrl, accountId),
      getTemporaryDirectory(),
      attachment.name ?? '',
      accountRequest.basicAuth,
      cancelToken: cancelToken);
  }

  Future<bool> downloadAttachmentForWeb(
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest,
  ) async {
    return _downloadManager.downloadFileForWeb(
        attachment.getDownloadUrl(baseDownloadUrl, accountId),
        attachment.name ?? '',
        accountRequest.basicAuth,
    );
  }

  Future<List<EmailId>> moveToMailbox(AccountId accountId, MoveToMailboxRequest moveRequest) async {
    final setEmailMethod = SetEmailMethod(accountId)
      ..addUpdates(moveRequest.emailIds
          .generateMapUpdateObjectMoveToMailbox(moveRequest.currentMailboxId, moveRequest.destinationMailboxId));

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

    final response = await (requestBuilder
        ..usings(setEmailMethod.requiredCapabilities))
      .build()
      .execute();

    final setEmailResponse = response.parse<SetEmailResponse>(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize);

    return Future.sync(() async {
      final mapUpdated = setEmailResponse!.updated!;
      return moveRequest.emailIds
        .where((emailId) => mapUpdated.containsKey(emailId.id))
        .toList();
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<Email>> markAsStar(AccountId accountId, List<Email> emails, MarkStarAction markStarAction) async {
    final emailIds = emails.map((email) => email.id).toList();

    final setEmailMethod = SetEmailMethod(accountId)
      ..addUpdates(emailIds.generateMapUpdateObjectMarkAsStar(markStarAction));

    final getEmailMethod = GetEmailMethod(accountId)
      ..addIds(emailIds.toIds().toSet())
      ..addProperties(Properties({'keywords'}));

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    requestBuilder.invocation(setEmailMethod);

    final getEmailInvocation = requestBuilder.invocation(getEmailMethod);

    final response = await (requestBuilder
        ..usings(setEmailMethod.requiredCapabilities))
      .build()
      .execute();

    final getEmailResponse = response.parse<GetEmailResponse>(
      getEmailInvocation.methodCallId,
      GetEmailResponse.deserialize);

    return Future.sync(() async {
      return getEmailResponse!.list;
    }).catchError((error) {
      throw error;
    });
  }

  Future<Email?> saveEmailAsDrafts(AccountId accountId, Email email) async {
    final setEmailMethod = SetEmailMethod(accountId)
      ..addCreate(email.id.id, email);

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

    final response = await (requestBuilder
        ..usings(setEmailMethod.requiredCapabilities))
      .build()
      .execute();

    final setEmailResponse = response.parse<SetEmailResponse>(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize);

    return Future.sync(() async {
      return setEmailResponse?.created?[email.id.id];
    }).catchError((error) {
      throw error;
    });
  }

  Future<bool> removeEmailDrafts(AccountId accountId, EmailId emailId) async {
    final setEmailMethod = SetEmailMethod(accountId)
      ..addDestroy({emailId.id});

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

    final response = await (requestBuilder
        ..usings(setEmailMethod.requiredCapabilities))
      .build()
      .execute();

    final setEmailResponse = response.parse<SetEmailResponse>(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize);

    return Future.sync(() async {
      return setEmailResponse?.destroyed?.contains(emailId.id) == true;
    }).catchError((error) {
      throw error;
    });
  }

  Future<Email?> updateEmailDrafts(AccountId accountId, Email newEmail, EmailId oldEmailId) async {
    final setEmailMethod = SetEmailMethod(accountId)
      ..addCreate(newEmail.id.id, newEmail)
      ..addDestroy({oldEmailId.id});

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

    final response = await (requestBuilder
        ..usings(setEmailMethod.requiredCapabilities))
      .build()
      .execute();

    final setEmailResponse = response.parse<SetEmailResponse>(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize);

    return Future.sync(() async {
      final emailUpdated = setEmailResponse?.created?[newEmail.id.id];
      final emailDestroyed = setEmailResponse?.destroyed?.contains(oldEmailId.id);
      if (emailUpdated != null && emailDestroyed == true) {
        return emailUpdated;
      }
      return null;
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<EmailId>> deleteMultipleEmailsPermanently(AccountId accountId, List<EmailId> emailIds) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final setEmailMethod = SetEmailMethod(accountId)
      ..addDestroy(emailIds.map((emailId) => emailId.id).toSet());

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

    final response = await (requestBuilder
        ..usings(setEmailMethod.requiredCapabilities))
      .build()
      .execute();

    final setEmailResponse = response.parse<SetEmailResponse>(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize);

    final listIdResult = setEmailResponse?.destroyed;

    if (listIdResult != null) {
      return listIdResult.map((id) => EmailId(id)).toList();
    }

    return List.empty();
  }

  Future<bool> deleteEmailPermanently(AccountId accountId, EmailId emailId) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final setEmailMethod = SetEmailMethod(accountId)
      ..addDestroy(Set.of([emailId.id]));

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

    final response = await (requestBuilder
        ..usings(setEmailMethod.requiredCapabilities))
      .build()
      .execute();

    final setEmailResponse = response.parse<SetEmailResponse>(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize);

    return setEmailResponse?.destroyed?.contains(emailId.id) == true;
  }
}