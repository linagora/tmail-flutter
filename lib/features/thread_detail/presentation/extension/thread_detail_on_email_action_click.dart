import 'dart:async';

import 'package:core/presentation/utils/html_transformer/transform_configuration.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/email/mark_star_action.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/email/read_actions.dart';
import 'package:model/extensions/email_extension.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/open_and_close_composer_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension ThreadDetailOnEmailActionClick on ThreadDetailController {
  void threadDetailOnEmailActionClick(
    PresentationEmail presentationEmail,
    EmailActionType emailActionType,
  ) {
    switch(emailActionType) {
      case EmailActionType.markAsRead:
        _markRead(presentationEmail);
        break;
      case EmailActionType.markAsUnread:
        _unRead(presentationEmail);
        break;
      case EmailActionType.markAsStarred:
        _markStar(presentationEmail, MarkStarAction.markStar);
        break;
      case EmailActionType.unMarkAsStarred:
        _markStar(presentationEmail, MarkStarAction.unMarkStar);
        break;
      case EmailActionType.moveToMailbox:
        _moveEmail(presentationEmail);
        break;
      case EmailActionType.moveToTrash:
        _trashEmail(presentationEmail);
        break;
      case EmailActionType.deletePermanently:
        _deleteEmailPermanently(presentationEmail);
        break;
      case EmailActionType.moveToSpam:
        _markEmailSpam(presentationEmail);
        break;
      case EmailActionType.unSpam:
        _unSpamEmail(presentationEmail);
        break;
      case EmailActionType.createRule:
        _quickCreateRule(presentationEmail);
        break;
      case EmailActionType.unsubscribe:
        _unsubscribeEmail(presentationEmail);
        break;
      case EmailActionType.archiveMessage:
        _archiveMessage(presentationEmail);
        break;
      case EmailActionType.printAll:
        _printEmail(presentationEmail);
        break;
      case EmailActionType.downloadMessageAsEML:
        _downloadMessageAsEML(presentationEmail);
        break;
      case EmailActionType.editAsNewEmail:
        _editAsNewEmail(presentationEmail);
        break;
      case EmailActionType.reply:
        _replyEmail(presentationEmail);
        break;
      case EmailActionType.replyAll:
        _replyAll(presentationEmail);
        break;
      case EmailActionType.replyToList:
        _replyToList(presentationEmail);
        break;
      case EmailActionType.forward:
        _forward(presentationEmail);
        break;
      default:
        break;
    }
  }

  void _markRead(PresentationEmail presentationEmail) {
    if (session == null || accountId == null || presentationEmail.hasRead) return;

    consumeState(emailActionReactor.markAsEmailRead(
      session!,
      accountId!,
      presentationEmail,
      readAction: ReadActions.markAsRead,
    ));
  }

  void _unRead(PresentationEmail presentationEmail) {
    if (session == null || accountId == null || !presentationEmail.hasRead) return;

    consumeState(emailActionReactor.markAsEmailRead(
      session!,
      accountId!,
      presentationEmail,
      readAction: ReadActions.markAsUnread,
    ));
  }

  void _markStar(
    PresentationEmail presentationEmail,
    MarkStarAction markStarAction,
  ) {
    if (session == null ||
        accountId == null ||
        (presentationEmail.hasStarred && markStarAction == MarkStarAction.markStar) ||
        (!presentationEmail.hasStarred && markStarAction == MarkStarAction.unMarkStar)) return;

    consumeState(emailActionReactor.markAsStarEmail(
      session!,
      accountId!,
      presentationEmail,
      markStarAction: markStarAction,
    ));
  }

  Future<void> _moveEmail(PresentationEmail presentationEmail) async {
    if (session == null || accountId == null) return;

    final moveActionRequest = await emailActionReactor.moveToMailbox(
      session!,
      accountId!,
      presentationEmail,
      mapMailbox: mailboxDashBoardController.mapMailboxById,
      selectedMailbox: mailboxDashBoardController.selectedMailbox.value,
      isSearchEmailRunning: mailboxDashBoardController.searchController.isSearchEmailRunning,
    );

    if (moveActionRequest == null) return;

    mailboxDashBoardController.moveToMailbox(
      session!,
      accountId!,
      moveActionRequest.moveRequest,
      moveActionRequest.emailIdsWithReadStatus,
    );
  }

  void _trashEmail(PresentationEmail presentationEmail) {
    if (session == null || accountId == null) return;

    final moveActionRequest = emailActionReactor.moveToTrash(
      presentationEmail,
      mapMailbox: mailboxDashBoardController.mapMailboxById,
      selectedMailbox: mailboxDashBoardController.selectedMailbox.value,
      isSearchEmailRunning: mailboxDashBoardController.searchController.isSearchEmailRunning,
      mapDefaultMailboxIdByRole: mailboxDashBoardController.mapDefaultMailboxIdByRole,
    );
    if (moveActionRequest == null) return;
    mailboxDashBoardController.moveToMailbox(
      session!,
      accountId!,
      moveActionRequest.moveRequest,
      moveActionRequest.emailIdsWithReadStatus,
    );
  }

  void _markEmailSpam(PresentationEmail presentationEmail) {
    if (session == null || accountId == null) return;

    final moveActionRequest = emailActionReactor.moveToSpam(
      presentationEmail,
      mapMailbox: mailboxDashBoardController.mapMailboxById,
      selectedMailbox: mailboxDashBoardController.selectedMailbox.value,
      isSearchEmailRunning: mailboxDashBoardController.searchController.isSearchEmailRunning,
      mapDefaultMailboxIdByRole: mailboxDashBoardController.mapDefaultMailboxIdByRole,
    );
    if (moveActionRequest == null) return;
    mailboxDashBoardController.moveToMailbox(
      session!,
      accountId!,
      moveActionRequest.moveRequest,
      moveActionRequest.emailIdsWithReadStatus,
    );
  }

  void _unSpamEmail(PresentationEmail presentationEmail) {
    if (session == null || accountId == null) return;

    final moveActionRequest = emailActionReactor.unSpam(
      presentationEmail,
      mapMailbox: mailboxDashBoardController.mapMailboxById,
      selectedMailbox: mailboxDashBoardController.selectedMailbox.value,
      isSearchEmailRunning: mailboxDashBoardController.searchController.isSearchEmailRunning,
      mapDefaultMailboxIdByRole: mailboxDashBoardController.mapDefaultMailboxIdByRole,
    );
    if (moveActionRequest == null) return;
    mailboxDashBoardController.moveToMailbox(
      session!,
      accountId!,
      moveActionRequest.moveRequest,
      moveActionRequest.emailIdsWithReadStatus,
    );
  }

  void _deleteEmailPermanently(PresentationEmail email) {
    emailActionReactor.deleteEmailPermanently(
      email,
      onDeleteEmailRequest: (email) {
        popBack();
        mailboxDashBoardController.deleteEmailPermanently(email);
      },
      responsiveUtils: responsiveUtils,
      imagePaths: imagePaths,
    );
  }

  void _quickCreateRule(PresentationEmail presentationEmail) {
    final emailAddress = presentationEmail.from?.first;
    if (session == null || accountId == null || emailAddress == null) return;
    
    consumeState(emailActionReactor.quickCreateRule(
      session!,
      accountId!,
      emailAddress: emailAddress,
    ));
  }
  
  void _unsubscribeEmail(PresentationEmail presentationEmail) {
    emailActionReactor.unsubscribeEmail(
      presentationEmail,
      emailUnsubscribe: EmailUtils.parsingUnsubscribe(
        presentationEmail.listUnsubscribe ?? '',
      ),
      onUnsubscribeByHttpsLink: mailboxDashBoardController.unsubscribeMail,
      onUnsubscribeByMailtoLink: (emailId, navigationRouter) {
        mailboxDashBoardController.openComposer(
          ComposerArguments.fromUnsubscribeMailtoLink(
            listEmailAddress: navigationRouter.listEmailAddress,
            subject: navigationRouter.subject,
            body: navigationRouter.body,
            previousEmailId: emailId,
          )
        );
      },
    );
  }
  
  void _archiveMessage(PresentationEmail presentationEmail) {
    if (currentContext == null) return;

    emailActionReactor.archiveMessage(
      presentationEmail,
      onArchiveEmailRequest: (presentationEmail) {
        mailboxDashBoardController.archiveMessage(currentContext!, presentationEmail);
      },
    );
  }
  
  void _printEmail(PresentationEmail presentationEmail) {
    consumeState(emailActionReactor.printEmail(
      presentationEmail,
      ownEmailAddress: mailboxDashBoardController.getOwnEmailAddress(),
      emailLoaded: null,
      session: session,
      accountId: accountId,
      baseDownloadUrl: session?.getDownloadUrl(jmapUrl: dynamicUrlInterceptors.jmapUrl),
      transformConfiguration: TransformConfiguration.forPreviewEmailOnWeb(),
      onGetEmailContentFailure: _showUnknownErrorToast,
    ));
  }
  
  void _downloadMessageAsEML(PresentationEmail presentationEmail) {
    if (accountId == null || session == null) return;

    consumeState(emailActionReactor.downloadMessageAsEML(
      session!,
      accountId!,
      presentationEmail,
      downloadProgressStateController: downloadProgressState,
    ));
  }
  
  void _editAsNewEmail(PresentationEmail presentationEmail) {
    if (accountId == null || session == null) return;

    emailActionReactor.editAsNewEmail(
      presentationEmail,
      onEditAsEmailRequest: (presentationEmail) {
        mailboxDashBoardController.openComposer(
          ComposerArguments.editAsNewEmail(presentationEmail),
        );
      },
    );
  }

  void _replyEmail(PresentationEmail presentationEmail) {
    emailActionReactor.replyEmail(
      presentationEmail,
      onReplyEmailRequest: (presentationEmail, emailLoaded) {
        mailboxDashBoardController.openComposer(
          ComposerArguments.replyEmail(
            presentationEmail: presentationEmail,
            content: emailLoaded?.htmlContent,
            inlineImages: emailLoaded?.inlineImages,
            mailboxRole: presentationEmail.mailboxContain?.role,
            messageId: emailLoaded?.emailCurrent?.messageId,
            references: emailLoaded?.emailCurrent?.references,
            listPost: emailLoaded?.emailCurrent?.listPost,
          )
        );
      },
      emailLoaded: null,
    );
  }

  void _replyAll(PresentationEmail presentationEmail) {
    emailActionReactor.replyAll(
      presentationEmail,
      onReplyAllRequest: (presentationEmail, emailLoaded) {
        mailboxDashBoardController.openComposer(
          ComposerArguments.replyAllEmail(
            presentationEmail: presentationEmail,
            content: emailLoaded?.htmlContent,
            inlineImages: emailLoaded?.inlineImages,
            mailboxRole: presentationEmail.mailboxContain?.role,
            messageId: emailLoaded?.emailCurrent?.messageId,
            references: emailLoaded?.emailCurrent?.references,
            listPost: emailLoaded?.emailCurrent?.listPost,
          )
        );
      },
      emailLoaded: null,
    );
  }
  void _replyToList(PresentationEmail presentationEmail) {
    emailActionReactor.replyToList(
      presentationEmail,
      onReplyToListRequest: (presentationEmail, emailLoaded) {
        mailboxDashBoardController.openComposer(
          ComposerArguments.replyToListEmail(
            presentationEmail: presentationEmail,
            content: emailLoaded?.htmlContent,
            inlineImages: emailLoaded?.inlineImages,
            mailboxRole: presentationEmail.mailboxContain?.role,
            messageId: emailLoaded?.emailCurrent?.messageId,
            references: emailLoaded?.emailCurrent?.references,
            listPost: emailLoaded?.emailCurrent?.listPost,
          )
        );
      },
      emailLoaded: null,
    );
  }
  void _forward(PresentationEmail presentationEmail) {
    emailActionReactor.forward(
      presentationEmail,
      onForwardRequest: (presentationEmail, emailLoaded) {
        mailboxDashBoardController.openComposer(
          ComposerArguments.forwardEmail(
            presentationEmail: presentationEmail,
            content: emailLoaded?.htmlContent,
            attachments: emailLoaded?.attachments,
            inlineImages: emailLoaded?.inlineImages,
            messageId: emailLoaded?.emailCurrent?.messageId,
            references: emailLoaded?.emailCurrent?.references,
          )
        );
      },
      emailLoaded: null,
    );
  }

  _showUnknownErrorToast() {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastErrorMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).unknownError,
      );
    }
  }
}