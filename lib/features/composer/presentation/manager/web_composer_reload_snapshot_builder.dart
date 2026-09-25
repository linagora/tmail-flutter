import 'package:collection/collection.dart';
import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_body_part.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/auto_create_tag_for_recipients_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/create_email_request_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/extensions/get_draft_mailbox_id_for_composer_extension.dart';
import 'package:tmail_ui_user/features/composer/presentation/manager/web_composer_reload_cache_handler.dart';
import 'package:tmail_ui_user/features/composer/presentation/model/create_email_request.dart';
import 'package:tmail_ui_user/features/email/domain/exceptions/email_exceptions.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/inline_image_cid_extension.dart';
import 'package:tmail_ui_user/features/email/domain/extensions/list_attachments_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:uuid/uuid.dart';

typedef _ComposerReloadSource = ({
  ComposerArguments arguments,
  Session session,
  AccountId accountId,
  String content,
  String composerId,
});

class WebComposerReloadSnapshotBuilder {
  final ComposerController _controller;

  WebComposerReloadSnapshotBuilder(this._controller);

  ComposerReloadSnapshot? build() {
    final source = _readSource();
    if (source == null) return null;

    _controller.autoCreateEmailTag();
    final request = _createRequest(source);
    if (source.arguments.selectedIdentityId != null &&
        request.identity == null) {
      return null;
    }

    return (
      accountId: source.accountId,
      session: source.session,
      cache: request.generateComposerCache(
        emailCreated: _createReloadEmail(request),
      ),
    );
  }

  _ComposerReloadSource? _readSource() {
    if (_controller.isClosed) return null;
    final composerId = _controller.composerId;
    if (composerId == null) return null;

    final arguments = _controller.composerArguments.value;
    final session = _controller.mailboxDashBoardController.sessionCurrent;
    final accountId = _controller.mailboxDashBoardController.accountId.value;
    final content = _controller.textEditorWeb;

    if (arguments == null) return null;
    if (session == null) return null;
    if (accountId == null) return null;
    if (content == null) return null;
    if (_hasFailedToRestoreContent) return null;

    return (
      arguments: arguments,
      session: session,
      accountId: accountId,
      content: content,
      composerId: composerId,
    );
  }

  // This Email is only a reload snapshot, never sent.
  Email _createReloadEmail(CreateEmailRequest request) {
    // Uploaded inline images must be cid-referenced; otherwise restore
    // classifies them as orphans and lists them as regular attachments.
    final (content, inlineImages) = _controller.uploadController
        .mapInlineAttachments
        .replaceUploadedImagesWithCid(request.emailContent);
    return request.generateEmail(
      newEmailContent: content,
      newEmailAttachments: {
        ...request.createAttachments(),
        ...inlineImages.toList().toEmailBodyPart(charset: Constant.base64Charset),
      }.onlyUseBlobIdOrPartId(),
      userAgent: '',
      partId: PartId(const Uuid().v4()),
      withIdentityHeader: true,
      isDraft: true,
    );
  }

  bool get _hasFailedToRestoreContent {
    if (_controller.currentEmailActionType !=
        EmailActionType.reopenComposerBrowser) {
      return false;
    }
    return _controller.emailContentsViewState.value?.fold(
          (failure) =>
              failure is GetEmailContentFailure &&
              failure.exception is! EmptyEmailContentException,
          (_) => false,
        ) ??
        false;
  }

  CreateEmailRequest _createRequest(_ComposerReloadSource source) {
    final arguments = source.arguments;
    // A restored composer keeps the action it was first opened with.
    final originalAction =
        _controller.savedActionType ??
        _controller.currentEmailActionType ??
        arguments.emailActionType;
    return CreateEmailRequest(
      session: source.session,
      accountId: source.accountId,
      emailActionType: originalAction,
      ownEmailAddress: _controller.ownEmailAddress,
      subject: _controller.subjectEmail.value ?? '',
      emailContent: source.content.removeEditorStartTag(),
      fromSender: arguments.presentationEmail?.from,
      toRecipients: _controller.listToEmailAddress.toSet(),
      ccRecipients: _controller.listCcEmailAddress.toSet(),
      bccRecipients: _controller.listBccEmailAddress.toSet(),
      replyToRecipients: _controller.listReplyToEmailAddress.toSet(),
      hasRequestReadReceipt: _controller.hasRequestReadReceipt.value,
      isMarkAsImportant: _controller.isMarkAsImportant.value,
      identity: _resolveIdentity(arguments),
      attachments: _controller.uploadController.attachmentsUploaded,
      draftsMailboxId: _controller.getDraftMailboxIdForComposer(),
      draftsEmailId: _controller.getDraftEmailId(),
      messageId: arguments.messageId,
      references: arguments.references,
      displayMode: _controller.screenDisplayMode.value,
      composerIndex: _controller.mailboxDashBoardController.composerManager
          .getComposerIndex(source.composerId),
      composerId: source.composerId,
      savedDraftHash:
          _controller.savedEmailDraftHash ?? arguments.savedDraftHash,
      savedActionType: originalAction,
      templateEmailId: _controller.currentTemplateEmailId,
    );
  }

  Identity? _resolveIdentity(ComposerArguments arguments) {
    final selected = _controller.identitySelected.value;
    if (selected != null) return selected;

    final availableIdentities = _controller.listFromIdentities.isNotEmpty
        ? _controller.listFromIdentities
        : arguments.identities ?? const <Identity>[];
    final selectedId = arguments.selectedIdentityId;
    if (selectedId != null) {
      return availableIdentities.firstWhereOrNull(
        (identity) => identity.id == selectedId,
      );
    }

    // The default identity may not have been applied to the editor yet.
    return availableIdentities.firstOrNull;
  }
}
