import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:email_recovery/email_recovery/email_recovery_action.dart';
import 'package:email_recovery/email_recovery/email_recovery_action_id.dart';
import 'package:email_recovery/email_recovery/get/get_email_recovery_action_method.dart';
import 'package:email_recovery/email_recovery/get/get_email_recovery_action_response.dart';
import 'package:email_recovery/email_recovery/set/set_email_recovery_action_method.dart';
import 'package:email_recovery/email_recovery/set/set_email_recovery_action_response.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/error/set_error.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/patch_object.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/reference_id.dart';
import 'package:jmap_dart_client/jmap/core/reference_prefix.dart';
import 'package:jmap_dart_client/jmap/core/request/request_invocation.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/jmap_request.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/get/get_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/keyword_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/email/parse/parse_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/parse/parse_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/set/set_email_response.dart';
import 'package:jmap_dart_client/jmap/mail/email/submission/address.dart';
import 'package:jmap_dart_client/jmap/mail/email/submission/email_submission.dart';
import 'package:jmap_dart_client/jmap/mail/email/submission/email_submission_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/submission/envelope.dart';
import 'package:jmap_dart_client/jmap/mail/email/submission/set/set_email_submission_method.dart';
import 'package:jmap_dart_client/jmap/mail/email/submission/set/set_email_submission_response.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/set/set_mailbox_method.dart';
import 'package:model/account/account_request.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/download/download_task_id.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';
import 'package:model/extensions/list_email_id_extension.dart';
import 'package:model/extensions/list_id_extension.dart';
import 'package:model/extensions/mailbox_id_extension.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/base/mixin/mail_api_mixin.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/download/domain/model/download_source_view.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_all_attachments_for_web_state.dart';
import 'package:tmail_ui_user/features/download/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:uri/uri.dart';
import 'package:uuid/uuid.dart';

class EmailAPI with HandleSetErrorMixin, MailAPIMixin {

  final HttpClient _httpClient;
  final DownloadManager _downloadManager;
  final DioClient _dioClient;
  final Uuid _uuid;

  EmailAPI(this._httpClient, this._downloadManager, this._dioClient, this._uuid);

  Future<Email> getEmailContent(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {Properties? additionalProperties}
  ) async {
    final processingInvocation = ProcessingInvocation();

    final jmapRequestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final getEmailMethod = GetEmailMethod(accountId)
      ..addIds({emailId.id})
      ..addProperties(ThreadConstants.propertiesGetEmailContent)
      ..addFetchHTMLBodyValues(true);
    if (additionalProperties != null) {
      getEmailMethod.addProperties(additionalProperties);
    }

    final getEmailInvocation = jmapRequestBuilder.invocation(getEmailMethod);

    final capabilities = getEmailMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (jmapRequestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final resultList = result.parse<GetEmailResponse>(
      getEmailInvocation.methodCallId,
      GetEmailResponse.deserialize
    );

    if (resultList?.list.isNotEmpty == true) {
      return resultList!.list.first;
    } else {
      throw NotFoundEmailException();
    }
  }

  Future<void> sendEmail(
    Session session,
    AccountId accountId,
    EmailRequest emailRequest,
    {
      CreateNewMailboxRequest? mailboxRequest,
      CancelToken? cancelToken,
    }
  ) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    Email? emailNeedsToBeCreated;
    MailboxId? outboxMailboxId;

    if (mailboxRequest != null) {
      final generateCreateId = Id(_uuid.v1());
      final setMailboxMethod = SetMailboxMethod(accountId)
        ..addCreate(
            generateCreateId,
            Mailbox(
              name: mailboxRequest.newName,
              parentId: mailboxRequest.parentId,
              isSubscribed: IsSubscribed(mailboxRequest.isSubscribed)
            )
        );

      requestBuilder.invocation(setMailboxMethod);

      outboxMailboxId = MailboxId(ReferenceId(
          ReferencePrefix.defaultPrefix,
          generateCreateId));
      emailNeedsToBeCreated = emailRequest.email.updatedEmail(newMailboxIds: {outboxMailboxId: true});
    } else {
      outboxMailboxId = emailRequest.email.mailboxIds?.keys.first;
      emailNeedsToBeCreated = emailRequest.email;
    }

    final idCreateMethod = Id(_uuid.v1());
    final setEmailMethod = SetEmailMethod(accountId)
      ..addCreate(idCreateMethod, emailNeedsToBeCreated);

    final submissionCreateId = Id(_uuid.v1());
    final mailFrom = Address(emailNeedsToBeCreated.from?.first.email ?? '');
    final recipientsList = emailNeedsToBeCreated.getRecipientEmailAddressList()
      .map((emailAddress) => Address(emailAddress))
      .toSet();
    final emailSubmissionId = EmailSubmissionId(ReferenceId(ReferencePrefix.defaultPrefix, submissionCreateId));
    Map<EmailSubmissionId, PatchObject> mapEmailSubmissionUpdated = {
      emailSubmissionId: PatchObject({
        if (emailRequest.sentMailboxId != null)
          emailRequest.sentMailboxId!.generatePath() : true,
        outboxMailboxId!.generatePath() : null,
        KeyWordIdentifier.emailSeen.generatePath(): true,
        KeyWordIdentifier.emailDraft.generatePath(): null
      })
    };
    final emailSubmission = EmailSubmission(
      identityId: emailRequest.identityId?.id,
      emailId: EmailId(ReferenceId(ReferencePrefix.defaultPrefix, idCreateMethod)),
      envelope: Envelope(mailFrom, recipientsList));

    final setEmailSubmissionMethod = SetEmailSubmissionMethod(accountId)
      ..addCreate(submissionCreateId, emailSubmission)
      ..addOnSuccessUpdateEmail(mapEmailSubmissionUpdated);

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);
    final setEmailSubmissionInvocation = requestBuilder.invocation(setEmailSubmissionMethod);

