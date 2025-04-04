import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/widget/material_text_button.dart';
import 'package:tmail_ui_user/features/email/presentation/widgets/email_view_back_button.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class EmailRobot extends CoreRobot {
  EmailRobot(super.$);

  Future<void> onTapForwardEmail() async {
    await $(#forward_email_button).tap();
    await $.pump(const Duration(seconds: 2));
  }

  Future<void> tapDownloadAllButton() async {
    await $(AppLocalizations().downloadAll).tap();
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
    await $(#markAsUnread_action).tap();
  }

  Future<void> tapEmailDetailedStarButton() async {
    await $(#email_detailed_star_button).tap();
  }

  Future<void> tapEmailDetailedMoveEmailButton() async {
    await $(#email_detailed_move_email_button).tap();
  }

  Future<void> tapEmailDetailedDeleteEmailButton() async {
    await $(#email_detailed_delete_email_button).tap();
  }

  Future<void> tapMarkAsSpamOptionInContextMenu() async {
    await $(#moveToSpam_action).tap();
  }

  Future<void> tapArchiveMessageOptionInContextMenu() async {
    await $(#archiveMessage_action).tap();
  }

  Future<void> tapSenderEmailAddress(String email) async {
    await $(MaterialTextButton)
        .which<MaterialTextButton>((widget) => widget.label.contains(email))
        .first
        .tap();
  }

  Future<void> tapRecipientEmailAddress(String email) async {
    await $(TMailButtonWidget)
        .which<TMailButtonWidget>((widget) => widget.text.contains(email))
        .first
        .tap();
  }
}