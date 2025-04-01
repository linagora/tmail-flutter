import 'package:flutter_test/flutter_test.dart';
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

  Future<void> onTapBackButton() async {
    await $(find.byType(EmailViewBackButton)).first.tap();
  }

  Future<void> tapEmailDetailedMoreButton() async {
    await $(#email_detailed_more_button).tap();
  }

  Future<void> tapMarkAsUnreadOptionInContextMenu() async {
    await $(#markAsUnread_action).tap();
  }
}