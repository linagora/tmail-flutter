import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/attachment_item_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_back_button.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/information_sender_and_receiver_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class EmailRobot extends CoreRobot {
  EmailRobot(super.$);

  Future<void> onTapForwardEmail() async {
    await $(#forward_email_button).tap();
    await $.pump(const Duration(seconds: 2));
  }

  Future<void> tapDownloadAllButton() async {
    await $(#download_all_attachments_button).tap();
    await $.pumpAndSettle();
  }

  Future<void> onTapReplyEmail() async {
    await $(#reply_email_button).tap();
  }

  Future<void> onTapReplyToListEmail() async {
    await $(#reply_to_list_email_button).tap();
  }

  Future<void> onTapReplyAllEmail() async {
    await $(#reply_all_emails_button).tap();
  }

  Future<void> onTapBackButton() async {
    await $(find.byType(EmailViewBackButton)).first.tap();
  }

  Future<void> tapEmailDetailedMoreButton() async {
    await $(#email_detailed_more_button).tap();
  }

  Future<void> tapMarkAsUnreadOptionInContextMenu() async {
    await $(AppLocalizations().mark_as_unread).tap();
  }

  Future<void> tapEmailDetailedStarButton() async {
    await $(AppLocalizations().starred).tap();
  }

  Future<void> tapEmailDetailedUnstarButton() async {
    await $(AppLocalizations().not_starred).tap();
  }

  Future<void> tapEmailDetailedMoveEmailButton() async {
    await $(AppLocalizations().moveMessage).tap();
  }

  Future<void> tapEmailDetailedDeleteEmailButton() async {
    await $(AppLocalizations().move_to_trash).tap();
  }

  Future<void> tapMarkAsSpamOptionInContextMenu() async {
    await $(AppLocalizations().markAsSpam).tap();
  }

  Future<void> tapArchiveMessageOptionInContextMenu() async {
    await $(AppLocalizations().archiveMessage).tap();
  }

  Future<void> tapSenderEmailAddress(String email) async {
    await $(InformationSenderAndReceiverBuilder).$(email).tap();
  }

  Future<void> tapRecipientEmailAddress(String email) async {
    await $(InformationSenderAndReceiverBuilder).$(email).tap();
  }

  Future<void> longPressSenderEmailAddress(String email) async {
    await $(InformationSenderAndReceiverBuilder).$(email).longPress();
  }

  Future<void> onTapAttachmentItem() async {
    await $(AttachmentItemWidget).$(InkWell).tap();
  }
}