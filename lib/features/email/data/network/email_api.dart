import 'dart:async';
import 'dart:io';
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
import 'package:external_path/external_path.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:jmap_dart_client/http/http_client.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/capability/core_capability.dart';
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
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';
import 'package:model/extensions/list_email_id_extension.dart';
import 'package:model/extensions/mailbox_id_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tmail_ui_user/features/base/mixin/handle_error_mixin.dart';
import 'package:tmail_ui_user/features/composer/domain/exceptions/set_method_exception.dart';
import 'package:tmail_ui_user/features/composer/domain/model/email_request.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/email/domain/model/event_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_action.dart';
import 'package:tmail_ui_user/features/email/domain/model/move_to_mailbox_request.dart';
import 'package:tmail_ui_user/features/email/domain/model/restore_deleted_message_request.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/create_new_mailbox_request.dart';
import 'package:tmail_ui_user/features/thread/domain/constants/thread_constants.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:uuid/uuid.dart';

class EmailAPI with HandleSetErrorMixin {

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

  Future<List<EmailId>> markAsRead(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    ReadActions readActions,
  ) async {
    final setEmailMethod = SetEmailMethod(accountId)
      ..addUpdates(emailIds.generateMapUpdateObjectMarkAsRead(readActions));

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

    final emailIdUpdated = setEmailResponse?.updated
      ?.keys
      .map((id) => EmailId(id))
      .toList() ?? [];
    final mapErrors = handleSetResponse([setEmailResponse]);

    if (emailIdUpdated.isNotEmpty) {
      return emailIdUpdated;
    } else {
      throw SetMethodException(mapErrors);
    }
  }

