import 'dart:async';

import 'package:core/data/network/download/download_manager.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/properties/properties.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/email/individual_header_identifier.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/email_property.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/extensions/keyword_identifier_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/domain/state/add_a_label_to_an_thread_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/labels/remove_a_label_from_an_thread_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/print_email_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/add_a_label_to_a_thread_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/labels/remove_a_label_from_a_thread_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_star_email_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/print_email_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/action/email_ui_action.dart';
import 'package:tmail_ui_user/features/email/presentation/model/email_loaded.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_action_reactor/email_action_reactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/create_new_rule_filter_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/create_new_email_rule_filter_interactor.dart';
import 'package:tmail_ui_user/features/network_connection/presentation/network_connection_controller.dart'
  if (dart.library.html) 'package:tmail_ui_user/features/network_connection/presentation/web_network_connection_controller.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_controller.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_multiple_email_read_state.dart';
import 'package:tmail_ui_user/features/thread/domain/state/mark_as_star_multiple_email_state.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_multiple_email_read_interactor.dart';
import 'package:tmail_ui_user/features/thread/domain/usecases/mark_as_star_multiple_email_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/model/email_in_thread_detail_info.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_emails_by_ids_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/state/get_thread_by_id_state.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_emails_by_ids_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/domain/usecases/get_thread_by_id_interactor.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/action/thread_detail_ui_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_email_moved_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_get_email_ids_by_thread_id_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_get_emails_by_ids_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_get_thread_by_id_failure.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_mark_multiple_emails_read_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_mail_shortcut_actions_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/handle_refresh_thread_detail_action.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/initialize_thread_detail_emails.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/labels/add_label_to_thread_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/labels/remove_label_from_thread_extension.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/mark_collapsed_email_unread_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/quick_create_rule_from_collapsed_email_success.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/extension/thread_detail_on_selected_email_updated.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/model/mail_view_shortcut_action_view_event.dart';
import 'package:tmail_ui_user/features/thread_detail/presentation/thread_detail_manager.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ThreadDetailController extends BaseController {
  final GetThreadByIdInteractor _getEmailIdsByThreadIdInteractor;
  final GetEmailsByIdsInteractor getEmailsByIdsInteractor;
  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;
  final MarkAsStarEmailInteractor _markAsStarEmailInteractor;
  final PrintEmailInteractor _printEmailInteractor;
  final GetEmailContentInteractor _getEmailContentInteractor;
  final MarkAsStarMultipleEmailInteractor markAsStarMultipleEmailInteractor;
  final MarkAsMultipleEmailReadInteractor markAsMultipleEmailReadInteractor;
  final AddALabelToAThreadInteractor addALabelToAThreadInteractor;
  final RemoveALabelFromAThreadInteractor removeALabelFromAThreadInteractor;

  ThreadDetailController(
    this._getEmailIdsByThreadIdInteractor,
    this.getEmailsByIdsInteractor,
    this._markAsEmailReadInteractor,
    this._markAsStarEmailInteractor,
    this._printEmailInteractor,
    this._getEmailContentInteractor,
    this.markAsStarMultipleEmailInteractor,
    this.markAsMultipleEmailReadInteractor,
    this.addALabelToAThreadInteractor,
    this.removeALabelFromAThreadInteractor,
  );

  final emailIdsPresentation = <EmailId, PresentationEmail?>{}.obs;
  final currentExpandedEmailId = Rxn<EmailId>();
  final currentEmailLoaded = Rxn<EmailLoaded>();
  final emailsInThreadDetailInfo = RxList<EmailInThreadDetailInfo>();

  late final EmailActionReactor emailActionReactor;
  final additionalProperties = Properties({
    IndividualHeaderIdentifier.listPostHeader.value,
    EmailProperty.references,
    EmailProperty.messageId,
  });
  final cachedEmailLoaded = <EmailId, EmailLoaded>{};
  late final _threadGetDebouncer = Debouncer<({ThreadId? threadId, bool isSentMailbox})?>(
    const Duration(milliseconds: 500),
    initialValue: null,
    checkEquality: false,
    onChanged: (value) {
      if (_validateLoadThread(value?.threadId)) {
        consumeState(_getEmailIdsByThreadIdInteractor.execute(
          value!.threadId!,
          session!,
          accountId!,
          sentMailboxId!,
          ownEmailAddress,
          isSentMailbox: value.isSentMailbox,
        ));
      }
    },
  );

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final searchEmailController = Get.find<SearchEmailController>();
  final networkConnectionController = Get.find<NetworkConnectionController>();
  final threadDetailManager = Get.find<ThreadDetailManager>();
  final downloadManager = Get.find<DownloadManager>();

  ScrollController? scrollController;
  CreateNewEmailRuleFilterInteractor? _createNewEmailRuleFilterInteractor;
  bool loadThreadOnThreadChanged = false;
  bool isDisplayAllAttachments = false;
  FocusNode? keyboardShortcutFocusNode;
  StreamController<MailViewShortcutActionViewEvent>? shortcutActionEventController;
  StreamSubscription<MailViewShortcutActionViewEvent>? shortcutActionEventSubscription;

  AccountId? get accountId => mailboxDashBoardController.accountId.value;
  Session? get session => mailboxDashBoardController.sessionCurrent;
  MailboxId? get sentMailboxId => mailboxDashBoardController.getMailboxIdByRole(
    PresentationMailbox.roleSent,
  );

  String get ownEmailAddress =>
      mailboxDashBoardController.ownEmailAddress.value;

  bool get isSearchRunning {
    final isWebSearchRunning = mailboxDashBoardController
      .searchController
      .isSearchEmailRunning;
    final isMobileSearchRunning = searchEmailController
      .searchIsRunning
      .value == true;
    return isWebSearchRunning || isMobileSearchRunning;
  }
  bool get networkConnected =>
      networkConnectionController.isNetworkConnectionAvailable();
  bool get isThreadDetailEnabled =>
      threadDetailManager.isThreadDetailEnabled;
  GlobalObjectKey? get expandedEmailHtmlViewKey => currentExpandedEmailId.value != null
      ? GlobalObjectKey(currentExpandedEmailId.value!)
      : null;

  @override
  void onInit() {
    super.onInit();
    ever(mailboxDashBoardController.accountId, (accountId) {
      if (accountId == null) return;

      injectRuleFilterBindings(session, accountId);
      _createNewEmailRuleFilterInteractor = getBinding<CreateNewEmailRuleFilterInteractor>();
      emailActionReactor = EmailActionReactor(
        _markAsEmailReadInteractor,
        _markAsStarEmailInteractor,
        _createNewEmailRuleFilterInteractor,
        _printEmailInteractor,
        _getEmailContentInteractor,
      );
    });
    ever(mailboxDashBoardController.selectedEmail, (presentationEmail) async {
      onSelectedEmailUpdated(
        presentationEmail,
        currentContext,
      );
    });
    ever(mailboxDashBoardController.threadDetailUIAction, (action) {
      if (action is UpdatedEmailKeywordsAction) {
        emailIdsPresentation
          [action.emailId]
          ?.keywords
          ?[action.updatedKeyword] = action.value;
        if (action.updatedKeyword == KeyWordIdentifierExtension.unsubscribeMail) {
          emailIdsPresentation
            [action.emailId]
            ?..emailHeader?.removeWhere((element) {
              return element.name == EmailProperty.headerUnsubscribeKey;
            })
            ..listUnsubscribeHeader?.clear();
        }
      } else if (action is EmailMovedAction) {
        handleEmailMovedAction(action);
      } else if (action is LoadThreadDetailAfterSelectedEmailAction) {
        _threadGetDebouncer.value = (
          threadId: action.threadId,
          isSentMailbox: action.isSentMailbox,
        );
      } else if (action is ReclaimMailViewKeyboardShortcutFocusAction) {
        refocusMailShortcutFocus();
      } else if (action is ClearMailViewKeyboardShortcutFocusAction) {
        clearMailShortcutFocus();
      } else if (action is ResyncThreadDetailWhenSettingChangedAction) {
        resyncThreadDetailWhenSettingChanged();
      }
      // Reset [threadDetailUIAction] to original value
      mailboxDashBoardController.dispatchThreadDetailUIAction(
        ThreadDetailUIAction(),
      );
    });
    ever(mailboxDashBoardController.emailUIAction, (action) {
      if (action is RefreshThreadDetailAction) {
        mailboxDashBoardController.dispatchEmailUIAction(EmailUIAction());
        handleRefreshThreadDetailAction(
          action,
          _getEmailIdsByThreadIdInteractor,
        );
      }
    });
  }

  bool _validateLoadThread(ThreadId? threadId) {
    return mailboxDashBoardController.selectedEmail.value?.threadId != null &&
        threadId == mailboxDashBoardController.selectedEmail.value?.threadId &&
        session != null &&
        accountId != null &&
        sentMailboxId != null &&
        ownEmailAddress.isNotEmpty &&
        networkConnected &&
        isThreadDetailEnabled;
  }

  void reset() {
    emailIdsPresentation.clear();
    scrollController?.dispose();
    scrollController = null;
    currentExpandedEmailId.value = null;
    currentEmailLoaded.value = null;
    cachedEmailLoaded.clear();
    _threadGetDebouncer.value = null;
    isDisplayAllAttachments = false;
  }

  @override
  void handleSuccessViewState(success) {
    if (success is GetThreadByIdSuccess) {
      handleGetEmailIdsByThreadIdSuccess(success);
      initializeThreadDetailEmails(success);
    } else if (success is GetEmailsByIdsSuccess) {
      handleGetEmailsByIdsSuccess(success);
    } else if (success is MarkAsEmailReadSuccess) {
      markCollapsedEmailReadSuccess(success);
    } else if (success is MarkAsMultipleEmailReadAllSuccess) {
      handleMarkMultipleEmailsReadSuccess(
        success,
        success.readActions,
        success.emailIds,
      );
    } else if (success is MarkAsMultipleEmailReadHasSomeEmailFailure) {
      handleMarkMultipleEmailsReadSuccess(
        success,
        success.readActions,
        success.successEmailIds,
      );
    } else if (success is CreateNewRuleFilterSuccess) {
      quickCreateRuleFromCollapsedEmailSuccess(success);
    } else if (success is AddALabelToAThreadSuccess) {
      handleAddLabelToThreadSuccess(success);
    } else if (success is RemoveALabelFromAThreadSuccess) {
      handleRemoveLabelFromThreadSuccess(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(failure) {
    if (failure is GetThreadByIdFailure) {
      handleGetThreadByIdFailure(failure);
    } else if (failure is GetEmailsByIdsFailure) {
      if (failure.updateCurrentThreadDetail) return;
      showRetryToast(failure);
    } else if (failure is PrintEmailFailure) {
      if (currentOverlayContext != null && currentContext != null) {
        appToast.showToastErrorMessage(
          currentOverlayContext!,
          AppLocalizations.of(currentContext!).unknownError,
        );
      }
    } else if (failure is MarkAsMultipleEmailReadFailure ||
        failure is MarkAsStarMultipleEmailFailure) {
      toastManager.showMessageFailure(failure as FeatureFailure);
    } else if (failure is AddALabelToAThreadFailure) {
      handleAddLabelToThreadFailure(failure);
    } else if (failure is RemoveALabelFromAThreadFailure) {
      handleRemoveLabelFromThreadFailure(failure);
    } else {
      super.handleFailureViewState(failure);
    }
  }

  @override
  void onClose() {
    onKeyboardShortcutDispose();
    super.onClose();
  }
}