import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import 'abstract/abstract_thread_empty_trash_robot.dart';

class ThreadEmptyTrashRobot extends CoreRobot implements AbstractThreadEmptyTrashRobot {
  ThreadEmptyTrashRobot(super.$);

  @override
  Future<void> tapEmptyTrashBanner() async =>
      $(find.textContaining(AppLocalizations().empty_trash_now)).tap();

  @override
  Future<void> confirmEmptyTrash() async =>
      $(AppLocalizations().delete).tap();
}
