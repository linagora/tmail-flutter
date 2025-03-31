
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
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
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension SetupEmailContentExtension on ComposerController {

  Future<void> setupEmailContent(ComposerArguments arguments) async {
    switch(currentEmailActionType) {
      case EmailActionType.editAsNewEmail:
      case EmailActionType.editDraft:
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
          TransformConfiguration.forEditDraftsEmail(),
          additionalProperties: Properties({
            IndividualHeaderIdentifier.identityHeader.value,
          }),
        ).last;

        final uiState = resultState.fold((failure) => failure, (success) => success);

        if (uiState is GetEmailContentSuccess) {
          initAttachmentsAndInlineImages(
            attachments: uiState.attachments,
            inlineImages: uiState.inlineImages,
          );

          if (currentEmailActionType == EmailActionType.editDraft) {
            setupEmailRequestReadReceiptFlagForEditDraft(
              uiState.emailCurrent!.hasRequestReadReceipt,
            );
            setupSelectedIdentityForEditDraft(
              uiState.emailCurrent!.identityIdFromHeader,
            );
          }

          emailContentsViewState.value = Right(uiState);
        } else if (uiState is GetEmailContentFromCacheSuccess) {
          initAttachmentsAndInlineImages(
            attachments: uiState.attachments,
            inlineImages: uiState.inlineImages,
          );

          if (currentEmailActionType == EmailActionType.editDraft) {
            setupEmailRequestReadReceiptFlagForEditDraft(
              uiState.emailCurrent.hasRequestReadReceipt,
            );
          }

          emailContentsViewState.value = Right(uiState);
        } else if (uiState is GetEmailContentFailure) {
          emailContentsViewState.value = Left(uiState);
          consumeState(Stream.value(Left(uiState)));
        } else {
          emailContentsViewState.value = Right(UIState.idle);
        }
        break;
      case EmailActionType.editSendingEmail:
        final sendingEmail = arguments.sendingEmail;
        final successState = GetEmailContentSuccess(
          htmlEmailContent: sendingEmail?.presentationEmail.emailContentList.asHtmlString ?? '',
          emailCurrent: arguments.sendingEmail?.email,
        );
        if (PlatformInfo.isWeb) {
          setTextEditorWeb(successState.htmlEmailContent);
        }
        emailContentsViewState.value = Right(successState);
        break;
      case EmailActionType.composeFromContentShared:
        final successState = GetEmailContentSuccess(htmlEmailContent: arguments.emailContents ?? '');
        if (PlatformInfo.isWeb) {
          setTextEditorWeb(successState.htmlEmailContent);
        }
        emailContentsViewState.value = Right(successState);
        break;
      case EmailActionType.composeFromMailtoUri:
        final successState = GetEmailContentSuccess(htmlEmailContent: arguments.body ?? '');
        if (PlatformInfo.isWeb) {
          setTextEditorWeb(successState.htmlEmailContent);
        }
        emailContentsViewState.value = Right(successState);
        break;
      case EmailActionType.reply:
      case EmailActionType.replyToList:
      case EmailActionType.replyAll:
      case EmailActionType.forward:
        if (arguments.emailContents?.trim().isNotEmpty != true) {
          emailContentsViewState.value = Left(GetEmailContentFailure(EmptyEmailContentException()));
        } else {
          final resultState = await transformHtmlEmailContentInteractor.execute(
            arguments.emailContents ?? '',
            TransformConfiguration.forReplyForwardEmail(),
          ).last;

          final uiState = resultState.fold((failure) => failure, (success) => success);

          if (uiState is TransformHtmlEmailContentSuccess) {
            final emailContent = uiState.htmlContent;

            if (PlatformInfo.isWeb &&
                currentContext != null &&
                arguments.presentationEmail != null) {
              final emailContentQuoted = getEmailContentQuotedAsHtml(
                locale: Localizations.localeOf(currentContext!),
                appLocalizations: AppLocalizations.of(currentContext!),
                emailContent: emailContent,
                emailActionType: currentEmailActionType!,
                presentationEmail: arguments.presentationEmail!,
              );

              setTextEditorWeb(emailContentQuoted);
            }

            final successState = GetEmailContentSuccess(htmlEmailContent: emailContent);
            emailContentsViewState.value = Right(successState);
          } else if (uiState is TransformHtmlEmailContentFailure) {
            emailContentsViewState.value = Left(GetEmailContentFailure(uiState.exception));
            consumeState(Stream.value(Left(GetEmailContentFailure(uiState.exception))));
          } else {
            emailContentsViewState.value = Right(UIState.idle);
          }
        }
        break;
      case EmailActionType.reopenComposerBrowser:
        final inlineImages = arguments.inlineImages ?? [];
        final content = arguments.emailContents ?? '';
        final displayMode = arguments.displayMode;

        if (content.trim().isEmpty) {
          emailContentsViewState.value = Left(GetEmailContentFailure(EmptyEmailContentException()));
        } else if (displayMode.isNotContentVisible()) {
          final successState = GetEmailContentSuccess(htmlEmailContent: content);
          setTextEditorWeb(content);
          emailContentsViewState.value = Right(successState);
        } else {
          final accountId = mailboxDashBoardController.accountId.value;
          final downloadUrl = mailboxDashBoardController.baseDownloadUrl;

          if (restoreEmailInlineImagesInteractor == null ||
              accountId == null ||
              downloadUrl.isEmpty) {
            emailContentsViewState.value = Left(GetEmailContentFailure(NotFoundAccountIdException()));
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

          final uiState = resultState.fold((failure) => failure, (success) => success);

          if (uiState is RestoreEmailInlineImagesSuccess) {
            final emailContent = uiState.emailContent;
            final successState = GetEmailContentSuccess(htmlEmailContent: emailContent);
            setTextEditorWeb(emailContent);
            emailContentsViewState.value = Right(successState);
          } else if (uiState is RestoreEmailInlineImagesFailure) {
            emailContentsViewState.value = Left(GetEmailContentFailure(uiState.exception));
            consumeState(Stream.value(Left(GetEmailContentFailure(uiState.exception))));
          } else {
            emailContentsViewState.value = Right(UIState.idle);
          }
        }
        break;
      case EmailActionType.composeFromUnsubscribeMailtoLink:
        final successState = GetEmailContentSuccess(htmlEmailContent: arguments.body ?? '');
        if (PlatformInfo.isWeb) {
          setTextEditorWeb(successState.htmlEmailContent);
        }
        emailContentsViewState.value = Right(successState);
        break;
      default:
        emailContentsViewState.value = Right(UIState.idle);
        break;
    }
  }
}