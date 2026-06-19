import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/base/widget/clean_messages_banner.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';
import '../utils/wait_for_condition.dart';
import 'abstract/abstract_thread_assertion_robot.dart';

class ThreadAssertionRobot extends CoreRobot implements AbstractThreadAssertionRobot {
  ThreadAssertionRobot(super.$);

  @override
  Future<void> expectAppGridButtonVisible() async {
    await $(const ValueKey(UiKeys.toggleAppGridButton)).waitUntilVisible();
  }

  @override
  Future<void> expectTrashBannerVisible() async {
    await $(find.textContaining(AppLocalizations().empty_trash_now)).waitUntilVisible();
  }

  @override
  Future<void> expectTrashBannerInvisible() async {
    await $(const Key(UiKeys.cleanMessageBannerNotVisible)).waitUntilExists();
    await waitForCondition(() => !$(CleanMessagesBanner).visible);
  }

  @override
  Future<void> expectEmptyTrashThreadView() async {
    await $(const Key(UiKeys.emptyThreadView)).waitUntilVisible();
  }
}