    SetEmailMethod? markAsAnsweredOrForwardedSetMethod;
    RequestInvocation? markAsAnsweredOrForwardedInvocation;
    SetEmailResponse? markAsAnsweredOrForwardedSetResponse;

    if (emailRequest.isEmailAnswered) {
      markAsAnsweredOrForwardedSetMethod = SetEmailMethod(accountId)
        ..addUpdates([emailRequest.emailIdAnsweredOrForwarded!].generateMapUpdateObjectMarkAsAnswered());

      markAsAnsweredOrForwardedInvocation = requestBuilder.invocation(markAsAnsweredOrForwardedSetMethod);
    } else if (emailRequest.isEmailForwarded) {
      markAsAnsweredOrForwardedSetMethod = SetEmailMethod(accountId)
        ..addUpdates([emailRequest.emailIdAnsweredOrForwarded!].generateMapUpdateObjectMarkAsForwarded());

      markAsAnsweredOrForwardedInvocation = requestBuilder.invocation(markAsAnsweredOrForwardedSetMethod);
    }

    final capabilities = setEmailSubmissionMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute(cancelToken: cancelToken);

    final setEmailResponse = response.parse<SetEmailResponse>(
      setEmailInvocation.methodCallId,
      SetEmailResponse.deserialize);

    final setEmailSubmissionResponse = response.parse<SetEmailSubmissionResponse>(
      setEmailSubmissionInvocation.methodCallId,
      SetEmailSubmissionResponse.deserialize,
      methodName: setEmailInvocation.methodName);

    if (markAsAnsweredOrForwardedInvocation != null) {
      markAsAnsweredOrForwardedSetResponse = response.parse<SetEmailResponse>(
        markAsAnsweredOrForwardedInvocation.methodCallId,
        SetEmailResponse.deserialize);
    }

    final emailCreated = setEmailResponse?.created?[idCreateMethod];
    final mapErrors = handleSetResponse([
      setEmailResponse,
      setEmailSubmissionResponse,
      markAsAnsweredOrForwardedSetResponse
    ]);

