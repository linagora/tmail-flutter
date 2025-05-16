import 'package:flutter/material.dart';
import 'dart:async';

import 'package:core/data/network/download/download_manager.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_property.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/domain/state/download_attachment_for_web_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_star_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/download_attachment_for_web_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_action_reactor/email_action_reactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/close_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_get_email_ids_by_thread_id_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_get_emails_by_ids_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/initialize_thread_detail_emails.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_collapsed_email_download_states.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/mark_collapsed_email_star_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/mark_collapsed_email_unread_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/quick_create_rule_from_collapsed_email_success.dart';

class ThreadDetailController extends BaseController {
  final GetThreadByIdInteractor _getEmailIdsByThreadIdInteractor;
  final GetEmailsByIdsInteractor getEmailsByIdsInteractor;
  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final CreateNewEmailRuleFilterInteractor _createNewEmailRuleFilterInteractor;
  final PrintEmailInteractor _printEmailInteractor;
  final GetEmailContentInteractor _getEmailContentInteractor;
  final DownloadAttachmentForWebInteractor _downloadAttachmentForWebInteractor;

  ThreadDetailController(
    this._getEmailIdsByThreadIdInteractor,
    this.getEmailsByIdsInteractor,
    this._markAsEmailReadInteractor,
    this._markAsStarEmailInteractor,
    this._createNewEmailRuleFilterInteractor,
    this._printEmailInteractor,
    this._getEmailContentInteractor,
    this._downloadAttachmentForWebInteractor,
  );

  final emailIdsPresentation = <EmailId, PresentationEmail?>{}.obs;
  final currentExpandedEmailId = Rxn<EmailId>();
  final currentEmailLoaded = Rxn<EmailLoaded>();

  late final EmailActionReactor emailActionReactor;
  final additionalProperties = Properties({
    'header:${EmailProperty.headerListPostKey}:asText',
    'header:${EmailProperty.headerUnsubscribeKey}:asText',
  });

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final searchEmailController = Get.find<SearchEmailController>();
  final downloadManager = Get.find<DownloadManager>();
  final downloadProgressState = StreamController<Either<Failure, Success>>();

  ScrollController? scrollController;

  AccountId? get accountId => mailboxDashBoardController.accountId.value;
  Session? get session => mailboxDashBoardController.sessionCurrent;
  MailboxId? get sentMailboxId => mailboxDashBoardController.getMailboxIdByRole(
    PresentationMailbox.roleSent,
  );
  String? get ownEmailAddress => session?.getOwnEmailAddress();
  int get emailsToLoadMoreCount => emailIdsPresentation
    .values
    .where((email) => email == null)
    .length;
  bool get loadingThreadDetail => viewState.value.fold(
    (failure) => false,
    (success) => success is GettingThreadById
      || success is GettingEmailsByIds,
  );
  bool get isSearchRunning {
    final isWebSearchRunning = mailboxDashBoardController
      .searchController
      .isSearchEmailRunning;
    final isMobileSearchRunning = searchEmailController
      .searchIsRunning
      .value == true;
    return isWebSearchRunning || isMobileSearchRunning;
  }

  @override
  void onInit() {
    super.onInit();
    emailActionReactor = EmailActionReactor(
      _markAsEmailReadInteractor,
      _markAsStarEmailInteractor,
      _createNewEmailRuleFilterInteractor,
      _printEmailInteractor,
      _getEmailContentInteractor,
      _downloadAttachmentForWebInteractor,
    );
    downloadProgressState.stream.listen(handleDownloadProgressState);
    ever(mailboxDashBoardController.selectedEmail, (presentationEmail) {
      if (presentationEmail?.threadId == null) {
        closeThreadDetailAction(currentContext);
        return;
      }
      if (session != null &&
          accountId != null &&
          sentMailboxId != null &&
          ownEmailAddress != null) {
        scrollController = ScrollController();
        consumeState(_getEmailIdsByThreadIdInteractor.execute(
          presentationEmail!.threadId!,
          session!,
          accountId!,
          sentMailboxId!,
          ownEmailAddress!,
        ));
      }
    });
  }

  void reset() {
    emailIdsPresentation.clear();
    scrollController?.dispose();
    scrollController = null;
    currentExpandedEmailId.value = null;
    currentEmailLoaded.value = null;
  }

  @override
  void handleSuccessViewState(success) {
    if (success is GetThreadByIdSuccess) {
      handleGetEmailIdsByThreadIdSuccess(success);
      initializeThreadDetailEmails();
    } else if (success is GetEmailsByIdsSuccess) {
      handleGetEmailsByIdsSuccess(success);
    } else if (success is MarkAsEmailReadSuccess) {
      markCollapsedEmailUnreadSuccess(success);
    } else if (success is MarkAsStarEmailSuccess) {
      markCollapsedEmailStarSuccess(success);
    } else if (success is CreateNewRuleFilterSuccess) {
      quickCreateRuleFromCollapsedEmailSuccess(success);
    } else if (success is DownloadAttachmentForWebSuccess) {
      handleDownloadSuccess(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(failure) {
    if (failure is GetThreadByIdFailure) {
      showRetryToast(failure);
      return;
    }
    if (failure is GetEmailsByIdsFailure) {
      showRetryToast(failure);
      return;
    }
    if (failure is DownloadAttachmentForWebFailure) {
      handleDownloadFailure(failure);
      return;
    }
    super.handleFailureViewState(failure);
  }
}