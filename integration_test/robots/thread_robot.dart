import 'package:core/presentation/views/search/search_bar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/compose_floating_button.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/scroll_to_top_button_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class ThreadRobot extends CoreRobot {
  ThreadRobot(super.$);

  Future<void> openComposer() async {
    await $(ComposeFloatingButton).$(InkWell).tap();
  }

  Future<void> openSearchView() async {
    await $(SearchBarView).$(InkWell).tap();
  }

  Future<void> tapOnSearchField() async {
    await $(ThreadView).$(SearchBarView).tap();
  }

  Future<void> openEmailWithSubject(String subject) async {
    final email = $(EmailTileBuilder)
      .which<EmailTileBuilder>((view) => view.presentationEmail.subject == subject);
    await $.waitUntilVisible(email);
    await email.tap();
    await $.pump(const Duration(seconds: 2));
  }

  Future<void> openMailbox() async {
    await $(#mobile_mailbox_menu_button).tap();
  }

  Future<void> tapEmptyTrashBanner() => $(' ${AppLocalizations().empty_trash_now}').tap();

  Future<void> tapDeleteAllButtonOnEmptyTrashConfirmDialog(
    AppLocalizations appLocalizations,
  ) => $(appLocalizations.delete_all).tap();

  Future<void> scrollToEmailWithSubject(String subject) async {
    await $.scrollUntilVisible(finder: $(subject), delta: 300);
    await $.pumpAndSettle();
  }

  Future<void> scrollToTop() async {
    await $(ScrollToTopButtonWidget).$(InkWell).tap();
    await $.pumpAndSettle();
  }

  Future<void> openQuickFilter() async {
    await $(#mobile_filter_message_button).tap();
  }

  Future<void> selectAttachmentFilter() async {
    await $(#attachments_filter).tap();
  }

  Future<void> selectUnreadFilter() async {
    await $(#unread_filter).tap();
  }

  Future<void> selectStarredFilter() async {
    await $(#starred_filter).tap();
  }

  Future<void> pullToRefreshByEmailSubject(String subject) async {
    await $(subject).waitUntilVisible();
    await $.tester.fling(
      $(subject),
      const Offset(0, 300),
      1000,
    );
    await $.pumpAndSettle();
  }

  Future<void> tapOnMailboxWithName(String name) async {
    await $(name).tap();
    await $.pumpAndSettle();
  }

  Future<void> confirmEmptyTrash() async {
    await $(AppLocalizations().delete_all).tap();
  }

  Future<void> tapEmptySpamBanner() async {
    await $(' ${AppLocalizations().deleteAllSpamEmailsNow}').tap();
  }

  Future<void> confirmEmptySpam() async {
    await $(AppLocalizations().delete_all).tap();
  }

  Future<void> tapEmptyTrashAfterLongPress() async {
    await $(AppLocalizations().emptyTrash).tap();
  }

  Future<void> tapConfirmEmptyTrashAfterLongPress() async {
    await $(AppLocalizations().delete).tap();
    await $.pumpAndSettle(duration: const Duration(seconds: 2));
  }

  Future<void> tapEmptySpamAfterLongPress() async {
    await $(AppLocalizations().deleteAllSpamEmails).tap();
  }

  Future<void> longPressEmailWithSubject(String subject) async {
    await $(subject).longPress();
  }

  Future<void> moveEmailToMailboxWithName(String mailboxName) async {
    await $(#moreAction_selected_email_button).tap();
    await $.pumpAndTrySettle();

    await $(#moveToMailbox_action).tap();
    await $.pumpAndTrySettle();

    await $(mailboxName).tap();
    await $.pumpAndTrySettle();
  }

  Future<void> moveEmailToTrash() async {
    await $(#moveToTrash_selected_email_button).tap();
    await $.pumpAndTrySettle();
  }

  Future<void> tapMarkAsReadButton() async {
    await $(#markAsRead_selected_email_button).tap();
    await $.pumpAndTrySettle();
  }

  Future<void> tapMarkAsStarAction() async {
    await $(#moreAction_selected_email_button).tap();
    await $.pumpAndTrySettle();
    await $(#markAsStarred_action).tap();
    await $.pumpAndTrySettle();
  }

  Future<void> tapMarkAsSpamAction() async {
    await $(#moreAction_selected_email_button).tap();
    await $.pumpAndTrySettle();
    await $(#moveToSpam_action).tap();
    await $.pumpAndTrySettle();
  }
}