  Future<List<DownloadTaskId>> downloadAttachments(
      List<Attachment> attachments,
      AccountId accountId,
      String baseDownloadUrl,
      AccountRequest accountRequest
  ) async {
    if (accountRequest.authenticationType == AuthenticationType.oidc &&
        accountRequest.token?.isExpired == true &&
        accountRequest.token?.refreshToken.isNotEmpty == true) {
      throw DownloadAttachmentHasTokenExpiredException(accountRequest.token!.refreshToken);
    }

    String externalStorageDirPath;
    if (Platform.isAndroid) {
      externalStorageDirPath = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    } else {
      throw DeviceNotSupportedException();
    }

    final authentication = accountRequest.authenticationType == AuthenticationType.oidc
        ? accountRequest.bearerToken
        : accountRequest.basicAuth;

    final taskIds = await Future.wait(
      attachments.map((attachment) async => await FlutterDownloader.enqueue(
        url: attachment.getDownloadUrl(baseDownloadUrl, accountId),
        savedDir: externalStorageDirPath,
        headers: {
          HttpHeaders.authorizationHeader: authentication,
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
      AccountRequest accountRequest,
      StreamController<Either<Failure, Success>> onReceiveController,
      {CancelToken? cancelToken}
  ) async {
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
          onReceiveController.add(Right(DownloadingAttachmentForWeb(
              taskId,
              attachment,
              progress,
              downloaded,
              total)));
        }
    );

    return bytesDownloaded;
  }

  Future<List<EmailId>> moveToMailbox(
    Session session,
    AccountId accountId,
    MoveToMailboxRequest moveRequest
  ) async {
    final coreCapability = session.getCapabilityProperties<CoreCapability>(
      accountId,
      CapabilityIdentifier.jmapCore
    );
    int maxMethodCount = coreCapability?.maxCallsInRequest?.value.toInt() ?? CapabilityIdentifierExtension.defaultMaxCallsInRequest;
    log('EmailAPI::moveToMailbox:maxMethodCount: $maxMethodCount');
    int start = 0;
    int end = 0;

    final List<EmailId> listEmailIdResult = List.empty(growable: true);
    final listCurrentMailboxesEntries = moveRequest.currentMailboxes.entries.toList();

    while (end < moveRequest.currentMailboxes.length) {
      start = end;
      if (moveRequest.currentMailboxes.length - start >= maxMethodCount) {
        end = maxMethodCount;
      } else {
        end = moveRequest.currentMailboxes.length;
      }
      log('EmailAPI::moveToMailbox(): move from $start to $end / ${listCurrentMailboxesEntries.length}');
      final currentExecuteList = listCurrentMailboxesEntries.sublist(start, end);

      final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
      final currentSetEmailInvocations = currentExecuteList.map((currentItem) {

        final moveProperties = (moveRequest.moveAction == MoveAction.moving && moveRequest.emailActionType == EmailActionType.moveToSpam)
            ? currentItem.value.generateMapUpdateObjectMoveToSpam(currentItem.key, moveRequest.destinationMailboxId)
            : currentItem.value.generateMapUpdateObjectMoveToMailbox(currentItem.key, moveRequest.destinationMailboxId);

        return SetEmailMethod(accountId)
          ..addUpdates(moveProperties);
      }).map(requestBuilder.invocation).toList();

      final capabilities = {CapabilityIdentifier.jmapCore, CapabilityIdentifier.jmapMail}
        .toCapabilitiesSupportTeamMailboxes(session, accountId);

      final response = await (requestBuilder..usings(capabilities))
        .build()
        .execute();

      Future.sync(() async {
        final listSetEmailResponse = currentSetEmailInvocations
          .map((currentInvocation) => response.parse(currentInvocation.methodCallId, SetEmailResponse.deserialize))
          .toList();

        listEmailIdResult.addAll(_getListEmailIdUpdatedFormSetEmailResponse(listSetEmailResponse, moveRequest));

      }).catchError((error) {
        throw error;
      });
    }

    return listEmailIdResult;
  }

  List<EmailId> _getListEmailIdUpdatedFormSetEmailResponse(List<SetEmailResponse?> listSetEmailResponse, MoveToMailboxRequest moveRequest) {
    final listUpdated = listSetEmailResponse.map((e) => e!.updated!.keys).toList();
    List<EmailId> listEmailIdRequest = moveRequest.currentMailboxes.values.expand((e) => e).toList();
    return listEmailIdRequest.where((emailId) => listUpdated.expand((e) => e).toList().contains(emailId.id)).toList();
  }

  Future<List<EmailId>> markAsStar(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds,
    MarkStarAction markStarAction
  ) async {
    final setEmailMethod = SetEmailMethod(accountId)
      ..addUpdates(emailIds.generateMapUpdateObjectMarkAsStar(markStarAction));

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

    final emailIdUpdated = setEmailResponse?.updated
        ?.keys
        .map((id) => EmailId(id))
        .toList() ?? [];
    final mapErrors = handleSetResponse([setEmailResponse]);

    if (emailIdUpdated.isNotEmpty) {
      return emailIdUpdated;
    } else {
      throw SetMethodException(mapErrors);
    }
  }

  Future<Email> saveEmailAsDrafts(
    Session session,
    AccountId accountId,
    Email email,
    {CancelToken? cancelToken}
  ) async {
    final idCreateMethod = Id(_uuid.v1());
    final setEmailMethod = SetEmailMethod(accountId)
      ..addCreate(idCreateMethod, email);

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

  Future<bool> removeEmailDrafts(
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

  Future<List<EmailId>> deleteMultipleEmailsPermanently(
    Session session,
    AccountId accountId,
    List<EmailId> emailIds
  ) async {
    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    final setEmailMethod = SetEmailMethod(accountId)
      ..addDestroy(emailIds.map((emailId) => emailId.id).toSet());

    final setEmailInvocation = requestBuilder.invocation(setEmailMethod);

    final capabilities = setEmailMethod.requiredCapabilities
      .toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
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
        SetEmailResponse.deserialize);

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

  Future<Email> unsubscribeMail(Session session, AccountId accountId, EmailId emailId) async {
    final setEmailMethod = SetEmailMethod(accountId)
      ..addUpdates(emailId.generateMapUpdateObjectUnsubscribeMail());

    final getEmailMethod = GetEmailMethod(accountId)
      ..addIds({emailId.id})
      ..addProperties(ThreadConstants.propertiesDefault);

    final requestBuilder = JmapRequestBuilder(_httpClient, ProcessingInvocation());
    requestBuilder.invocation(setEmailMethod);
    final getEmailInvocation = requestBuilder.invocation(getEmailMethod);

    final capabilities = setEmailMethod.requiredCapabilities.toCapabilitiesSupportTeamMailboxes(session, accountId);

    final response = await (requestBuilder
        ..usings(capabilities))
      .build()
      .execute();

    final getEmailResponse = response.parse<GetEmailResponse>(
      getEmailInvocation.methodCallId,
      GetEmailResponse.deserialize);

    if (getEmailResponse?.list.isNotEmpty == true) {
      return getEmailResponse!.list.first;
    } else {
      throw NotFoundEmailException();
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

  Future<void> storeEventAttendanceStatus(
    Session session,
    AccountId accountId,
    EmailId emailId,
    EventActionType eventActionType
  ) async {
    final setEmailMethod = SetEmailMethod(accountId)
      ..addUpdates(emailId.generateMapUpdateObjectEventAttendanceStatus(eventActionType));

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

    final emailIdUpdated = setEmailResponse?.updated
        ?.keys
        .map((id) => EmailId(id))
        .toList() ?? [];
    final mapErrors = handleSetResponse([setEmailResponse]);

    if (emailIdUpdated.isEmpty) {
      throw SetMethodException(mapErrors);
    }
  }
}