    if (emailCreated == null || mapErrors.isNotEmpty) {
      throw SetMethodException(mapErrors);
    }
  }

  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> markAsRead(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    ReadActions readActions,
  ) async {
    final maxObjects = getMaxObjectsInSetMethod(session, accountId);
    final totalEmails = emailIds.length;
    final maxBatches = min(totalEmails, maxObjects);

    final List<EmailId> updatedEmailIds = List.empty(growable: true);
    final Map<Id, SetError> mapErrors = <Id, SetError>{};

    for (int start = 0; start < totalEmails; start += maxBatches) {
      int end = (start + maxBatches < totalEmails)
        ? start + maxBatches
        : totalEmails;
      log('EmailAPI::markAsRead:emails from ${start + 1} to $end');

      final currentListEmailIds = emailIds.sublist(start, end);

      final setEmailMethod = SetEmailMethod(accountId)
        ..addUpdates(
            currentListEmailIds.generateMapUpdateObjectMarkAsRead(readActions)
          );

      final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

      final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

      final capabilities = setEmailMethod.requiredCapabilities
          .toCapabilitiesSupportTeamMailboxes(session, accountId);

      final response = await (requestBuilder
          ..usings(capabilities))
        .build()
        .execute();

      final setEmailResponse = response.parse<SetEmailResponse>(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize,
      );

      final listEmailIds = setEmailResponse?.updated?.keys.toEmailIds() ?? [];
      final mapErrors = handleSetResponse([setEmailResponse]);

      updatedEmailIds.addAll(listEmailIds);
      mapErrors.addAll(mapErrors);
    }

    return (emailIdsSuccess: updatedEmailIds, mapErrors: mapErrors);
  }

  Future<DownloadedResponse> exportAttachment(
      Attachment attachment,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest,
      CancelToken cancelToken
  ) async {
    final authentication = accountRequest.authenticationType == AuthenticationType.oidc
      ? accountRequest.bearerToken
      : accountRequest.basicAuth;

    return _downloadManager.downloadFile(
      attachment.getDownloadUrl(baseDownloadUrl, accountId),
      getTemporaryDirectory(),
      attachment.name ?? '',
      authentication,
      cancelToken: cancelToken);
  }

  Future<Uint8List> downloadAttachmentForWeb(
    DownloadTaskId taskId,
    Attachment attachment,
    AccountId accountId,
    String baseDownloadUrl,
    AccountRequest accountRequest, {
    StreamController<Either<Failure, Success>>? onReceiveController,
    CancelToken? cancelToken,
  }) async {
    final authentication = accountRequest.authenticationType == AuthenticationType.oidc
        ? accountRequest.bearerToken
        : accountRequest.basicAuth;
    final downloadUrl = attachment.getDownloadUrl(baseDownloadUrl, accountId);
    log('EmailAPI::downloadAttachmentForWeb(): downloadUrl: $downloadUrl');

    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.authorizationHeader] = authentication;
    headerParam[HttpHeaders.acceptHeader] = DioClient.jmapHeader;

    final bytesDownloaded = await _dioClient.get(
        downloadUrl,
        options: Options(
            headers: headerParam,
            responseType: ResponseType.bytes),
        cancelToken: cancelToken,
        onReceiveProgress: (downloaded, total) {
          log('EmailAPI::downloadFileForWeb(): downloaded = $downloaded | total: $total');
          double progress = 0;
          if (downloaded > 0 && total >= downloaded) {
            progress = (downloaded / total) * 100;
          }
          log('EmailAPI::downloadFileForWeb(): progress = ${progress.round()}%');
          onReceiveController?.add(
            Right(
              DownloadingAttachmentForWeb(
                taskId,
                attachment,
                progress,
                downloaded,
                total,
                DownloadSourceView.emailView,
              ),
            ),
          );
        }
    );

    return bytesDownloaded;
  }

  Future<void> downloadAllAttachmentsForWeb(
    AccountId accountId,
    EmailId emailId,
    String baseDownloadAllUrl,
    String outputFileName,
    AccountRequest accountRequest,
    DownloadTaskId taskId, {
    StreamController<Either<Failure, Success>>? onReceiveController,
    CancelToken? cancelToken,
  }) async {
    final authentication = accountRequest.authenticationType == AuthenticationType.oidc
        ? accountRequest.bearerToken
        : accountRequest.basicAuth;
    final headerParam = _dioClient.getHeaders();
    headerParam[HttpHeaders.authorizationHeader] = authentication;
    headerParam[HttpHeaders.acceptHeader] = DioClient.jmapHeader;
    
    final downloadAllUriTemplate = UriTemplate(Uri.decodeFull(baseDownloadAllUrl));
    final downloadAllUrl = downloadAllUriTemplate.expand({
      'accountId': accountId.asString,
      'emailId': emailId.asString,
      'name': outputFileName,
    });
    final downloadFileName = '$outputFileName.zip';

    final bytesDownloaded = await _dioClient.get(
      downloadAllUrl,
      options: Options(
        headers: headerParam,
        responseType: ResponseType.bytes),
      onReceiveProgress: (downloaded, total) {
        log('EmailAPI::downloadFileForWeb(): downloaded = $downloaded | total: $total');
        double progress = 0;
        if (downloaded > 0 && total >= downloaded) {
          progress = (downloaded / total) * 100;
        }
        log('EmailAPI::downloadFileForWeb(): progress = ${progress.round()}%');
        onReceiveController?.add(Right(DownloadingAllAttachmentsForWeb(
          taskId,
          downloadFileName,
          progress,
          downloaded,
          total > 0 ? total : 0,
        )));
      },
      cancelToken: cancelToken,
    );

    _downloadManager.createAnchorElementDownloadFileWeb(
      bytesDownloaded,
      downloadFileName,
    );
  }

  Future<DownloadedResponse> exportAllAttachments(
    AccountId accountId,
    EmailId emailId,
    String baseDownloadAllUrl,
    String outputFileName,
    AccountRequest accountRequest,
    {CancelToken? cancelToken}
  ) async {
    final authentication = accountRequest.authenticationType == AuthenticationType.oidc
      ? accountRequest.bearerToken
      : accountRequest.basicAuth;

    final downloadAllUriTemplate = UriTemplate(Uri.decodeFull(baseDownloadAllUrl));
    final downloadAllUrl = downloadAllUriTemplate.expand({
      'accountId': accountId.asString,
      'emailId': emailId.asString,
      'name': outputFileName,
    });
    final downloadFileName = '$outputFileName.zip';

    return _downloadManager.downloadFile(
      downloadAllUrl,
      getTemporaryDirectory(),
      downloadFileName,
      authentication,
      cancelToken: cancelToken);
  }

  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> moveToMailbox(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest
  ) async {
    final List<EmailId> listEmailIdResult = List.empty(growable: true);
    final Map<Id, SetError> mapErrors = <Id, SetError>{};

    final listMailboxIds = moveRequest.currentMailboxes.keys.toList();
    for (int i = 0; i < listMailboxIds.length; i++) {
      final currentMailboxId = listMailboxIds[i];
      final listEmailIds = moveRequest.currentMailboxes[currentMailboxId]!;
      log('EmailAPI::moveToMailbox:from mailbox ${currentMailboxId.asString} with ${listEmailIds.length} emails to mailbox ${moveRequest.destinationMailboxId.asString}');
      final resultRecords = await moveEmailsBetweenMailboxes(
        httpClient: _httpClient,
        session: session,
        accountId: accountId,
        emailIds: listEmailIds,
        currentMailboxId: currentMailboxId,
        destinationMailboxId: moveRequest.destinationMailboxId,
        markAsRead: moveRequest.isMovingToSpam,
      );

      listEmailIdResult.addAll(resultRecords.emailIdsSuccess);
      mapErrors.addAll(resultRecords.mapErrors);
    }

    return (emailIdsSuccess: listEmailIdResult, mapErrors: mapErrors);
  }

  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> markAsStar(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    MarkStarAction markStarAction
  ) async {
    final maxObjects = getMaxObjectsInSetMethod(session, accountId);
    final totalEmails = emailIds.length;
    final maxBatches = min(totalEmails, maxObjects);

    final List<EmailId> updatedEmailIds = List.empty(growable: true);
    final Map<Id, SetError> mapErrors = <Id, SetError>{};

    for (int start = 0; start < totalEmails; start += maxBatches) {
      int end = (start + maxBatches < totalEmails)
        ? start + maxBatches
        : totalEmails;
      log('EmailAPI::markAsStar:emails from ${start + 1} to $end');

      final currentListEmailIds = emailIds.sublist(start, end);

      final setEmailMethod = SetEmailMethod(accountId)
        ..addUpdates(
            currentListEmailIds.generateMapUpdateObjectMarkAsStar(markStarAction),
          );

      final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

      final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

      final capabilities = setEmailMethod.requiredCapabilities
          .toCapabilitiesSupportTeamMailboxes(session, accountId);

      final response = await (requestBuilder
          ..usings(capabilities))
        .build()
        .execute();

      final setEmailResponse = response.parse<SetEmailResponse>(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize,
      );

      final listEmailIds = setEmailResponse?.updated?.keys.toEmailIds() ?? [];
      final mapErrors = handleSetResponse([setEmailResponse]);

      updatedEmailIds.addAll(listEmailIds);
      mapErrors.addAll(mapErrors);
    }

    return (emailIdsSuccess: updatedEmailIds, mapErrors: mapErrors);
  }

  Future<Email> _emailSetCreateMethod(
    Session session,
    AccountId accountId,
    Email email,
    {
      CreateNewMailboxRequest? createNewMailboxRequest,
      CancelToken? cancelToken
    }
  ) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    MailboxId? mailboxId;
    if (createNewMailboxRequest != null) {
      final generateCreateId = Id(_uuid.v1());
      final setMailboxMethod = SetMailboxMethod(accountId)
        ..addCreate(
            generateCreateId,
            Mailbox(
              name: createNewMailboxRequest.newName,
              parentId: createNewMailboxRequest.parentId,
              isSubscribed: IsSubscribed(createNewMailboxRequest.isSubscribed)
            )
        );

      requestBuilder.invocation(setMailboxMethod);

      mailboxId = MailboxId(ReferenceId(
          ReferencePrefix.defaultPrefix,
          generateCreateId));
    } else {
      mailboxId = email.mailboxIds?.keys.first;
    }
    if (mailboxId != null) {
      email.mailboxIds?.addAll({mailboxId: true});
    }
    final idCreateMethod = Id(_uuid.v1());
    final setEmailMethod = SetEmailMethod(accountId)
      ..addCreate(idCreateMethod, email);

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

    final capabilities = setEmailMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute(cancelToken: cancelToken);

    final setEmailResponse = response.parse<SetEmailResponse>(
      setEmailInvocation.methodCallId,
      SetEmailResponse.deserialize
    );

    final emailCreated = setEmailResponse?.created?[idCreateMethod];
    final mapErrors = handleSetResponse([setEmailResponse]);

    if (emailCreated != null && mapErrors.isEmpty) {
      return emailCreated;
    } else {
      throw SetMethodException(mapErrors);
    }
  }

  Future<bool> _emailSetDestroyMethod(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {CancelToken? cancelToken}
  ) async {
    final setEmailMethod = SetEmailMethod(accountId)
      ..addDestroy({emailId.id});

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

    final capabilities = setEmailMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute(cancelToken: cancelToken);

    final setEmailResponse = response.parse<SetEmailResponse>(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize);

    final isEmailDestroyed = setEmailResponse?.destroyed?.contains(emailId.id) ?? false;
    final mapErrors = handleSetResponse([setEmailResponse]);

    if (isEmailDestroyed && mapErrors.isEmpty) {
      return isEmailDestroyed;
    } else {
      throw SetMethodException(mapErrors);
    }
  }

  Future<Email> saveEmailAsDrafts(
    Session session,
    AccountId accountId,
    Email email,
    {CancelToken? cancelToken}
  ) => _emailSetCreateMethod(session, accountId, email, cancelToken: cancelToken);

  Future<bool> removeEmailDrafts(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {CancelToken? cancelToken}
  ) => _emailSetDestroyMethod(session, accountId, emailId, cancelToken: cancelToken);

  Future<Email> updateEmailDrafts(
    Session session,
    AccountId accountId,
    Email newEmail,
    EmailId oldEmailId,
    {CancelToken? cancelToken}
  ) async {
    final emailCreated = await saveEmailAsDrafts(
      session,
      accountId,
      newEmail,
      cancelToken: cancelToken
    );

    try {
      await removeEmailDrafts(
        session,
        accountId,
        oldEmailId,
        cancelToken: cancelToken
      );
    } catch (e) {
      logError('EmailAPI::updateEmailDrafts: Exception = $e');
    }

    return emailCreated;
  }

  Future<Email> saveEmailAsTemplate(
    Session session,
    AccountId accountId,
    Email email,
    {
      CreateNewMailboxRequest? createNewMailboxRequest,
      CancelToken? cancelToken
    }
  ) => _emailSetCreateMethod(session, accountId, email, createNewMailboxRequest: createNewMailboxRequest, cancelToken: cancelToken);

  Future<bool> removeEmailTemplate(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {CancelToken? cancelToken}
  ) => _emailSetDestroyMethod(session, accountId, emailId, cancelToken: cancelToken);

  Future<Email> updateEmailTemplate(
    Session session,
    AccountId accountId,
    Email newEmail,
    EmailId oldEmailId,
    {CancelToken? cancelToken}
  ) async {
    final emailCreated = await saveEmailAsTemplate(
      session,
      accountId,
      newEmail,
      cancelToken: cancelToken
    );

    try {
      await removeEmailTemplate(
        session,
        accountId,
        oldEmailId,
        cancelToken: cancelToken
      );
    } catch (e) {
      logError('EmailAPI::updateEmailTemplate: Exception = $e');
    }

    return emailCreated;
  }

  Future<({
    List<EmailId> emailIdsSuccess,
    Map<Id, SetError> mapErrors,
  })> deleteMultipleEmailsPermanently(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds
  ) async {
    final maxObjects = getMaxObjectsInSetMethod(session, accountId);
    final totalEmails = emailIds.length;
    final maxBatches = min(totalEmails, maxObjects);

    final List<EmailId> destroyedEmailIds = List.empty(growable: true);
    final Map<Id, SetError> mapErrors = <Id, SetError>{};

    for (int start = 0; start < totalEmails; start += maxBatches) {
      int end = (start + maxBatches < totalEmails)
          ? start + maxBatches
          : totalEmails;
      log('EmailAPI::deleteMultipleEmailsPermanently:emails from ${start + 1} to $end');

      final currentListEmailIds = emailIds.sublist(start, end);

      final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
      final setEmailMethod = SetEmailMethod(accountId)
        ..addDestroy(currentListEmailIds.toIds().toSet());

      final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

      final capabilities = setEmailMethod.requiredCapabilities
        .toCapabilitiesSupportTeamMailboxes(session, accountId);

      final response = await (requestBuilder
          ..usings(capabilities))
        .build()
        .execute();

      final setEmailResponse = response.parse<SetEmailResponse>(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize,
      );

      final listEmailIds = setEmailResponse?.destroyed?.toEmailIds() ?? [];
      final mapErrors = handleSetResponse([setEmailResponse]);

      destroyedEmailIds.addAll(listEmailIds);
      mapErrors.addAll(mapErrors);
    }

    return (emailIdsSuccess: destroyedEmailIds, mapErrors: mapErrors);
  }

  Future<bool> deleteEmailPermanently(
    Session session,
    AccountId accountId,
    EmailId emailId,
    {CancelToken? cancelToken}
  ) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final setEmailMethod = SetEmailMethod(accountId)
      ..addDestroy({emailId.id});

      final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

      final capabilities = setEmailMethod.requiredCapabilities
          .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute(cancelToken: cancelToken);

      final setEmailResponse = response.parse<SetEmailResponse>(
        setEmailInvocation.methodCallId,
        SetEmailResponse.deserialize,
      );

    return setEmailResponse?.destroyed?.contains(emailId.id) == true;
  }

  Future<Email> getDetailedEmailById(
    Session session,
    AccountId accountId,
    EmailId emailId
  ) async {
    final jmapRequestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());

    final getEmailMethod = GetEmailMethod(accountId)
      ..addIds({emailId.id})
      ..addProperties(ThreadConstants.propertiesGetDetailedEmail)
      ..addFetchHTMLBodyValues(true);

    final getEmailInvocation = jmapRequestBuilder.invocation(getEmailMethod);

    final capabilities = getEmailMethod.requiredCapabilities.toCapabilitiesSupportTeamMailboxes(session, accountId);

    final result = await (jmapRequestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final resultList = result.parse<GetEmailResponse>(
      getEmailInvocation.methodCallId,
      GetEmailResponse.deserialize);

    if (resultList?.list.isNotEmpty == true) {
      return resultList!.list.first;
    } else {
      throw NotFoundEmailException();
    }
  }

  Future<void> unsubscribeMail(Session session, AccountId accountId, EmailId emailId) async {
    final setEmailMethod = SetEmailMethod(accountId)
      ..addUpdates(emailId.generateMapUpdateObjectUnsubscribeMail());

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    requestBuilder.invocation(setEmailMethod);
    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

    final capabilities = setEmailMethod.requiredCapabilities.toCapabilitiesSupportTeamMailboxes(session, accountId);

      final response = await (requestBuilder
          ..usings(capabilities))
        .build()
        .execute();

    final setEmailResponse = response.parse<SetEmailResponse>(
      setEmailInvocation.methodCallId,
      SetEmailResponse.deserialize,
    );

    final emailIdUpdated = setEmailResponse?.updated
        ?.keys
        .map((id) => EmailId(id))
        .toList() ?? [];
    final mapErrors = handleSetResponse([setEmailResponse]);

    if (emailIdUpdated.isEmpty) {
      throw SetMethodException(mapErrors);
    }
  }

  Future<EmailRecoveryAction> restoreDeletedMessage(RestoredDeletedMessageRequest restoredDeletedMessageRequest) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final emailRecoveryActionSetMethod = SetEmailRecoveryActionMethod()
      ..addCreate(
        restoredDeletedMessageRequest.createRequestId,
        restoredDeletedMessageRequest.emailRecoveryAction
      );
    final emailRecoveryActionSetInvocation = requestBuilder.invocation(emailRecoveryActionSetMethod);
    final response = await (requestBuilder
        ..usings(emailRecoveryActionSetMethod.requiredCapabilities))
      .build()
      .execute();

    final emailRecoveryActionSetResponse = response.parse<SetEmailRecoveryActionResponse>(
      emailRecoveryActionSetInvocation.methodCallId,
      SetEmailRecoveryActionResponse.deserialize
    );

    return emailRecoveryActionSetResponse!.created![restoredDeletedMessageRequest.createRequestId]!;
  }

  Future<EmailRecoveryAction> getRestoredDeletedMessage(EmailRecoveryActionId emailRecoveryActionId) async {
    final processingInvocation = ProcessingInvocation();
    final requestBuilder = JmapRequestBuilder(_httpClient, processingInvocation);

    final getEmailRecoveryActionMethod = GetEmailRecoveryActionMethod()
      ..addIds({emailRecoveryActionId.id});
    final getEmailRecoveryActionInvocation = requestBuilder.invocation(getEmailRecoveryActionMethod);

    final response = await (requestBuilder
        ..usings(getEmailRecoveryActionMethod.requiredCapabilities))
      .build()
      .execute();

    final getEmailRecoveryActionResponse = response.parse<GetEmailRecoveryActionResponse>(
      getEmailRecoveryActionInvocation.methodCallId,
      GetEmailRecoveryActionResponse.deserialize
    );

    if (getEmailRecoveryActionResponse?.list.isNotEmpty == true) {
      return getEmailRecoveryActionResponse!.list.firstWhere((element) => element.id == emailRecoveryActionId);
    } else {
      throw NotFoundEmailRecoveryActionException();
    }
  }

  Future<List<Email>> parseEmailByBlobIds(AccountId accountId, Set<Id> blobIds) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final parseEmailMethod = ParseEmailMethod(accountId, blobIds)
      ..addProperties(ThreadConstants.propertiesParseEmailByBlobId)
      ..addFetchHTMLBodyValues(true);
    final parseEmailInvocation = requestBuilder.invocation(parseEmailMethod);

    final response = await (requestBuilder
        ..usings(parseEmailMethod.requiredCapabilities))
      .build()
      .execute();

    final parseEmailResponse = response.parse<ParseEmailResponse>(
      parseEmailInvocation.methodCallId,
      ParseEmailResponse.deserialize);

    if (parseEmailResponse?.parsed?.isNotEmpty == true) {
      return parseEmailResponse!.parsed!.values.toList();
    } else if (parseEmailResponse?.notParsable?.isNotEmpty == true) {
      throw NotParsableBlobIdToEmailException(ids: parseEmailResponse!.notParsable!);
    } else if (parseEmailResponse?.notFound?.isNotEmpty == true) {
      throw NotFoundBlobIdException(parseEmailResponse!.notFound!);
    } else {
      throw NotParsableBlobIdToEmailException();
    }
  }

  Future<void> addLabelToEmail(
    Session session,
    AccountId accountId,
    EmailId emailId,
    KeyWordIdentifier labelKeyword,
  ) async {
    final method = SetEmailMethod(accountId)
      ..addUpdates({emailId.id: labelKeyword.generateLabelActionPath()});

    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final invocation = builder.invocation(method);

    final capabilities = method.requiredCapabilities
        .toCapabilitiesSupportTeamMailboxes(session, accountId);
    final result = await (builder..usings(capabilities)).build().execute();

    final response = result.parse<SetEmailResponse>(
      invocation.methodCallId,
      SetEmailResponse.deserialize,
    );

    final emailIdsUpdated = response?.updated?.keys ?? <Id>[];

    if (emailIdsUpdated.isEmpty || !emailIdsUpdated.contains(emailId.id)) {
      throw parseErrorForSetResponse(response, emailId.id);
    }
  }

  Future<void> addLabelToThread(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    KeyWordIdentifier labelKeyword,
  ) async {
    final method = SetEmailMethod(accountId)
      ..addUpdates(emailIds.generateMapUpdateObjectLabel(labelKeyword));

    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final invocation = builder.invocation(method);

    final capabilities = method.requiredCapabilities
        .toCapabilitiesSupportTeamMailboxes(session, accountId);
    final result = await (builder..usings(capabilities)).build().execute();

    final response = result.parse<SetEmailResponse>(
      invocation.methodCallId,
      SetEmailResponse.deserialize,
    );

    final emailIdsUpdated = response?.updated?.keys ?? <Id>[];
    final ids = emailIds.map((emailId) => emailId.id);
    final isUpdated = emailIdsUpdated.every(ids.contains);

    if (emailIdsUpdated.isEmpty || !isUpdated) {
      for (var id in emailIds) {
        throw parseErrorForSetResponse(response, id.id);
      }
    }
  }

  Future<void> removeLabelFromEmail(
    Session session,
    AccountId accountId,
    EmailId emailId,
    KeyWordIdentifier labelKeyword,
  ) async {
    final method = SetEmailMethod(accountId)
      ..addUpdates({
        emailId.id: labelKeyword.generateLabelActionPath(remove: true),
      });

    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final invocation = builder.invocation(method);

    final capabilities = method.requiredCapabilities
        .toCapabilitiesSupportTeamMailboxes(session, accountId);
    final result = await (builder..usings(capabilities)).build().execute();

    final response = result.parse<SetEmailResponse>(
      invocation.methodCallId,
      SetEmailResponse.deserialize,
    );

    final emailIdsUpdated = response?.updated?.keys ?? <Id>[];

    if (emailIdsUpdated.isEmpty || !emailIdsUpdated.contains(emailId.id)) {
      throw parseErrorForSetResponse(response, emailId.id);
    }
  }

  Future<void> removeLabelFromThread(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    KeyWordIdentifier labelKeyword,
  ) async {
    final method = SetEmailMethod(accountId)
      ..addUpdates(emailIds.generateMapUpdateObjectLabel(
        labelKeyword,
        remove: true,
      ));

    final builder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final invocation = builder.invocation(method);

    final capabilities = method.requiredCapabilities
        .toCapabilitiesSupportTeamMailboxes(session, accountId);
    final result = await (builder..usings(capabilities)).build().execute();

    final response = result.parse<SetEmailResponse>(
      invocation.methodCallId,
      SetEmailResponse.deserialize,
    );

    final emailIdsUpdated = response?.updated?.keys ?? <Id>[];
    final ids = emailIds.map((emailId) => emailId.id);
    final isUpdated = emailIdsUpdated.every(ids.contains);

    if (emailIdsUpdated.isEmpty || !isUpdated) {
      for (var id in emailIds) {
        throw parseErrorForSetResponse(response, id.id);
      }
    }
  }
}