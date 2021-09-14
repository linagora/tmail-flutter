import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/features/email/domain/state/mark_as_email_read_state.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/get_email_content_interactor.dart';
import 'package:tmail_ui_user/features/email/domain/usecases/mark_as_email_read_interactor.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/actions/app_action.dart';
import 'package:tmail_ui_user/main/actions/email_action.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class EmailController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final responsiveUtils = Get.find<ResponsiveUtils>();

  final GetEmailContentInteractor _getEmailContentInteractor;
  final MarkAsEmailReadInteractor _markAsEmailReadInteractor;

  final emailAddressExpandMode = ExpandMode.COLLAPSE.obs;
  EmailContent? emailContent;
  AppAction? emailActionCurrent;

  EmailController(this._getEmailContentInteractor, this._markAsEmailReadInteractor);

  @override
  void onReady() {
    super.onReady();
    mailboxDashBoardController.selectedEmail.listen((presentationEmail) {
      toggleDisplayEmailAddressAction(expandMode: ExpandMode.COLLAPSE);
      emailActionCurrent = null;
      final accountId = mailboxDashBoardController.accountId.value;
      if (accountId != null && presentationEmail != null) {
        _getEmailContentAction(accountId, presentationEmail.id);
        if (presentationEmail.isUnReadEmail()) {
          markAsEmailRead(unread: false);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    mailboxDashBoardController.selectedEmail.close();
  }

  void _getEmailContentAction(AccountId accountId, EmailId emailId) async {
    consumeState(_getEmailContentInteractor.execute(accountId, emailId));
  }

  @override
  void onData(Either<Failure, Success> newState) {
    super.onData(newState);
  }

  @override
  void onDone() {
    viewState.value.map((success) {
      if (success is GetEmailContentSuccess) {
        emailContent = success.emailContent;
      }
    });
  }

  @override
  void onError(error) {
  }

  void toggleDisplayEmailAddressAction({required ExpandMode expandMode}) {
    emailAddressExpandMode.value = expandMode;
  }

  void markAsEmailRead({required bool unread}) async {
    final accountId = mailboxDashBoardController.accountId.value;
    final presentationEmail = mailboxDashBoardController.selectedEmail.value;
    final mailboxCurrent = mailboxDashBoardController.selectedMailbox.value;
    if (accountId != null && presentationEmail != null && mailboxCurrent != null) {
      _markAsEmailReadInteractor.execute(accountId, presentationEmail.id, unread)
          .then((result) => result
            .map((success) {
              if (success is MarkAsEmailReadSuccess) {
                emailActionCurrent = MarkAsEmailReadAction(presentationEmail.id, mailboxCurrent);
                _updateMailboxDashBoardActionForDesktop(emailActionCurrent);
              }
            })
          );
    }
  }

  void _updateMailboxDashBoardActionForDesktop(AppAction? appAction) {
    if (Get.context != null && responsiveUtils.isDesktop(Get.context!)) {
      mailboxDashBoardController.setMailboxDashBoardAction(appAction);
    }
  }

  bool canComposeEmail() => mailboxDashBoardController.sessionCurrent != null
      && mailboxDashBoardController.userProfile.value != null
      && mailboxDashBoardController.mapMailboxId.containsKey(PresentationMailbox.roleOutbox)
      && mailboxDashBoardController.selectedEmail.value != null;

  void goToThreadView(BuildContext context) {
    popBack(result: emailActionCurrent);
  }

  void pressEmailAction(EmailActionType emailActionType) {
    if (canComposeEmail()) {
      Get.toNamed(
        AppRoutes.COMPOSER,
        arguments: ComposerArguments(
          emailActionType: emailActionType,
          presentationEmail: mailboxDashBoardController.selectedEmail.value!,
          emailContent: emailContent,
          session: mailboxDashBoardController.sessionCurrent!,
          userProfile: mailboxDashBoardController.userProfile.value!,
          mapMailboxId: mailboxDashBoardController.mapMailboxId));
    }
  }
}