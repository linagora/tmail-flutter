import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_mailbox_empty_trash_robot.dart';

class MailboxEmptyTrashRobot extends CoreRobot
    implements AbstractMailboxEmptyTrashRobot {
  final _l10n = AppLocalizations();

  MailboxEmptyTrashRobot(super.$);

  @override
  Future<void> tapEmptyTrash() async => $(_l10n.emptyTrash).tap();

  @override
  Future<void> confirmEmptyTrash() async => $(_l10n.delete).tap();
}
