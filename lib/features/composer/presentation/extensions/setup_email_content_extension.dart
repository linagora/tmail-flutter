
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/email/attachment.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/list_attachment_extension.dart';
import 'package:model/extensions/list_email_content_extension.dart';
import 'package:tmail_ui_user/features/composer/domain/state/restore_email_inline_images_state.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_email_request_read_receipt_flag_for_edit_draft_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/setup_selected_identity_extension.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/transform_html_email_content_state.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/download/domain/exceptions/download_attachment_exceptions.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/main/exceptions/logic_exception.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension SetupEmailContentExtension on ComposerController {

  Future<void> setupEmailContent(ComposerArguments arguments) async {
    if (_isEditDraftContentAction) {
      await _getEmailContent(
        arguments,
        transformConfiguration: TransformConfiguration.forEditDraftsEmail(),
        additionalProperties: Properties({IndividualHeaderIdentifier.identityHeader.value}),
      );
    } else if (currentEmailActionType == EmailActionType.editSendingEmail) {
      _loadSendingEmailContent(arguments);
    } else if (currentEmailActionType == EmailActionType.composeFromContentShared) {
      _loadSimpleEmailContent(arguments.emailContents ?? '');
    } else if (_isMailtoContentAction) {
      _loadSimpleEmailContent(arguments.body ?? '');
    } else if (_isReplyForwardContentAction) {
      await _loadReplyForwardEmailContent(arguments);
    } else if (currentEmailActionType == EmailActionType.reopenComposerBrowser) {
      await _loadReopenBrowserEmailContent(arguments);
    } else if (currentEmailActionType == EmailActionType.restoreComposerFromPersistentCache) {
      await _loadMobileRestoredEmailContent(arguments);
    } else {
      emailContentsViewState.value = Right(LoadEmailContentCompleted());
    }
  }

  bool get _isEditDraftContentAction => const {
    EmailActionType.editAsNewEmail,
    EmailActionType.editDraft,
  }.contains(currentEmailActionType);

  bool get _isMailtoContentAction => const {
    EmailActionType.composeFromMailtoUri,
    EmailActionType.composeFromUnsubscribeMailtoLink,
  }.contains(currentEmailActionType);

  bool get _isReplyForwardContentAction => const {
    EmailActionType.reply,
    EmailActionType.replyToList,
    EmailActionType.replyAll,
    EmailActionType.forward,
  }.contains(currentEmailActionType);

  void _loadSendingEmailContent(ComposerArguments arguments) {
    final sendingEmail = arguments.sendingEmail;
    final htmlContent = sendingEmail?.presentationEmail.emailContentList.asHtmlString ?? '';
    final successState = GetEmailContentSuccess(
      htmlEmailContent: htmlContent,
      emailCurrent: sendingEmail?.email,
    );
    if (PlatformInfo.isWeb) setTextEditorWeb(htmlContent);
    emailContentsViewState.value = Right(successState);
  }

  void _loadSimpleEmailContent(String content) {
    if (PlatformInfo.isWeb) setTextEditorWeb(content);
    emailContentsViewState.value = Right(GetEmailContentSuccess(htmlEmailContent: content));
  }

  Future<void> _loadReplyForwardEmailContent(ComposerArguments arguments) async {
    if (arguments.emailContents?.trim().isEmpty ?? true) {
      await _getEmailContent(
        arguments,
        transformConfiguration: TransformConfiguration.forReplyForwardEmptyEmail(),
      );
      return;
    }

    final resultState = await transformHtmlEmailContentInteractor.execute(
      arguments.emailContents ?? '',
      TransformConfiguration.forReplyForwardEmail(),
    ).last;

    final uiState = resultState.fold((f) => f, (s) => s);

    if (uiState is TransformHtmlEmailContentSuccess) {
      _applyTransformedReplyContent(uiState.htmlContent, arguments);
    } else if (uiState is TransformHtmlEmailContentFailure) {
      _setEmailContentFailure(GetEmailContentFailure(uiState.exception));
    } else {
      emailContentsViewState.value = Right(LoadEmailContentCompleted());
    }
  }

  void _applyTransformedReplyContent(String emailContent, ComposerArguments arguments) {
    _applyWebQuotingIfNeeded(emailContent, arguments);
    emailContentsViewState.value = Right(GetEmailContentSuccess(htmlEmailContent: emailContent));
  }

  void _applyWebQuotingIfNeeded(String emailContent, ComposerArguments arguments) {
    if (!PlatformInfo.isWeb) return;
    bool cannotApplyQuoting = currentContext == null ||
        arguments.presentationEmail == null ||
        currentEmailActionType == null;
    if (cannotApplyQuoting) {
      return;
    }
    final emailContentQuoted = getEmailContentQuotedAsHtml(
      locale: Localizations.localeOf(currentContext!),
      appLocalizations: AppLocalizations.of(currentContext!),
      emailContent: emailContent,
      emailActionType: currentEmailActionType!,
      presentationEmail: arguments.presentationEmail!,
    );
    setTextEditorWeb(emailContentQuoted);
  }

  Future<void> _loadReopenBrowserEmailContent(ComposerArguments arguments) async {
    final content = arguments.emailContents ?? '';
    final inlineImages = arguments.inlineImages ?? [];
    final displayMode = arguments.displayMode;

    if (content.trim().isEmpty) {
      emailContentsViewState.value = Left(GetEmailContentFailure(EmptyEmailContentException()));
      return;
    }

    final canSkipInlineRestoration = displayMode.isNotContentVisible() && inlineImages.isEmpty;
    if (canSkipInlineRestoration) {
      setTextEditorWeb(content);
      emailContentsViewState.value = Right(GetEmailContentSuccess(htmlEmailContent: content));
      return;
    }

    await _restoreInlineImages(content, inlineImages);
  }

  Future<void> _restoreInlineImages(String content, List<Attachment> inlineImages) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final downloadUrl = mailboxDashBoardController.baseDownloadUrl;

    if (restoreEmailInlineImagesInteractor == null) {
      emailContentsViewState.value = Left(GetEmailContentFailure(const InteractorNotInitialized()));
      return;
    }

    if (accountId == null) {
      emailContentsViewState.value = Left(GetEmailContentFailure(NotFoundAccountIdException()));
      return;
    }

    if (downloadUrl.isEmpty) {
      emailContentsViewState.value = Left(GetEmailContentFailure(DownloadUrlIsNullException()));
      return;
    }

    final resultState = await restoreEmailInlineImagesInteractor!.execute(
      htmlContent: content,
      transformConfiguration: TransformConfiguration.forRestoreEmail(),
      mapUrlDownloadCID: inlineImages.toMapCidImageDownloadUrl(
        accountId: accountId,
        downloadUrl: downloadUrl,
      ),
    ).last;

    final uiState = resultState.fold((f) => f, (s) => s);

    if (uiState is RestoreEmailInlineImagesSuccess) {
      setTextEditorWeb(uiState.emailContent);
      emailContentsViewState.value = Right(GetEmailContentSuccess(htmlEmailContent: uiState.emailContent));
    } else if (uiState is RestoreEmailInlineImagesFailure) {
      _setEmailContentFailure(GetEmailContentFailure(uiState.exception));
    } else {
      emailContentsViewState.value = Right(LoadEmailContentCompleted());
    }
  }

  void _setEmailContentFailure(GetEmailContentFailure failure) {
    emailContentsViewState.value = Left(failure);
    consumeState(Stream.value(Left(failure)));
  }

  Future<void> _loadMobileRestoredEmailContent(ComposerArguments arguments) async {
    final content = arguments.emailContents ?? '';
    final inlineImages = arguments.inlineImages ?? [];

    if (content.trim().isEmpty) {
      emailContentsViewState.value = Left(GetEmailContentFailure(EmptyEmailContentException()));
      return;
    }

    if (inlineImages.isEmpty) {
      emailContentsViewState.value = Right(GetEmailContentSuccess(htmlEmailContent: content));
      return;
    }

    await _restoreInlineImages(content, inlineImages);
  }

  Future<void> _getEmailContent(
    ComposerArguments arguments, {
    required TransformConfiguration transformConfiguration,
    Properties? additionalProperties,
  }) async {
    final session = mailboxDashBoardController.sessionCurrent;
    final accountId = mailboxDashBoardController.accountId.value;
    final emailId = arguments.presentationEmail?.id;

    if (session == null) {
      emailContentsViewState.value = Left(GetEmailContentFailure(NotFoundSessionException()));
      return;
    }

    if (accountId == null) {
      emailContentsViewState.value = Left(GetEmailContentFailure(NotFoundAccountIdException()));
      return;
    }

    if (emailId == null) {
      emailContentsViewState.value = Left(GetEmailContentFailure(NotFoundEmailException()));
      return;
    }

    final resultState = await getEmailContentInteractor.execute(
      session,
      accountId,
      emailId,
      mailboxDashBoardController.baseDownloadUrl,
      transformConfiguration,
      additionalProperties: additionalProperties,
    ).last;

    final uiState = resultState.fold((f) => f, (s) => s);

    if (uiState is GetEmailContentSuccess) {
      _setupEmailContentState(
        attachments: uiState.attachments,
        inlineImages: uiState.inlineImages,
        hasRequestReadReceipt: uiState.emailCurrent?.hasRequestReadReceipt,
        identityIdFromHeader: uiState.emailCurrent?.identityIdFromHeader,
      );
      emailContentsViewState.value = Right(uiState);
    } else if (uiState is GetEmailContentFromCacheSuccess) {
      _setupEmailContentState(
        attachments: uiState.attachments,
        inlineImages: uiState.inlineImages,
        hasRequestReadReceipt: uiState.emailCurrent.hasRequestReadReceipt,
        identityIdFromHeader: uiState.emailCurrent.identityIdFromHeader,
      );
      emailContentsViewState.value = Right(uiState);
    } else if (uiState is GetEmailContentFailure) {
      _setEmailContentFailure(uiState);
    } else {
      emailContentsViewState.value = Right(LoadEmailContentCompleted());
    }
  }

  void _setupEmailContentState({
    required List<Attachment>? attachments,
    required List<Attachment>? inlineImages,
    bool? hasRequestReadReceipt,
    IdentityId? identityIdFromHeader,
  }) {
    initAttachmentsAndInlineImages(
      attachments: attachments,
      inlineImages: inlineImages,
    );
    if (_isEditDraftContentAction) {
      if (hasRequestReadReceipt != null) {
        setupEmailRequestReadReceiptFlag(hasRequestReadReceipt);
      }
      setupSelectedIdentityForEditDraft(identityIdFromHeader);
    }
  }
}
