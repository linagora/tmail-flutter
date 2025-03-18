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

  Future<void> onTapReplyToListEmail() async {
    await $(#reply_to_list_email_button).tap();
  }

  Future<void> onTapReplyAllEmail() async {
    await $(#reply_all_emails_button).tap();
  }

  Future<void> onTapBackButton() async {
    await $(find.byType(EmailViewBackButton)).first.tap();
  }
}